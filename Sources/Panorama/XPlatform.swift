//
//	CrossPlatform.swift
//	Silvershadow
//
//	Created by Kaz Yoshikawa on 12/25/16.
//	Copyright © 2017 Electricwoods LLC. All rights reserved.
//

import Foundation


#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif



#if os(iOS)

import UIKit
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

import Cocoa
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



#if os(macOS)
public extension NSBezierPath {

	func addLine(to point: CGPoint) { self.line(to: point) }

}
#endif

#if os(iOS)
public extension UIBezierPath {

	func line(to point: CGPoint) { self.addLine(to: point) }

}
#endif


#if os(macOS)
public extension NSView {

	@objc func setNeedsLayout() {
		self.layout()
	}
	
	@objc func setNeedsDisplay() {
		self.setNeedsDisplay(self.bounds)
	}

	@objc func sendSubview(toBack: NSView) {
		var subviews = self.subviews
		if let index = subviews.firstIndex(of: toBack) {
			subviews.remove(at: index)
			subviews.insert(toBack, at: 0)
			self.subviews = subviews
		}
	}
	
	@objc func bringSubview(toFront: NSView) {
		var subviews = self.subviews
		if let index = subviews.firstIndex(of: toFront) {
			subviews.remove(at: index)
			subviews.append(toFront)
			self.subviews = subviews
		}
	}

	@objc func replaceSubview(subview: NSView, with other: NSView) {
		var subviews = self.subviews
		if let index = subviews.firstIndex(of: subview) {
			subviews.remove(at: index)
			subviews.insert(other, at: index)
			self.subviews = subviews
		}
	}
}
#endif


#if os(macOS)
public extension NSImage {

	// somehow OSX does not provide CGImage property
	var cgImage: CGImage? {
		if let data = self.tiffRepresentation,
		   let imageSource = CGImageSourceCreateWithData(data as CFData, nil) {
			if CGImageSourceGetCount(imageSource) > 0 {
				return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
			}
		}
		return nil
	}

}
#endif

#if os(macOS)
public extension NSString {
	/* Method 'sizeWithAttributes' with Objective-C selector 'sizeWithAttributes:' conflicts with method 'size(withAttributes:)' with the same Objective-C selector
	func size(attributes: [String : Any]? = nil) -> CGSize {
		return self.size(withAttributes: attributes)
	}
	*/
}
#endif

