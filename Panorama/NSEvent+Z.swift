//
//	NSEvent+P.swift
//	ZKit
//
//	Created by Kaz Yoshikawa on 1/18/17.
//	Copyright © 2017 Electricwoods LLC. All rights reserved.
//

#if os(macOS)
import Cocoa

extension NSEvent {

	public func location(in view: NSView) -> CGPoint? {
		guard view.window != nil else { return nil }
		return view.convert(self.locationInWindow, from: nil)
	}

}

#endif
