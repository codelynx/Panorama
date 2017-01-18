//
//  MyPanorama.swift
//  Panorama
//
//  Created by Kaz Yoshikawa on 1/18/17.
//
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif



class MyPanorama: Panorama {

	var bezierPaths = [XBezierPath]()
	
	#if os(iOS)
	var activePathDict = [UITouch: XBezierPath]()
	#endif

	#if os(macOS)
	var activePath: XBezierPath?
	#endif

	override func draw(in context: CGContext) {
		for path in self.bezierPaths {
			XColor.blue.set()
			path.stroke()
		}
		#if os(iOS)
		for (_, path) in self.activePathDict {
			XColor.red.set()
			path.stroke()
		}
		#elseif os(macOS)
		if let activePath = activePath {
			XColor.red.set()
			activePath.stroke()
		}
		#endif
	}

	//	iOS

	#if os(iOS)
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let path = XBezierPath()
			if let location = touch.location(in: self) {
				path.move(to: location)
				activePathDict[touch] = path
			}
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let path = self.activePathDict[touch], let location = touch.location(in: self) {
				path.addLine(to: location)
				self.setNeedsDisplay()
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let path = self.activePathDict[touch], let location = touch.location(in: self) {
				path.addLine(to: location)
				self.activePathDict[touch] = nil
				self.bezierPaths.append(path)
				self.setNeedsDisplay()
			}
		}
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			self.activePathDict[touch] = nil
			self.setNeedsDisplay()
		}
	}
	#endif

	//	macOS

	#if os(macOS)
	override func mouseDown(with event: NSEvent) {
		if let location = event.location(in: self) {
			let path = XBezierPath()
			path.move(to: location)
			self.activePath = path
		}
	}

	override func mouseDragged(with event: NSEvent) {
		if let activePath = self.activePath, let location = event.location(in: self) {
			activePath.addLine(to: location)
			self.setNeedsDisplay()
		}
	}
	
	override func mouseUp(with event: NSEvent) {
		if let activePath = self.activePath, let location = event.location(in: self) {
			activePath.addLine(to: location)
			self.bezierPaths.append(activePath)
		}
		self.activePath = nil
		self.setNeedsDisplay()
	}
	#endif
}
