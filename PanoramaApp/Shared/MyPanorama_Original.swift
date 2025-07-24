//
//  MyPanorama_Original.swift
//  Panorama
//
//  Backup of original MyPanorama.swift without new viewlets
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
		// Draw background
		#if os(iOS)
		context.setFillColor(XColor.systemGray6.cgColor)
		#else
		context.setFillColor(XColor.windowBackgroundColor.cgColor)
		#endif
		context.fill(bounds)
		
		// Draw paths
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
		super.didMove(to: panoramaView)
		
		// Simple viewlet examples
		let viewlet1 = MyViewlet(frame: CGRect(x: 100, y: 100, width: 400, height: 400), color: XColor.orange.withAlphaComponent(0.5), name: "1")
		let viewlet2 = MyViewlet(frame: CGRect(x: 100, y: 100, width: 200, height: 200), color: XColor.blue.withAlphaComponent(0.5), name: "2")
		viewlet1.addViewlet(viewlet2)

		let viewlet3 = ButtonViewlet(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
		viewlet3.title = "Click"
		viewlet2.addViewlet(viewlet3)

		self.addViewlet(viewlet1)
		
		// Add some labels
		setupSimpleLabels()
	}
	
	private func setupSimpleLabels() {
		// Title label
		let titleLabel = LabelViewlet(frame: CGRect(x: 300, y: 50, width: 400, height: 40))
		titleLabel.text = "Panorama Example App"
		titleLabel.horizontalAlignment = .center
		titleLabel.textAttributes = [
			.font: XFont.boldSystemFont(ofSize: 24),
			.foregroundColor: XColor.black
		]
		addViewlet(titleLabel)
		
		// Info labels
		let infoLabel = LabelViewlet(frame: CGRect(x: 300, y: 100, width: 400, height: 30))
		infoLabel.text = "New viewlets will be added when files are included in Xcode project"
		infoLabel.horizontalAlignment = .center
		infoLabel.textAttributes = [
			.font: XFont.systemFont(ofSize: 16),
			.foregroundColor: XColor.darkGray
		]
		addViewlet(infoLabel)
	}
}