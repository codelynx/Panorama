//
//  XPlatform.swift
//  Panorama
//
//  Created by Kaz Yoshikawa on 12/25/16.
//  Copyright © 2017 Electricwoods LLC. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

// MARK: - Type Aliases

#if os(iOS)
public typealias XView = UIView
public typealias XImage = UIImage
public typealias XColor = UIColor
public typealias XBezierPath = UIBezierPath
public typealias XScrollView = UIScrollView
public typealias XScrollViewDelegate = UIScrollViewDelegate
public typealias XViewController = UIViewController
public typealias XEvent = UIEvent
public typealias XFont = UIFont

#elseif os(macOS)
public typealias XView = NSView
public typealias XImage = NSImage
public typealias XColor = NSColor
public typealias XBezierPath = NSBezierPath
public typealias XScrollView = NSScrollView
public typealias XViewController = NSViewController
public typealias XEvent = NSEvent
public typealias XFont = NSFont

public protocol XScrollViewDelegate {}

#endif

// MARK: - Cross-Platform Extensions

#if os(macOS)
public extension NSBezierPath {

	func addLine(to point: CGPoint) {
		self.line(to: point)
	}

}
#endif

#if os(iOS)
public extension UIBezierPath {
	func line(to point: CGPoint) {
		self.addLine(to: point)
	}
}
#endif


// MARK: - NSView UIKit Compatibility

#if os(macOS)
public extension NSView {
	/// Marks the receiver's layout as needing an update.
	@objc func setNeedsLayout() {
		self.needsLayout = true
	}
	
	/// Marks the receiver's entire bounds as needing display.
	@objc func setNeedsDisplay() {
		self.setNeedsDisplay(self.bounds)
	}

	/// Moves the specified subview to the back of the view hierarchy.
	@objc func sendSubview(toBack subview: NSView) {
		var subviews = self.subviews
		guard let index = subviews.firstIndex(of: subview) else { return }
		
		subviews.remove(at: index)
		subviews.insert(subview, at: 0)
		self.subviews = subviews
	}
	
	/// Moves the specified subview to the front of the view hierarchy.
	@objc func bringSubview(toFront subview: NSView) {
		var subviews = self.subviews
		guard let index = subviews.firstIndex(of: subview) else { return }
		
		subviews.remove(at: index)
		subviews.append(subview)
		self.subviews = subviews
	}

	// Note: NSView already has replaceSubview(_:with:) method in AppKit
}
#endif


// MARK: - NSImage Extensions

#if os(macOS)
public extension NSImage {
	/// Returns a Core Graphics image representation of the image.
	var cgImage: CGImage? {
		guard let data = self.tiffRepresentation,
		      let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
		      CGImageSourceGetCount(imageSource) > 0 else {
		    return nil
		}
		
		return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
	}
}
#endif

