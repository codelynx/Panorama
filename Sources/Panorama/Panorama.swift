//
//	Panorama.swift
//	Panorama
//
//	Created by Kaz Yoshikawa on 1/18/17.
//	Copyright © 2017 Electricwoods LLC. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif


open class Panorama: Viewlet {

	public override var frame: CGRect {
		didSet {
			self.panoramaView?.setNeedsLayout()
		}
	}
	weak var panoramaView: PanoramaView?

	public var maximumZoomScale: CGFloat = 4.0 {
		didSet {
			#if os(iOS)
			self.panoramaView?.scrollView.maximumZoomScale = self.maximumZoomScale
			#elseif os(macOS)
			self.panoramaView?.scrollView.maxMagnification = self.maximumZoomScale
			#endif
		}
	}
	public var minimumZoomScale: CGFloat = 1.0 {
		didSet {
			#if os(iOS)
			self.panoramaView?.scrollView.minimumZoomScale = self.minimumZoomScale
			#elseif os(macOS)
			self.panoramaView?.scrollView.minMagnification = self.minimumZoomScale
			#endif
		}
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
	}

	open func didMove(to panoramaView: PanoramaView?) {
		self.panoramaView = panoramaView
	}

	override open func setNeedsDisplay() {
		self.panoramaView?.backView.setNeedsDisplay()
	}

	override open var panorama: Panorama? {
		return self
	}

	override open var transformToPanorama: CGAffineTransform? {
		return CGAffineTransform.identity
	}

	// MARK: -

	#if os(iOS)
	
	private var activeTouchViewlet = [UITouch: Viewlet]()
	
	override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		// Only process touches if we're the root panorama (attached to a PanoramaView)
		guard self.panoramaView != nil else {
			// If we're a nested panorama, just call super to handle as a regular viewlet
			super.touchesBegan(touches, with: event)
			return
		}
		
		for touch in touches {
			let point = touch.location(in: self.panoramaView!.contentView)
			
			if let viewlet = self.findViewlet(at: point) {
				// Don't forward to self or other Panoramas to avoid infinite recursion
				if viewlet !== self && !(viewlet is Panorama) && viewlet.isEnabled {
					activeTouchViewlet[touch] = viewlet
					viewlet.touchesBegan(touches, with: event)
				} else if viewlet !== self && viewlet.isEnabled {
					// For nested Panoramas, just track them but don't forward touches
					activeTouchViewlet[touch] = viewlet
				}
			}
		}
	}

	override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard self.panoramaView != nil else {
			super.touchesMoved(touches, with: event)
			return
		}
		
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch], !(viewlet is Panorama) {
				// why not checking enabled? -- once start handling began then let them finish
				viewlet.touchesMoved(touches, with: event)
			}
		}
	}
	
	override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard self.panoramaView != nil else {
			super.touchesEnded(touches, with: event)
			return
		}
		
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch], !(viewlet is Panorama) {
				viewlet.touchesEnded(touches, with: event)
			}
			self.activeTouchViewlet[touch] = nil
		}
	}
	
	override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard self.panoramaView != nil else {
			super.touchesCancelled(touches, with: event)
			return
		}
		
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch], !(viewlet is Panorama) {
				viewlet.touchesCancelled(touches, with: event)
			}
			self.activeTouchViewlet[touch] = nil
		}
	}
	#endif

	#if os(macOS)
	public var activeViewlet: Viewlet?

	override open func mouseDown(with event: NSEvent) {
		if let point = event.location(in: self), let viewlet = self.findViewlet(at: point) {
			if viewlet !== self, viewlet.isEnabled {
				activeViewlet = viewlet
				viewlet.mouseDown(with: event)
			}
		}
	}

	override open func mouseDragged(with event: NSEvent) {
		// why not checking enabled? -- once start handling mouseDown then let them finish
		activeViewlet?.mouseMoved(with: event)
	}
	
	override open func mouseUp(with event: NSEvent) {
		activeViewlet?.mouseUp(with: event)
		activeViewlet = nil
	}
	#endif

	#if os(iOS)
	#endif
}

