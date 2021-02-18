//
//	NSEvent+P.swift
//	ZKit
//
//	Created by Kaz Yoshikawa on 1/18/17.
//	Copyright © 2017 Electricwoods LLC. All rights reserved.
//

#if os(macOS)
import Cocoa

public extension NSEvent {

	public func location(in panorama: Panorama) -> CGPoint? {
		if let contentView: NSView = panorama.panoramaView?.contentView {
			return contentView.convert(self.locationInWindow, from: nil)
		}
		return nil
	}

}

#endif
