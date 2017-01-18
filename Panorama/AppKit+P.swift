//
//	NSEvent+P.swift
//	Panorama
//
//	Created by Kaz Yoshikawa on 1/18/17.
//	Copyright © 2017 Electricwoods LLC. All rights reserved.
//

import Cocoa


extension NSEvent {

	func location(in panorama: Panorama) -> CGPoint? {
		if let contentView = panorama.panoramaView?.contentView {
			guard contentView.window != nil else { return nil }
			return contentView.convert(self.locationInWindow, from: nil)
		}
		return nil
	}
	
	func location(in view: NSView) -> CGPoint? {
		guard view.window != nil else { return nil }
		return view.convert(self.locationInWindow, from: nil)
	}

}
