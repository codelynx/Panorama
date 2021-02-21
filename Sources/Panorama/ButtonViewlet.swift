//
//	ButtonViewlet.swift
//	Panorama
//
//	Created by Kaz Yoshikawa on 1/30/17.
//	Copyright © 2017 Electricwoods LLC., Kaz Yoshikawa. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif


open class ButtonViewlet: Viewlet {

	var state: ViewletState = .normal { didSet { self.setNeedsDisplay() } }

	var title: String? { didSet { self.setNeedsDisplay() } }
	var style: ViewletStyle? = ButtonViewlet.defaultStyle

	var foregroundColors: [ViewletState: XColor] = [:]
	var backgroundFills: [ViewletState: ViewletFill] = [:]

	func foregroundColor(for state: ViewletState) -> XColor {
		if let color = self.foregroundColors[state] { return color }
		if let color = self.style?.foregroundColor(for: state) { return color }
		return XColor.white
	}

	func backgroundFill(for state: ViewletState) -> ViewletFill? {
		if let fill = self.backgroundFills[state] { return fill }
		if let fill = self.style?.backgroundFill(for: state) { return fill }
		return ViewletFill.solid(XColor.blue)
	}

	static var normalForegroundColor: XColor = XColor.white
	static var highlightedForegroundColor: XColor = XColor.white
	static var selectedForegroundColor: XColor = XColor.white

	static var normalBackgroundFill: ViewletFill = ViewletFill.solid(XColor.blue)
	static var highlightedBackgroundFill: ViewletFill = ViewletFill.solid(XColor.cyan)
	static var selectedBackgroundFill: ViewletFill = ViewletFill.none

	private var _cornerRadius: CGFloat? { didSet { self.setNeedsDisplay() } }
	var cornerRadius: CGFloat? {
		get {
			guard let cornerRadius = _cornerRadius else { return nil }
			let halfwidth = self.bounds.size.width * 0.5
			let halfheight = self.bounds.size.height * 0.5
			return min(max(halfwidth, halfheight), cornerRadius)
		}
		set { _cornerRadius = newValue }
	}

	#if os(iOS)
	var activeTouches = Set<UITouch>()

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		activeTouches.formUnion(touches)
		self.state = .highlighted
		self.setNeedsDisplay()
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.setNeedsDisplay()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		activeTouches.subtract(touches)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) { // otherwise, may be too fast to see
			self.state = .normal
		}
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		activeTouches.subtract(touches)
		self.state = .normal
	}
	#endif

	#if os(macOS)
	open override func mouseDown(with event: NSEvent) {
		self.state = .highlighted
	}

	open override func mouseDragged(with event: NSEvent) {
		self.setNeedsDisplay()
	}
	
	open override func mouseUp(with event: NSEvent) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) { // otherwise, may not able to see
			self.state = .normal
		}
	}
	#endif

	// MARK: -

	open override func draw(in context: CGContext) {
		if let cornerRadius = cornerRadius {
			let path = self.bounds.cgPath(cornerRadius: cornerRadius)
			context.addPath(path)
			context.clip(using: .evenOdd)
		}
		else {
			context.clip(to: self.bounds)
		}

		// background
		let backgroundFill = self.backgroundFill(for: self.state)
		backgroundFill?.fill(rect: self.bounds, context: context)

		// title
		guard let title = self.title else { return }
		let attributes: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.foregroundColor: self.foregroundColor(for: self.state),
			NSAttributedString.Key.paragraphStyle: self.paragraphStyle,
			NSAttributedString.Key.font: style?.font ?? ButtonViewlet.defaultFont
		]
		
		let attributedString = NSAttributedString(string: title, attributes: attributes)
		self.drawText(in: context, rect: self.bounds.insetBy(dx: 8, dy: 8), attributedString: attributedString, verticalAlignment: .center)

	}
	
	class var defaultFont: XFont {
		return XFont.systemFont(ofSize: 14)
	}

	var paragraphStyle: NSParagraphStyle {
		let style = NSMutableParagraphStyle(NSParagraphStyle.default)
		style.alignment = NSTextAlignment.center
		return style
	}

	static var defaultStyle: ViewletStyle = {
		let style = ViewletStyle()
		let backgroundGardient = Gradient(locations: [(0, XColor.cyan), (1, XColor.blue)])!
		let highlightedGardient = Gradient(locations: [(0, XColor.yellow), (1, XColor.red)])!

		style.foregroundColors = [.normal: XColor.white, .highlighted: XColor.white]
		style.backgroundFills = [.normal: ViewletFill.none, .highlighted: ViewletFill.none]

		style.font = ButtonViewlet.defaultFont
		return style
	}()

}
