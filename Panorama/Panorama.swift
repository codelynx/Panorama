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


class Panorama {

	var bounds: CGRect {
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

	init(bounds: CGRect) {
		self.bounds = bounds
	}

	func didMove(to panoramaView: PanoramaView?) {
		self.panoramaView = panoramaView
	}

	func draw(in context: CGContext) {
		XColor.red.set()
		XBezierPath(ovalIn: self.bounds).fill()
	}
	
	
	func setNeedsDisplay() {
		self.panoramaView?.backView.setNeedsDisplay()
	}

	#if os(iOS)
	func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
	}

	func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
	}
	
	func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
	}
	
	func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
	}
	#endif

	#if os(macOS)
	func touchesBegan(with event: NSEvent) {
	}

	func touchesMoved(with event: NSEvent) {
	}

	func touchesEnded(with event: NSEvent) {
	}

	func touchesCancelled(with event: NSEvent) {
	}
	#endif

	#if os(macOS)
	func mouseDown(with event: NSEvent) {
	}

	func mouseDragged(with event: NSEvent) {
	}
	
	func mouseUp(with event: NSEvent) {
	}

	func mouseMoved(with event: NSEvent) {
	}
	
	func rightMouseDown(with event: NSEvent) {
	}
	
	func rightMouseDragged(with event: NSEvent) {
	}
	
	func rightMouseUp(with event: NSEvent) {
	}
	
	func otherMouseDown(with event: NSEvent) {
	}
	
	func otherMouseDragged(with event: NSEvent) {
	}
	
	func otherMouseUp(with event: NSEvent) {
	}
	
	func mouseExited(with event: NSEvent) {
	}
	
	func mouseEntered(with event: NSEvent) {
	}
	#endif

}

