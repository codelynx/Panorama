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
import AppKit
#endif
import Panorama


class MyViewlet: Viewlet {

	var color: XColor
	var name: String

	init(frame: CGRect, color: XColor, name: String) {
		self.color = color
		self.name = name
		super.init(frame: frame)
	}

	override func draw(in context: CGContext) {
		context.setFillColor(self.color.cgColor)
		context.fillEllipse(in: self.bounds)
	}
	
}


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
	
	
	override func didMove(to panoramaView: PanoramaView?) {
		
		let viewlet1 = MyViewlet(frame: CGRect(x: 0, y: 0, width: 1024, height: 1024), color: XColor.orange.withAlphaComponent(0.5), name: "1")
		let viewlet2 = MyViewlet(frame: CGRect(x: 256, y: 256, width: 512, height: 512), color: XColor.blue.withAlphaComponent(0.5), name: "2")
		viewlet1.addViewlet(viewlet2)

		let viewlet3 = ButtonViewlet(frame: CGRect(x: 128, y: 128, width: 256, height: 256))
		viewlet2.addViewlet(viewlet3)

		self.addViewlet(viewlet1)
	}

	//	iOS
/*
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
*/
	//	macOS

/*
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
*/
}
