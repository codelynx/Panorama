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
		for touch in touches {
			if let point = touch.location(in: self), let viewlet = self.findViewlet(point: point) {
				if viewlet.enabled {
					activeTouchViewlet[touch] = viewlet
					viewlet.touchesBegan(touches, with: event)
				}
			}
		}
	}

	override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch] {
				// why not checking enabled? -- once start handling began then let them finish
				viewlet.touchesMoved(touches, with: event)
			}
		}
	}
	
	override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch] {
				viewlet.touchesEnded(touches, with: event)
			}
			self.activeTouchViewlet[touch] = nil
		}
	}
	
	override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch] {
				viewlet.touchesCancelled(touches, with: event)
			}
			self.activeTouchViewlet[touch] = nil
		}
	}
	#endif

	#if os(macOS)
	public var activeViewlet: Viewlet?

	override open func mouseDown(with event: NSEvent) {
		if let point = event.location(in: self), let viewlet = self.findViewlet(point: point) {
			if viewlet !== self, viewlet.enabled {
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

