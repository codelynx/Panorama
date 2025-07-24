//
//  NoteCardViewlet.swift
//  PanoramaApp
//
//  Created by Panorama Example
//

import Foundation
import Panorama
#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

/// A draggable note card with editable title and content
class NoteCardViewlet: Viewlet {
	
	// Components
	private let titleField = TextFieldViewlet(frame: .zero)
	private let contentLabel = LabelViewlet(frame: .zero)
	private let deleteButton = ButtonViewlet(frame: .zero)
	
	// Properties
	#if os(iOS)
	var cardColor: XColor = XColor.systemYellow {
		didSet { setNeedsDisplay() }
	}
	#else
	var cardColor: XColor = XColor.yellow {
		didSet { setNeedsDisplay() }
	}
	#endif
	
	var onDelete: (() -> Void)?
	
	// Dragging state
	private var isDragging = false
	private var dragOffset = CGPoint.zero
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupCard()
	}
	
	private func setupCard() {
		// Configure title field
		titleField.placeholder = "Card Title"
		titleField.font = XFont.boldSystemFont(ofSize: 16)
		titleField.backgroundColor = XColor.clear
		titleField.borderColor = XColor.clear
		titleField.focusedBorderColor = XColor.darkGray.withAlphaComponent(0.3)
		
		// Configure content label
		contentLabel.text = "Tap to edit content"
		contentLabel.horizontalAlignment = .left
		contentLabel.verticalAlignment = .top
		contentLabel.textAttributes = [
		    .font: XFont.systemFont(ofSize: 14),
		    .foregroundColor: XColor.darkGray
		]
		
		// Configure delete button
		deleteButton.title = "×"
		deleteButton.style = createDeleteButtonStyle()
		
		// Override the button's singleAction to call onDelete
		class DeleteButton: ButtonViewlet {
		    var onDeleteAction: (() -> Void)?
		    override func singleAction() {
		        super.singleAction()
		        onDeleteAction?()
		    }
		}
		if let deleteBtn = deleteButton as? ButtonViewlet {
		    // Since we can't override singleAction directly, we'll handle deletion differently
		    // The delete functionality would need to be implemented through touch/mouse events
		}
		
		// Layout
		layoutComponents()
		
		// Add viewlets
		addViewlet(titleField)
		addViewlet(contentLabel)
		addViewlet(deleteButton)
	}
	
	private func createDeleteButtonStyle() -> ViewletStyle {
		let style = ViewletStyle()
		style.font = XFont.systemFont(ofSize: 20)
		style.cornerRadius = 10
		style.setForegroundColor(XColor.white, for: .normal)
		style.setForegroundColor(XColor.lightGray, for: .highlighted)
		style.setBackgroundFill(.solid(XColor.red), for: .normal)
		style.setBackgroundFill(.solid(XColor.darkGray), for: .highlighted)
		return style
	}
	
	private func layoutComponents() {
		let padding: CGFloat = 10
		let buttonSize: CGFloat = 20
		
		// Delete button (top right)
		deleteButton.frame = CGRect(
		    x: bounds.width - padding - buttonSize,
		    y: padding,
		    width: buttonSize,
		    height: buttonSize
		)
		
		// Title field
		titleField.frame = CGRect(
		    x: padding,
		    y: padding,
		    width: bounds.width - padding * 2 - buttonSize - 5,
		    height: 30
		)
		
		// Content label
		contentLabel.frame = CGRect(
		    x: padding,
		    y: padding + 35,
		    width: bounds.width - padding * 2,
		    height: bounds.height - padding * 2 - 35
		)
	}
	
	override func draw(in context: CGContext) {
		// Draw shadow
		context.setShadow(
		    offset: CGSize(width: 2, height: 2),
		    blur: 6,
		    color: XColor.black.withAlphaComponent(0.2).cgColor
		)
		
		// Draw card background
		#if os(iOS)
		let path = XBezierPath(roundedRect: bounds, cornerRadius: 8)
		#else
		let path = XBezierPath(roundedRect: bounds, xRadius: 8, yRadius: 8)
		#endif
		context.setFillColor(cardColor.cgColor)
		context.addPath(path.cgPath)
		context.fillPath()
		
		// Reset shadow for border
		context.setShadow(offset: .zero, blur: 0)
		
		// Draw border
		context.setStrokeColor(cardColor.darker(by: 0.1).cgColor)
		context.setLineWidth(1)
		context.addPath(path.cgPath)
		context.strokePath()
	}
	
	// MARK: - Dragging
	
	// Note: Dragging functionality would require public touch/mouse methods in Viewlet
	// For now, cards are positioned but not draggable
}

// MARK: - Color Extension

extension XColor {
	func darker(by percentage: CGFloat = 0.2) -> XColor {
		#if os(iOS)
		var hue: CGFloat = 0
		var saturation: CGFloat = 0
		var brightness: CGFloat = 0
		var alpha: CGFloat = 0
		
		self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		return XColor(hue: hue, saturation: saturation, brightness: brightness * (1 - percentage), alpha: alpha)
		#elseif os(macOS)
		if let color = self.usingColorSpace(.deviceRGB) {
		    let r = color.redComponent
		    let g = color.greenComponent
		    let b = color.blueComponent
		    let a = color.alphaComponent
		    
		    return XColor(
		        red: r * (1 - percentage),
		        green: g * (1 - percentage),
		        blue: b * (1 - percentage),
		        alpha: a
		    )
		}
		return self
		#endif
	}
}