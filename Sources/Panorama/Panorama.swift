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

	open override var frame: CGRect {
		didSet {
			self.panoramaView?.setNeedsLayout()
		}
	}
	weak var panoramaView: PanoramaView?

	var maximumZoomScale: CGFloat = 4.0 {
		didSet {
			#if os(iOS)
			self.panoramaView?.scrollView.maximumZoomScale = self.maximumZoomScale
			#elseif os(macOS)
			self.panoramaView?.scrollView.maxMagnification = self.maximumZoomScale
			#endif
		}
	}
	var minimumZoomScale: CGFloat = 1.0 {
		didSet {
			#if os(iOS)
			self.panoramaView?.scrollView.minimumZoomScale = self.minimumZoomScale
			#elseif os(macOS)
			self.panoramaView?.scrollView.minMagnification = self.minimumZoomScale
			#endif
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	open func didMove(to panoramaView: PanoramaView?) {
		self.panoramaView = panoramaView
	}

	open override func setNeedsDisplay() {
		self.panoramaView?.backView.setNeedsDisplay()
	}

	open override var panorama: Panorama? {
		return self
	}

	open override var transformToPanorama: CGAffineTransform? {
		return CGAffineTransform.identity
	}

	// MARK: -

	#if os(iOS)
	
	public var activeTouchViewlet = [UITouch: Viewlet]()
	
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let point = touch.location(in: self), let viewlet = self.findViewlet(point: point) {
				if viewlet.enabled {
					activeTouchViewlet[touch] = viewlet
					viewlet.touchesBegan(touches, with: event)
				}
			}
		}
	}

	open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch] {
				// why not checking enabled? -- once start handling began then let them finish
				viewlet.touchesMoved(touches, with: event)
			}
		}
	}
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch] {
				viewlet.touchesEnded(touches, with: event)
			}
			self.activeTouchViewlet[touch] = nil
		}
	}
	
	open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch] {
				viewlet.touchesCancelled(touches, with: event)
			}
			self.activeTouchViewlet[touch] = nil
		}
	}
	#endif

	#if os(macOS)
	open var activeViewlet: Viewlet?

	open override func mouseDown(with event: NSEvent) {
		if let point = event.location(in: self), let viewlet = self.findViewlet(point: point) {
			if viewlet.enabled {
				activeViewlet = viewlet
				viewlet.mouseDown(with: event)
			}
		}
	}

	open override func mouseDragged(with event: NSEvent) {
		// why not checking enabled? -- once start handling mouseDown then let them finish
		activeViewlet?.mouseMoved(with: event)
	}
	
	open override func mouseUp(with event: NSEvent) {
		activeViewlet?.mouseUp(with: event)
		activeViewlet = nil
	}
	#endif

	#if os(iOS)
	#endif
}

