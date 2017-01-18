//
//	PanoramaContentView.swift
//	Panorama
//
//	Created by Kaz Yoshikawa on 1/18/17.
//	Copyright © 2017 Electricwoods LLC. All rights reserved.
//

import Foundation


#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif


class PanoramaContentView: XView {

	weak var panoramaView: PanoramaView!

	var panorama: Panorama? {
		return self.panoramaView.panorama
	}

	#if os(iOS)
	override func layoutSubviews() {
		assert(panoramaView != nil)
		super.layoutSubviews()
		self.backgroundColor = XColor.clear
	}
	#endif

	#if os(macOS)
	override var isFlipped: Bool { return true }
	#endif

	#if os(iOS)
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.panorama?.touchesBegan(touches, with: event)
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.panorama?.touchesMoved(touches, with: event)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.panorama?.touchesEnded(touches, with: event)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.panorama?.touchesCancelled(touches, with: event)
	}
	#endif

	#if os(macOS)
	override func touchesBegan(with event: NSEvent) {
		self.panorama?.touchesBegan(with: event)
	}

	override func touchesMoved(with event: NSEvent) {
		self.panorama?.touchesMoved(with: event)
	}

	override func touchesEnded(with event: NSEvent) {
		self.panorama?.touchesEnded(with: event)
	}

	override func touchesCancelled(with event: NSEvent) {
		self.panorama?.touchesCancelled(with: event)
	}
	#endif

	#if os(macOS)
	override func mouseDown(with event: NSEvent) {
		self.panorama?.mouseDown(with: event)
	}

	override func mouseDragged(with event: NSEvent) {
		self.panorama?.mouseDragged(with: event)
	}
	
	override func mouseUp(with event: NSEvent) {
		self.panorama?.mouseUp(with: event)
	}

	override func mouseMoved(with event: NSEvent) {
		self.panorama?.mouseMoved(with: event)
	}
	
	override func rightMouseDown(with event: NSEvent) {
		self.panorama?.rightMouseDown(with: event)
	}
	
	override func rightMouseDragged(with event: NSEvent) {
		self.panorama?.rightMouseDragged(with: event)
	}
	
	override func rightMouseUp(with event: NSEvent) {
		self.panorama?.rightMouseUp(with: event)
	}
	
	override func otherMouseDown(with event: NSEvent) {
		self.panorama?.otherMouseDown(with: event)
	}
	
	override func otherMouseDragged(with event: NSEvent) {
		self.panorama?.otherMouseDragged(with: event)
	}
	
	override func otherMouseUp(with event: NSEvent) {
		self.panorama?.otherMouseUp(with: event)
	}
	
	override func mouseExited(with event: NSEvent) {
		self.panorama?.mouseExited(with: event)
	}
	
	override func mouseEntered(with event: NSEvent) {
		self.panorama?.mouseEntered(with: event)
	}
	#endif
	
}


