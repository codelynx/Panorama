//
//	Drawable.swift
//	Panorama
//
//	Created by Kaz Yoshikawa on 1/26/17.
//	Copyright © 2017 Electricwoods LLC.  Kaz Yoshikawa. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif



open class Viewlet {

	public enum HorizontalAlignment {
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
	
	public enum VerticalAlignment {
		case top
		case center
		case bottom
	}

	weak var _parent: Viewlet?

	open var parent: Viewlet? {
		get { return _parent }
	}
	open var subviewlets = [Viewlet]()

	private var _bounds: CGRect
	open var bounds: CGRect { return _bounds }

	open var frame: CGRect {
		get { return self.bounds.applying(transform) }
		set {
			_bounds = CGRect(origin: CGPoint.zero, size: newValue.size)
			transform = _bounds.transform(to: newValue)
		}
	}
	open var transform: CGAffineTransform

	public init(frame: CGRect) {
		_bounds = CGRect(origin: CGPoint.zero, size: frame.size)
		transform = _bounds.transform(to: frame)
	}

	open func setNeedsDisplay() {
		_parent?.setNeedsDisplay()
	}

	open func addViewlet(_ viewlet: Viewlet) {
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
	
	open func draw(in context: CGContext) {
	}

	// MARK: -

	open func findViewlet(point: CGPoint) -> Viewlet? {
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

	open var panorama: Panorama? {
		return self.parent?.panorama
	}

	open var transformToPanorama: CGAffineTransform? {
		return self.parent?.transformToPanorama?.concatenating(self.transform)
	}

	open var transformFromPanorama: CGAffineTransform? {
		return self.transformToPanorama?.inverted()
	}

	// MARK: -

	open func drawText(in context: CGContext, rect: CGRect, attributedString: NSAttributedString, verticalAlignment: VerticalAlignment ) {
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

	open func drawImage(in context: CGContext, image: XImage, rect: CGRect, mode: ViewletImageFillMode) {
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

	open var enabled: Bool = true

	// MARK: -

	open func singleAction() {
	}
	
	open func doubleAction() {
	}

	open func multipleAction(count: Int) {
	}

	open func holdAction() {
	}

	// MARK: -

	#if os(iOS)
	open var tapCount: Int = 0
	private var activeTouch: UITouch? // multi-touch may be taken by scroll-view
	private weak var timer: Timer?
	
	open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.tapCount += 1
		self.timer?.invalidate()
		if let touch = touches.first, touches.count == 1 {
			self.activeTouch = touch
		}
	}

	open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
	}
	
	open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.activeTouch = nil
		self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(Self.touchTimerFired(_:)), userInfo: nil, repeats: false)
	}
	
	open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.timer?.invalidate()
		self.tapCount = 0
		self.activeTouch = nil
	}
	
	@objc private func touchTimerFired(_ timer: Timer) {
		switch self.tapCount {
		case 0: break
		case 1: self.singleAction()
		case 2: self.doubleAction()
		default: self.multipleAction(count: self.tapCount)
		}
		self.tapCount = 0
		self.activeTouch = nil
	}
	#endif

	#if os(macOS)
	open func touchesBegan(with event: NSEvent) {
	}

	open func touchesMoved(with event: NSEvent) {
	}

	open func touchesEnded(with event: NSEvent) {
	}

	open func touchesCancelled(with event: NSEvent) {
	}
	#endif

	#if os(macOS)
	open var clickCount: Int = 0
	open weak var timer: Timer?

	open func mouseDown(with event: NSEvent) {
		self.timer?.invalidate()
		self.clickCount += 1
	}

	open func mouseDragged(with event: NSEvent) {
	}
	
	open func mouseUp(with event: NSEvent) {
		self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(Self.mouseTimerFired(_:)), userInfo: nil, repeats: false)
	}

	open func mouseMoved(with event: NSEvent) {
	}
	
	open func rightMouseDown(with event: NSEvent) {
	}
	
	open func rightMouseDragged(with event: NSEvent) {
	}
	
	open func rightMouseUp(with event: NSEvent) {
	}
	
	open func otherMouseDown(with event: NSEvent) {
	}
	
	open func otherMouseDragged(with event: NSEvent) {
	}
	
	open func otherMouseUp(with event: NSEvent) {
	}
	
	open func mouseExited(with event: NSEvent) {
	}
	
	open func mouseEntered(with event: NSEvent) {
	}

	@objc private func mouseTimerFired(_ timer: Timer) {
		switch self.clickCount {
		case 0: break
		case 1: self.singleAction()
		case 2: self.doubleAction()
		default: self.multipleAction(count: self.clickCount)
		}
		self.clickCount = 0
	}
	#endif
}


// MARK: -



open class LabelViewlet: Viewlet {

	open var text: String?
	open var horizontalAlignment: Viewlet.HorizontalAlignment = .center
	open var verticalAlignment: Viewlet.VerticalAlignment = .center
	private var _attributes: [NSAttributedString.Key: Any] = [:]

	open var textAlignment: NSTextAlignment {
		switch horizontalAlignment {
		case .left: return .left
		case .center: return .center
		case .right: return .right
		}
	}

	class var defaultFont: XFont {
		return XFont.systemFont(ofSize: 12)
	}

	open var paragraphStyle: NSParagraphStyle {
		let style = NSMutableParagraphStyle(NSParagraphStyle.default)
		style.alignment = self.textAlignment
		return style
	}

	open var attribute: [NSAttributedString.Key: Any] {
		var attributes = _attributes // copy
		attributes[NSAttributedString.Key.paragraphStyle] = self.paragraphStyle
		attributes[NSAttributedString.Key.font] = LabelViewlet.defaultFont
		return attributes
	}

	open override func draw(in context: CGContext) {
		guard let text = self.text else { return }
		let attributes = self.attribute
		let attributedString = NSAttributedString(string: text, attributes: attributes)
		self.drawText(in: context, rect: self.bounds, attributedString: attributedString, verticalAlignment: self.verticalAlignment)
	}


}

// MARK: -

open class TextViewlet: Viewlet {

	open var verticalAlignment: Viewlet.VerticalAlignment = .center
	open var attributedString: NSAttributedString?

	open override func draw(in context: CGContext) {
		guard let attributedString = self.attributedString else { return }
		self.drawText(in: context, rect: self.bounds, attributedString: attributedString, verticalAlignment: self.verticalAlignment)
	}

	open override func singleAction() {
		print("single action!")
	}

	open override func doubleAction() {
		print("doubleAction action!")
	}

	open override func multipleAction(count: Int) {
		print("multipleAction!")
	}
}

public enum ViewletImageFillMode {
	case fill
	case aspectFit
	case aspectFill
}


open class ImageViewlet: Viewlet {

	var image: XImage?
	var mode: ViewletImageFillMode = .aspectFill

	init(frame: CGRect, image: XImage) {
		self.image = image
		super.init(frame: frame)
	}

	open override func draw(in context: CGContext) {
		guard let image = self.image else { return }
		self.drawImage(in: context, image: image, rect: self.bounds, mode: self.mode)
	}

}



