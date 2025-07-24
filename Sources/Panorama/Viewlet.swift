//
//  Viewlet.swift
//  Panorama
//
//  Created by Kaz Yoshikawa on 1/26/17.
//  Copyright © 2017 Electricwoods LLC. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

// MARK: - Viewlet

/// A lightweight view-like component that uses Core Graphics for rendering.
open class Viewlet {
	
	// MARK: - Alignment Types
	
	public enum HorizontalAlignment: CaseIterable {
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
	
	public enum VerticalAlignment: CaseIterable {
		case top
		case center
		case bottom
	}
	
	// MARK: - Properties
	
	private weak var _parent: Viewlet?
	
	/// The parent viewlet in the hierarchy.
	public var parent: Viewlet? {
		_parent
	}
	
	/// Child viewlets contained within this viewlet.
	public private(set) var subviewlets = [Viewlet]()
	
	private var _bounds: CGRect
	
	/// The bounds rectangle, which describes the viewlet's location and size in its own coordinate system.
	public var bounds: CGRect {
		_bounds
	}
	
	/// The frame rectangle, which describes the viewlet's location and size in its superview's coordinate system.
	public var frame: CGRect {
		get {
		    bounds.applying(transform)
		}
		set {
		    _bounds = CGRect(origin: .zero, size: newValue.size)
		    transform = _bounds.transform(to: newValue)
		}
	}
	
	/// The transform applied to the viewlet relative to its bounds.
	public var transform: CGAffineTransform
	
	/// Indicates whether the viewlet is enabled for interaction.
	public var isEnabled = true
	
	// MARK: - Initialization
	
	public init(frame: CGRect) {
		_bounds = CGRect(origin: .zero, size: frame.size)
		transform = _bounds.transform(to: frame)
	}
	
	// MARK: - Display Management
	
	/// Marks the viewlet as needing display.
	public func setNeedsDisplay() {
		_parent?.setNeedsDisplay()
	}
	
	// MARK: - Viewlet Hierarchy
	
	/// Adds a child viewlet to this viewlet.
	public func addViewlet(_ viewlet: Viewlet) {
		viewlet._parent = self
		subviewlets.append(viewlet)
		setNeedsDisplay()
	}
	
	/// Removes a child viewlet from this viewlet.
	public func removeViewlet(_ viewlet: Viewlet) {
		guard let index = subviewlets.firstIndex(where: { $0 === viewlet }) else { return }
		subviewlets.remove(at: index)
		viewlet._parent = nil
		setNeedsDisplay()
	}
	
	// MARK: - Drawing
	
	final func drawRecursively(in context: CGContext) {
		context.saveGState()
		defer { context.restoreGState() }
		
		draw(in: context)
		
		for viewlet in subviewlets {
		    context.saveGState()
		    context.concatenate(viewlet.transform)
		    viewlet.drawRecursively(in: context)
		    context.restoreGState()
		}
	}
	
	/// Override this method to perform custom drawing.
	open func draw(in context: CGContext) {
		// Default implementation draws nothing
	}
	
	// MARK: - Hit Testing
	
	/// Returns the farthest descendant of the viewlet hierarchy that contains a specified point.
	public func findViewlet(at point: CGPoint) -> Viewlet? {
		let localPoint = point.applying(transform.inverted())
		
		// First check if the point is within our bounds
		guard bounds.contains(localPoint) else {
		    return nil
		}
		
		// Check subviewlets in reverse order (front to back)
		for viewlet in subviewlets.reversed() {
		    // Pass the point in our local coordinate system, not the transformed point
		    if let found = viewlet.findViewlet(at: localPoint) {
		        return found
		    }
		}
		
		// If no subviewlet contains the point, return self
		return self
	}
	
	// MARK: - Coordinate Conversion
	
	/// Returns the panorama that contains this viewlet.
	public var panorama: Panorama? {
		parent?.panorama
	}
	
	/// The transform from this viewlet's coordinate system to the panorama's coordinate system.
	public var transformToPanorama: CGAffineTransform? {
		guard let parentTransform = parent?.transformToPanorama else { return transform }
		return parentTransform.concatenating(transform)
	}
	
	/// The transform from the panorama's coordinate system to this viewlet's coordinate system.
	public var transformFromPanorama: CGAffineTransform? {
		transformToPanorama?.inverted()
	}
	
	// MARK: - Text Drawing
	
	/// Draws attributed text within the specified rectangle.
	public func drawText(
		in context: CGContext,
		rect: CGRect,
		attributedString: NSAttributedString,
		verticalAlignment: VerticalAlignment
	) {
		// Save the current graphics state
		context.saveGState()
		defer { context.restoreGState() }
		
		#if os(macOS)
		// On macOS, use NSAttributedString drawing instead of Core Text
		let nsContext = NSGraphicsContext(cgContext: context, flipped: true)
		NSGraphicsContext.saveGraphicsState()
		NSGraphicsContext.current = nsContext
		
		// Calculate text position based on vertical alignment
		let framesetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
		var fitRange = CFRange()
		let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
		    framesetter,
		    CFRange(),
		    nil,
		    rect.size,
		    &fitRange
		)
		
		let textRect: CGRect
		switch verticalAlignment {
		case .top:
		    textRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: suggestedSize.height)
		case .center:
		    let topMargin = (rect.size.height - suggestedSize.height) * 0.5
		    textRect = CGRect(x: rect.minX, y: rect.minY + topMargin, width: rect.width, height: suggestedSize.height)
		case .bottom:
		    textRect = CGRect(x: rect.minX, y: rect.maxY - suggestedSize.height, width: rect.width, height: suggestedSize.height)
		}
		
		attributedString.draw(in: textRect)
		NSGraphicsContext.restoreGraphicsState()
		return
		#else
		// For iOS, use UIKit's string drawing which handles coordinate systems properly
		// Calculate text size
		let textSize = attributedString.boundingRect(
		    with: rect.size,
		    options: [.usesLineFragmentOrigin, .usesFontLeading],
		    context: nil
		).size
		
		// Calculate text position based on vertical alignment
		let textRect: CGRect
		switch verticalAlignment {
		case .top:
		    textRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: textSize.height)
		case .center:
		    let topMargin = (rect.size.height - textSize.height) * 0.5
		    textRect = CGRect(x: rect.minX, y: rect.minY + topMargin, width: rect.width, height: textSize.height)
		case .bottom:
		    textRect = CGRect(x: rect.minX, y: rect.maxY - textSize.height, width: rect.width, height: textSize.height)
		}
		
		// Use UIKit drawing
		UIGraphicsPushContext(context)
		attributedString.draw(in: textRect)
		UIGraphicsPopContext()
		#endif
	}
	
	// MARK: - Image Drawing
	
	/// Draws an image within the viewlet's bounds using the specified fill mode.
	public func drawImage(
		in context: CGContext,
		image: XImage,
		rect: CGRect,
		mode: ViewletImageFillMode
	) {
		guard let cgImage = image.cgImage else { return }
		
		context.saveGState()
		defer { context.restoreGState() }
		
		context.clip(to: bounds)
		context.translateBy(x: 0, y: bounds.height)
		context.scaleBy(x: 1, y: -1)
		
		let drawRect: CGRect
		switch mode {
		case .fill:
		    drawRect = bounds
		case .aspectFit:
		    drawRect = bounds.aspectFit(image.size)
		case .aspectFill:
		    drawRect = bounds.aspectFill(image.size)
		}
		
		context.draw(cgImage, in: drawRect)
	}
	
	// MARK: - Actions
	
	/// Called when a single tap/click is detected.
	open func singleAction() {}
	
	/// Called when a double tap/click is detected.
	open func doubleAction() {}
	
	/// Called when multiple taps/clicks are detected.
	open func multipleAction(count: Int) {}
	
	/// Called when a long press/hold is detected.
	open func holdAction() {}
	
	// MARK: - Touch Handling (iOS)
	
	#if os(iOS)
	private var tapCount = 0
	private var activeTouch: UITouch?
	private weak var tapTimer: Timer?
	
	func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		tapCount += 1
		tapTimer?.invalidate()
		if touches.count == 1, let touch = touches.first {
		    activeTouch = touch
		}
	}
	
	func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		// Override in subclasses
	}
	
	func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		activeTouch = nil
		tapTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
		    guard let self = self else { return }
		    switch self.tapCount {
		    case 0:
		        break
		    case 1:
		        self.singleAction()
		    case 2:
		        self.doubleAction()
		    default:
		        self.multipleAction(count: self.tapCount)
		    }
		    self.tapCount = 0
		    self.activeTouch = nil
		}
	}
	
	func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		tapTimer?.invalidate()
		tapCount = 0
		activeTouch = nil
	}
	#endif
	
	// MARK: - Mouse Handling (macOS)
	
	#if os(macOS)
	private var clickCount = 0
	private weak var clickTimer: Timer?
	
	func mouseDown(with event: NSEvent) {
		clickTimer?.invalidate()
		clickCount += 1
	}
	
	func mouseDragged(with event: NSEvent) {
		// Override in subclasses
	}
	
	func mouseUp(with event: NSEvent) {
		clickTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
		    guard let self = self else { return }
		    switch self.clickCount {
		    case 0:
		        break
		    case 1:
		        self.singleAction()
		    case 2:
		        self.doubleAction()
		    default:
		        self.multipleAction(count: self.clickCount)
		    }
		    self.clickCount = 0
		}
	}
	
	func mouseMoved(with event: NSEvent) {}
	func rightMouseDown(with event: NSEvent) {}
	func rightMouseDragged(with event: NSEvent) {}
	func rightMouseUp(with event: NSEvent) {}
	func otherMouseDown(with event: NSEvent) {}
	func otherMouseDragged(with event: NSEvent) {}
	func otherMouseUp(with event: NSEvent) {}
	func mouseExited(with event: NSEvent) {}
	func mouseEntered(with event: NSEvent) {}
	#endif
}

// MARK: - ViewletImageFillMode

/// Specifies how an image should be scaled within a viewlet's bounds.
public enum ViewletImageFillMode: CaseIterable {
	/// Scale the image to fill the entire bounds, potentially changing aspect ratio.
	case fill
	/// Scale the image to fit within the bounds while maintaining aspect ratio.
	case aspectFit
	/// Scale the image to fill the bounds while maintaining aspect ratio, potentially cropping.
	case aspectFill
}

// MARK: - LabelViewlet

/// A viewlet that displays text with configurable alignment and styling.
open class LabelViewlet: Viewlet {
	
	// MARK: - Properties
	
	/// The text to display.
	public var text: String?
	
	/// The horizontal alignment of the text.
	public var horizontalAlignment: Viewlet.HorizontalAlignment = .center
	
	/// The vertical alignment of the text.
	public var verticalAlignment: Viewlet.VerticalAlignment = .center
	
	/// Text attributes for styling.
	public var textAttributes: [NSAttributedString.Key: Any] = [:]
	
	/// The default font for labels.
	public static var defaultFont: XFont {
		XFont.systemFont(ofSize: 12)
	}
	
	// MARK: - Computed Properties
	
	private var paragraphStyle: NSParagraphStyle {
		let style = NSMutableParagraphStyle()
		style.alignment = horizontalAlignment.textAlignment
		return style
	}
	
	private var attributes: [NSAttributedString.Key: Any] {
		var attrs = textAttributes
		attrs[.paragraphStyle] = paragraphStyle
		attrs[.font] = attrs[.font] ?? Self.defaultFont
		return attrs
	}
	
	// MARK: - Drawing
	
	public override func draw(in context: CGContext) {
		guard let text = text else { return }
		
		let attributedString = NSAttributedString(string: text, attributes: attributes)
		drawText(
		    in: context,
		    rect: bounds,
		    attributedString: attributedString,
		    verticalAlignment: verticalAlignment
		)
	}
}

// MARK: - TextViewlet

/// A viewlet that displays attributed text.
open class TextViewlet: Viewlet {
	
	/// The attributed string to display.
	public var attributedString: NSAttributedString?
	
	/// The vertical alignment of the text.
	public var verticalAlignment: Viewlet.VerticalAlignment = .center
	
	public override func draw(in context: CGContext) {
		guard let attributedString = attributedString else { return }
		
		drawText(
		    in: context,
		    rect: bounds,
		    attributedString: attributedString,
		    verticalAlignment: verticalAlignment
		)
	}
}

// MARK: - ImageViewlet

/// A viewlet that displays an image.
open class ImageViewlet: Viewlet {
	
	/// The image to display.
	public var image: XImage?
	
	/// The fill mode for the image.
	public var fillMode: ViewletImageFillMode = .aspectFill
	
	public init(frame: CGRect, image: XImage? = nil) {
		self.image = image
		super.init(frame: frame)
	}
	
	public override func draw(in context: CGContext) {
		guard let image = image else { return }
		
		drawImage(
		    in: context,
		    image: image,
		    rect: bounds,
		    mode: fillMode
		)
	}
}