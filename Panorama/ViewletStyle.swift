//
//  ViewletStyle.swift
//  Panorama
//
//  Created by Kaz Yoshikawa on 1/29/17.
//  Copyright © 2017 Electricwoods LLC., Kaz Yoshikawa. All rights reserved.
//

import Foundation


#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif


//
//	ViewletState
//

public enum ViewletState {
	case normal
	case highlighted
}

//
//	ViewletFill
//

public enum ViewletFill {

	enum GradientType {
		case horizontal
		case vertical
	}

	case none
	case solid(XColor)
	case gradient(CGPoint, CGPoint, Gradient) // normalized: 0.0 ~ 1.0

	func fill(rect: CGRect, context: CGContext) {
		switch self {
		case .none:
			break
		case .solid(let color):
			context.setFillColor(color.cgColor)
			context.fill(rect)
		case .gradient(let startPt, let endPt, let gradient):
			let colorspace = CGColorSpaceCreateDeviceRGB()
			let colors: [CGColor] = gradient.locations.map { $0.1.cgColor }
			var locations: [CGFloat] = gradient.locations.map { $0.0 }
			guard let gradient = CGGradient(colorsSpace: colorspace, colors: colors as CFArray, locations: &locations) else { return }
			let transform = CGRect(x: 0, y: 0, width: 1, height: 1).transform(to: rect)
			context.drawLinearGradient(gradient, start: startPt.applying(transform), end: endPt	.applying(transform), options: [])
		}
	}
	
	static func linearGradient(_ type: GradientType, colors: [XColor]) -> ViewletFill {
		assert(colors.count >= 2)
		let gradient = Gradient(colors: colors)!
		let (startPt, endPt): (CGPoint, CGPoint) = {
			switch type {
			case .horizontal: return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
			case .vertical: return (CGPoint(x: 0.5, y: 0.0), CGPoint(x: 0.5, y: 1.0))
			}
		}()
		return ViewletFill.gradient(startPt, endPt, gradient)
	}
}

//
//	ViewletStyle
//

class ViewletStyle {
	var name: String?
	weak var superStyle: ViewletStyle?

	var foregroundColors: [ViewletState: XColor] = [:]
	var backgroundFills: [ViewletState: ViewletFill] = [:]

	func foregroundColor(for state: ViewletState) -> XColor? {
		if let color = self.foregroundColors[state] { return color }
		if let superStyle = self.superStyle { return superStyle.foregroundColor(for: state) }
		return nil
	}

	func backgroundFill(for state: ViewletState) -> ViewletFill? {
		if let fill = self.backgroundFills[state] { return fill }
		if let superStyle = self.superStyle { return superStyle.backgroundFill(for: state) }
		return nil
	}

	var cornerRadius: CGFloat?
	var font: XFont?
	var alignment: NSTextAlignment?

}

//
//	Gradient
//

open class Gradient {

	private (set) var locations = [(CGFloat, XColor)]()
	
	init?(locations: [(CGFloat, XColor)]) {
		// first must be 0, last must be 1
		if let first = locations.first, let last = locations.last, first.0 == 0, last.0 == 1 {
			self.locations = locations
			return
		}
		return nil
	}

	init?(colors: [XColor]) {
		if colors.count < 2 { return nil }
		self.locations = colors.enumerated().map { (CGFloat($0.offset) / CGFloat(colors.count), $0.element) }
	}

	init(_ color1: XColor, _ color2: XColor, _ color3: XColor, _ color4: XColor) {
		self.locations = [(0.0, color1), (0.5, color2), (0.5, color3), (1.0, color4)]
	}

	var reversed: Gradient {
		let locations: [(CGFloat, XColor)] = zip(self.locations.reversed(), self.locations).map { ($0.1.0, $0.0.1) }
		return Gradient(locations: locations)!
	}
	
}
