//
//  TextFieldViewlet_Simple.swift
//  PanoramaApp
//
//  Simplified version for build testing
//

import Foundation
import Panorama
#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

/// A simplified text field viewlet that builds on both platforms
class TextFieldViewlet: Viewlet {
	
	// MARK: - Properties
	
	/// The current text value
	var text: String = "" {
		didSet {
			setNeedsDisplay()
			onTextChange?(text)
		}
	}
	
	/// Placeholder text shown when empty
	var placeholder: String = "" {
		didSet { setNeedsDisplay() }
	}
	
	/// Whether the field has keyboard focus
	var isFocused: Bool = false {
		didSet { setNeedsDisplay() }
	}
	
	/// Whether the field accepts input
	var isEditable: Bool = true
	
	// MARK: - Appearance
	
	var textColor: XColor = .black
	var placeholderColor: XColor = .gray
	var backgroundColor: XColor = .white
	var borderColor: XColor = .lightGray
	var focusedBorderColor: XColor = .blue
	var cornerRadius: CGFloat = 5
	var font: XFont = .systemFont(ofSize: 14)
	
	// MARK: - Callbacks
	
	var onTextChange: ((String) -> Void)?
	var onReturn: (() -> Void)?
	var onFocus: (() -> Void)?
	var onBlur: (() -> Void)?
	
	// MARK: - Methods
	
	func focus() {
		guard isEditable else { return }
		isFocused = true
		onFocus?()
	}
	
	func resignFocus() {
		isFocused = false
		onBlur?()
	}
	
	// MARK: - Drawing
	
	override func draw(in context: CGContext) {
		// Draw background
		context.setFillColor(backgroundColor.cgColor)
#if os(iOS)
		let backgroundPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
		context.addPath(backgroundPath.cgPath)
#else
		let backgroundPath = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
		context.addPath(backgroundPath.cgPath)
#endif
		context.fillPath()
		
		// Draw border
		let borderWidth: CGFloat = isFocused ? 2 : 1
		context.setStrokeColor((isFocused ? focusedBorderColor : borderColor).cgColor)
		context.setLineWidth(borderWidth)
#if os(iOS)
		let borderPath = UIBezierPath(roundedRect: bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2), cornerRadius: cornerRadius)
		context.addPath(borderPath.cgPath)
#else
		let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
		let borderPath = NSBezierPath(roundedRect: borderRect, xRadius: cornerRadius, yRadius: cornerRadius)
		context.addPath(borderPath.cgPath)
#endif
		context.strokePath()
		
		// Draw text or placeholder
		let textToDraw = text.isEmpty ? placeholder : text
		let textColor = text.isEmpty ? placeholderColor : self.textColor
		
		let attributes: [NSAttributedString.Key: Any] = [
			.font: font,
			.foregroundColor: textColor
		]
		
		let attributedString = NSAttributedString(string: textToDraw, attributes: attributes)
		let textRect = bounds.insetBy(dx: 8, dy: 4)
		
		// Draw the text
		context.saveGState()
#if os(iOS)
		UIGraphicsPushContext(context)
		attributedString.draw(in: textRect)
		UIGraphicsPopContext()
#else
		let graphicsContext = NSGraphicsContext(cgContext: context, flipped: true)
		NSGraphicsContext.saveGraphicsState()
		NSGraphicsContext.current = graphicsContext
		attributedString.draw(in: textRect)
		NSGraphicsContext.restoreGraphicsState()
#endif
		context.restoreGState()
		
		// Draw cursor if focused
		if isFocused && !text.isEmpty {
			drawCursor(in: context, at: textRect)
		}
	}
	
	private func drawCursor(in context: CGContext, at textRect: CGRect) {
		// Simple cursor at end of text
		let size = (text as NSString).size(withAttributes: [.font: font])
		let cursorX = textRect.minX + min(size.width, textRect.width - 2)
		let cursorRect = CGRect(x: cursorX, y: textRect.minY, width: 2, height: textRect.height)
		
		context.setFillColor(textColor.cgColor)
		context.fill(cursorRect)
	}
	
	// MARK: - Touch/Mouse Handling
	
	override func singleAction() {
		if isEditable {
			focus()
		}
	}
}
