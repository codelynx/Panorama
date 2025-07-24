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


open class PanoramaContentView: XView {

	weak var panoramaView: PanoramaView!

	var panorama: Panorama? {
		return self.panoramaView.panorama
	}

	#if os(iOS)
	open override func layoutSubviews() {
		assert(panoramaView != nil)
		super.layoutSubviews()
		self.backgroundColor = XColor.clear
	}
	#endif

	#if os(macOS)
	open override var isFlipped: Bool { return false }
	#endif

	#if os(iOS)
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.panorama?.touchesBegan(touches, with: event)
	}

	open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.panorama?.touchesMoved(touches, with: event)
	}
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.panorama?.touchesEnded(touches, with: event)
	}
	
	open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.panorama?.touchesCancelled(touches, with: event)
	}
	#endif

	#if os(macOS)
	open override func touchesBegan(with event: NSEvent) {
		self.panorama?.touchesBegan(with: event)
	}

	open override func touchesMoved(with event: NSEvent) {
		self.panorama?.touchesMoved(with: event)
	}

	open override func touchesEnded(with event: NSEvent) {
		self.panorama?.touchesEnded(with: event)
	}

	open override func touchesCancelled(with event: NSEvent) {
		self.panorama?.touchesCancelled(with: event)
	}
	#endif

	#if os(macOS)
	open override func mouseDown(with event: NSEvent) {
		self.panorama?.mouseDown(with: event)
	}

	open override func mouseDragged(with event: NSEvent) {
		self.panorama?.mouseDragged(with: event)
	}
	
	open override func mouseUp(with event: NSEvent) {
		self.panorama?.mouseUp(with: event)
	}

	open override func mouseMoved(with event: NSEvent) {
		self.panorama?.mouseMoved(with: event)
	}
	
	open override func rightMouseDown(with event: NSEvent) {
		self.panorama?.rightMouseDown(with: event)
	}
	
	open override func rightMouseDragged(with event: NSEvent) {
		self.panorama?.rightMouseDragged(with: event)
	}
	
	open override func rightMouseUp(with event: NSEvent) {
		self.panorama?.rightMouseUp(with: event)
	}
	
	open override func otherMouseDown(with event: NSEvent) {
		self.panorama?.otherMouseDown(with: event)
	}
	
	open override func otherMouseDragged(with event: NSEvent) {
		self.panorama?.otherMouseDragged(with: event)
	}
	
	open override func otherMouseUp(with event: NSEvent) {
		self.panorama?.otherMouseUp(with: event)
	}
	
	open override func mouseExited(with event: NSEvent) {
		self.panorama?.mouseExited(with: event)
	}
	
	open override func mouseEntered(with event: NSEvent) {
		self.panorama?.mouseEntered(with: event)
	}
	#endif
	
}


