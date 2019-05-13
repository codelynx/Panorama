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
typealias XView = UIView
typealias XImage = UIImage
typealias XColor = UIColor
typealias XBezierPath = UIBezierPath
typealias XScrollView = UIScrollView
typealias XScrollViewDelegate = UIScrollViewDelegate
typealias XViewController = UIViewController
typealias XEvent = UIEvent
typealias XFont = UIFont

#elseif os(macOS)

import Cocoa
typealias XView = NSView
typealias XImage = NSImage
typealias XColor = NSColor
typealias XBezierPath = NSBezierPath
typealias XScrollView = NSScrollView
typealias XViewController = NSViewController
typealias XEvent = NSEvent
typealias XFont = NSFont

protocol XScrollViewDelegate {}

#endif



#if os(macOS)
extension NSBezierPath {

	func addLine(to point: CGPoint) { self.line(to: point) }

}
#endif

#if os(iOS)
extension UIBezierPath {

	func line(to point: CGPoint) { self.addLine(to: point) }

}
#endif


#if os(macOS)
extension NSView {

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
extension NSImage {

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
extension NSString {
	/* Method 'sizeWithAttributes' with Objective-C selector 'sizeWithAttributes:' conflicts with method 'size(withAttributes:)' with the same Objective-C selector
	func size(attributes: [String : Any]? = nil) -> CGSize {
		return self.size(withAttributes: attributes)
	}
	*/
}
#endif

