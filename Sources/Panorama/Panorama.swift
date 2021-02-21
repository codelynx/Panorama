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

	override var frame: CGRect {
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

	func didMove(to panoramaView: PanoramaView?) {
		self.panoramaView = panoramaView
	}

	override func setNeedsDisplay() {
		self.panoramaView?.backView.setNeedsDisplay()
	}

	override var panorama: Panorama? {
		return self
	}

	override var transformToPanorama: CGAffineTransform? {
		return CGAffineTransform.identity
	}

	// MARK: -

	#if os(iOS)
	
	var activeTouchViewlet = [UITouch: Viewlet]()
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let point = touch.location(in: self), let viewlet = self.findViewlet(point: point) {
				if viewlet.enabled {
					activeTouchViewlet[touch] = viewlet
					viewlet.touchesBegan(touches, with: event)
				}
			}
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch] {
				// why not checking enabled? -- once start handling began then let them finish
				viewlet.touchesMoved(touches, with: event)
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch] {
				viewlet.touchesEnded(touches, with: event)
			}
			self.activeTouchViewlet[touch] = nil
		}
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let viewlet = self.activeTouchViewlet[touch] {
				viewlet.touchesCancelled(touches, with: event)
			}
			self.activeTouchViewlet[touch] = nil
		}
	}
	#endif

	#if os(macOS)
	var activeViewlet: Viewlet?

	override func mouseDown(with event: NSEvent) {
		if let point = event.location(in: self), let viewlet = self.findViewlet(point: point) {
			if viewlet.enabled {
				activeViewlet = viewlet
				viewlet.mouseDown(with: event)
			}
		}
	}

	override func mouseDragged(with event: NSEvent) {
		// why not checking enabled? -- once start handling mouseDown then let them finish
		activeViewlet?.mouseMoved(with: event)
	}
	
	override func mouseUp(with event: NSEvent) {
		activeViewlet?.mouseUp(with: event)
		activeViewlet = nil
	}
	#endif

	#if os(iOS)
	#endif
}

