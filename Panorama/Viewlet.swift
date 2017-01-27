//
//  Drawable.swift
//  BookStudio
//
//  Created by Kaz Yoshikawa on 1/26/17.
//  Copyright © 2017 Electricwoods LLC.  Kaz Yoshikawa. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif



class Viewlet {

	enum HorizontalAlignment {
		case left
		case center
		case right
		
		var textAlignment: NSTextAlignment {
			switch self {
			case .left: return .left
			case .center: return .center
			case .right: return .right
			}
		}
	}
	
	enum VerticalAlignment {
		case top
		case center
		case bottom
	}

	weak var _parent: Viewlet?

	var parent: Viewlet? {
		get { return _parent }
	}
	var subviewlets = [Viewlet]()

	private var _bounds: CGRect
	var bounds: CGRect { return _bounds }

	var frame: CGRect {
		get { return self.bounds.applying(transform) }
		set {
			_bounds = CGRect(origin: CGPoint.zero, size: newValue.size)
			transform = _bounds.transform(to: newValue)
		}
	}
	var transform: CGAffineTransform

	init(frame: CGRect) {
		_bounds = CGRect(origin: CGPoint.zero, size: frame.size)
		transform = _bounds.transform(to: frame)
	}

	func setNeedsDisplay() {
		_parent?.setNeedsDisplay()
	}

	func addViewlet(_ viewlet: Viewlet) {
		viewlet._parent = self
		self.subviewlets.append(viewlet)
		self.setNeedsDisplay()
	}

	final func drawRecursively(in context: CGContext) {
		context.saveGState()
		XColor.lightGray.set()
		context.stroke(self.bounds)
		self.draw(in: context)
		context.restoreGState()

		for viewlet in self.subviewlets {
			context.saveGState()
			context.concatenate(viewlet.transform)
			viewlet.drawRecursively(in: context)
			context.restoreGState()
		}
	}
	
	func draw(in context: CGContext) {
	}

	// MARK: -

	func findViewlet(point: CGPoint) -> Viewlet? {
		let point = point.applying(self.transform.inverted())
		for viewlet in self.subviewlets {
			if let viewlet = viewlet.findViewlet(point: point) {
				return viewlet
			}
		}
		if self.bounds.contains(point) { return self }
		else { return nil }
	}

	// MARK: -

	var panorama: Panorama? {
		return self.parent?.panorama
	}

	var transformToPanorama: CGAffineTransform? {
		return self.parent?.transformToPanorama?.concatenating(self.transform)
	}

	var transformFromPanorama: CGAffineTransform? {
		return self.transformToPanorama?.inverted()
	}

	// MARK: -

	func drawText(in context: CGContext, rect: CGRect, attributedString: NSAttributedString, verticalAlignment: VerticalAlignment ) {
		// prepare for Core Text
		context.translateBy(x: 0, y: self.bounds.height)
		context.scaleBy(x: 1, y: -1)

		let framesetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
		var fitRange = CFRangeMake(0, 0)
		let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(), nil, self.bounds.size, &fitRange)
		let textRect: CGRect
		switch verticalAlignment {
		case .top:
			(textRect, _) = rect.divided(atDistance: size.height, from: .maxYEdge)
		case .center:
			let topMargin = (rect.size.height - size.height) * 0.5
			let (_, rect2) = rect.divided(atDistance: topMargin, from: .minYEdge)
			(textRect, _) = rect2.divided(atDistance: size.height, from: .minYEdge)
		case .bottom:
			(textRect, _) = rect.divided(atDistance: size.height, from: .minYEdge)
		}

		let path = CGPath(rect: textRect, transform: nil)
		let frameAttributes: CFDictionary? = nil
		let frame = CTFramesetterCreateFrame(framesetter, fitRange, path, frameAttributes)
		CTFrameDraw(frame, context)
		
	}

	func drawImage(in context: CGContext, image: XImage, rect: CGRect, mode: ViewletImageFillMode) {
		guard let cgImage = image.cgImage else { return }

		context.clip(to: self.bounds)
		context.translateBy(x: 0, y: self.bounds.height)
		context.scaleBy(x: 1, y: -1)
		
		switch mode {
		case .fill: context.draw(cgImage, in: self.bounds)
		case .aspectFit: context.draw(cgImage, in: self.bounds.aspectFit(image.size))
		case .aspectFill: context.draw(cgImage, in: self.bounds.aspectFill(image.size))
		}
	}

	var enabled: Bool = true

	// MARK: -

	func singleAction() {
	}
	
	func doubleAction() {
	}

	func multipleAction(count: Int) {
	}

	func holdAction() {
	}

	// MARK: -

	#if os(iOS)
	var tapCount: Int = 0
	var activeTouch: UITouch? // multi-touch may be taken by scroll-view
	weak var timer: Timer?
	
	func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.tapCount += 1
		self.timer?.invalidate()
		if let touch = touches.first, touches.count == 1 {
			self.activeTouch = touch
		}
	}

	func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
	}
	
	func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.activeTouch = nil
		self.timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
			switch self.tapCount {
			case 0: break
			case 1: self.singleAction()
			case 2: self.doubleAction()
			default: self.multipleAction(count: self.tapCount)
			}
			self.tapCount = 0
			self.activeTouch = nil
		}
	}
	
	func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.timer?.invalidate()
		self.tapCount = 0
		self.activeTouch = nil
	}
	#endif

	#if os(macOS)

	func touchesBegan(with event: NSEvent) {
	}

	func touchesMoved(with event: NSEvent) {
	}

	func touchesEnded(with event: NSEvent) {
	}

	func touchesCancelled(with event: NSEvent) {
	}
	#endif

	#if os(macOS)
	var clickCount: Int = 0
	weak var timer: Timer?

	func mouseDown(with event: NSEvent) {
		self.timer?.invalidate()
		self.clickCount += 1
	}

	func mouseDragged(with event: NSEvent) {
	}
	
	func mouseUp(with event: NSEvent) {
		self.timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
			switch self.clickCount {
			case 0: break
			case 1: self.singleAction()
			case 2: self.doubleAction()
			default: self.multipleAction(count: self.clickCount)
			}
			self.clickCount = 0
		}
	}

	func mouseMoved(with event: NSEvent) {
	}
	
	func rightMouseDown(with event: NSEvent) {
	}
	
	func rightMouseDragged(with event: NSEvent) {
	}
	
	func rightMouseUp(with event: NSEvent) {
	}
	
	func otherMouseDown(with event: NSEvent) {
	}
	
	func otherMouseDragged(with event: NSEvent) {
	}
	
	func otherMouseUp(with event: NSEvent) {
	}
	
	func mouseExited(with event: NSEvent) {
	}
	
	func mouseEntered(with event: NSEvent) {
	}
	#endif
}


// MARK: -



class LabelViewlet: Viewlet {

	var text: String?
	var horizontalAlignment: Viewlet.HorizontalAlignment = .center
	var verticalAlignment: Viewlet.VerticalAlignment = .center
	var _attributes: [String: Any] = [:]

	var textAlignment: NSTextAlignment {
		switch horizontalAlignment {
		case .left: return .left
		case .center: return .center
		case .right: return .right
		}
	}

	class var defaultFont: XFont {
		return XFont.systemFont(ofSize: 12)
	}

	var paragraphStyle: NSParagraphStyle {
		#if os(iOS)
		let style = NSMutableParagraphStyle(NSParagraphStyle.default)
		#elseif os(macOS)
		let style = NSMutableParagraphStyle(NSParagraphStyle.default())
		#endif
		style.alignment = self.textAlignment
		return style
	}

	var attribute: [String: Any] {
		var attributes = _attributes // copy
		attributes[NSParagraphStyleAttributeName] = self.paragraphStyle
		attributes[NSFontAttributeName] = LabelViewlet.defaultFont
		return attributes
	}

	override func draw(in context: CGContext) {
		guard let text = self.text else { return }
		let attributes = self.attribute
		let attributedString = NSAttributedString(string: text, attributes: attributes)
		self.drawText(in: context, rect: self.bounds, attributedString: attributedString, verticalAlignment: self.verticalAlignment)
	}


}

// MARK: -

class TextViewlet: Viewlet {

	var verticalAlignment: Viewlet.VerticalAlignment = .center
	var attributedString: NSAttributedString?

	override func draw(in context: CGContext) {
		guard let attributedString = self.attributedString else { return }
		self.drawText(in: context, rect: self.bounds, attributedString: attributedString, verticalAlignment: self.verticalAlignment)
	}

	override func singleAction() {
		print("single action!")
	}

	override func doubleAction() {
		print("doubleAction action!")
	}

	override func multipleAction(count: Int) {
		print("multipleAction!")
	}
}

enum ViewletImageFillMode {
	case fill
	case aspectFit
	case aspectFill
}


class ImageViewlet: Viewlet {

	var image: XImage?
	var mode: ViewletImageFillMode = .aspectFill

	init(frame: CGRect, image: XImage) {
		self.image = image
		super.init(frame: frame)
	}

	override func draw(in context: CGContext) {
		guard let image = self.image else { return }
		self.drawImage(in: context, image: image, rect: self.bounds, mode: self.mode)
	}

}



