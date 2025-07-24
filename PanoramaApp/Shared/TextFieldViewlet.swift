//
//  TextFieldViewlet.swift
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

/// A viewlet that provides text field functionality with keyboard input
open class TextFieldViewlet: Viewlet {
    
    // MARK: - Properties
    
    /// The current text value
    public var text: String = "" {
        didSet {
            setNeedsDisplay()
            onTextChanged?(text)
        }
    }
    
    /// Placeholder text shown when field is empty
    public var placeholder: String = "" {
        didSet { setNeedsDisplay() }
    }
    
    /// Whether the text field is currently focused
    public var isFocused: Bool = false {
        didSet {
            setNeedsDisplay()
            if isFocused {
                startCursorAnimation()
            } else {
                stopCursorAnimation()
            }
        }
    }
    
    /// Whether the text field is editable
    public var isEditable: Bool = true
    
    /// Text attributes
    public var font: XFont = XFont.systemFont(ofSize: 14)
    #if os(iOS)
    public var textColor: XColor = XColor.label
    public var placeholderColor: XColor = XColor.placeholderText
    #else
    public var textColor: XColor = XColor.labelColor
    public var placeholderColor: XColor = XColor.placeholderTextColor
    #endif
    
    /// Border and background
    #if os(iOS)
    public var borderColor: XColor = XColor.separator
    public var backgroundColor: XColor = XColor.systemBackground
    public var focusedBorderColor: XColor = XColor.systemBlue
    #else
    public var borderColor: XColor = XColor.separatorColor
    public var backgroundColor: XColor = XColor.controlBackgroundColor
    public var focusedBorderColor: XColor = XColor.controlAccentColor
    #endif
    public var cornerRadius: CGFloat = 4.0
    
    /// Padding
    public var textInsets = XEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    /// Cursor properties
    private var cursorPosition: Int = 0
    private var showCursor: Bool = false
    private var cursorTimer: Timer?
    
    /// Callbacks
    public var onTextChanged: ((String) -> Void)?
    public var onReturnPressed: (() -> Void)?
    
    // Hidden text field for keyboard input
    private lazy var hiddenTextField: XTextField = {
        let field = XTextField()
        #if os(iOS)
        field.isHidden = true
        field.delegate = self
        field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        #elseif os(macOS)
        field.isHidden = true
        field.delegate = self
        #endif
        return field
    }()
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupHiddenTextField()
    }
    
    private func setupHiddenTextField() {
        // Add hidden text field to the panorama view when attached
    }
    
    // MARK: - Drawing
    
    public override func draw(in context: CGContext) {
        // Draw background
        let path = XBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        context.setFillColor(backgroundColor.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        // Draw border
        let borderColor = isFocused ? focusedBorderColor : self.borderColor
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(isFocused ? 2.0 : 1.0)
        context.addPath(path.cgPath)
        context.strokePath()
        
        // Calculate text rect
        let textRect = bounds.inset(by: textInsets)
        
        // Draw text or placeholder
        let displayText = text.isEmpty ? placeholder : text
        let textColor = text.isEmpty ? placeholderColor : self.textColor
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSAttributedString(string: displayText, attributes: attributes)
        drawText(in: context, rect: textRect, attributedString: attributedString, verticalAlignment: .center)
        
        // Draw cursor if focused
        if isFocused && showCursor && !text.isEmpty {
            drawCursor(in: context, textRect: textRect)
        }
    }
    
    private func drawCursor(in context: CGContext, textRect: CGRect) {
        // Calculate cursor position
        let textBeforeCursor = String(text.prefix(cursorPosition))
        let size = (textBeforeCursor as NSString).size(withAttributes: [.font: font])
        
        let cursorX = textRect.minX + size.width
        let cursorHeight = font.lineHeight
        let cursorY = textRect.midY - cursorHeight / 2
        
        context.setStrokeColor(textColor.cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: cursorX, y: cursorY))
        context.addLine(to: CGPoint(x: cursorX, y: cursorY + cursorHeight))
        context.strokePath()
    }
    
    // MARK: - Cursor Animation
    
    private func startCursorAnimation() {
        stopCursorAnimation()
        showCursor = true
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.showCursor.toggle()
            self?.setNeedsDisplay()
        }
    }
    
    private func stopCursorAnimation() {
        cursorTimer?.invalidate()
        cursorTimer = nil
        showCursor = false
    }
    
    // MARK: - Focus Management
    
    public func focus() {
        guard isEditable else { return }
        isFocused = true
        cursorPosition = text.count
        
        // Setup hidden text field
        if let panoramaView = panorama?.panoramaView {
            #if os(iOS)
            panoramaView.addSubview(hiddenTextField)
            hiddenTextField.text = text
            hiddenTextField.becomeFirstResponder()
            #elseif os(macOS)
            panoramaView.addSubview(hiddenTextField)
            hiddenTextField.stringValue = text
            panoramaView.window?.makeFirstResponder(hiddenTextField)
            #endif
        }
    }
    
    public func resignFocus() {
        isFocused = false
        hiddenTextField.removeFromSuperview()
        #if os(iOS)
        hiddenTextField.resignFirstResponder()
        #elseif os(macOS)
        panorama?.panoramaView?.window?.makeFirstResponder(nil)
        #endif
    }
    
    // MARK: - Text Input
    
    #if os(iOS)
    @objc private func textFieldDidChange(_ textField: UITextField) {
        text = textField.text ?? ""
        cursorPosition = text.count
    }
    #endif
    
    // MARK: - Actions
    
    public override func singleAction() {
        if isEditable {
            focus()
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopCursorAnimation()
        hiddenTextField.removeFromSuperview()
    }
}

// MARK: - Platform-specific TextField Delegate

#if os(iOS)
extension TextFieldViewlet: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnPressed?()
        resignFocus()
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        resignFocus()
    }
}
#elseif os(macOS)
extension TextFieldViewlet: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            text = textField.stringValue
            cursorPosition = text.count
        }
    }
    
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            onReturnPressed?()
            resignFocus()
            return true
        }
        return false
    }
}
#endif

// MARK: - Platform Type Aliases

#if os(iOS)
typealias XTextField = UITextField
typealias XEdgeInsets = UIEdgeInsets
#elseif os(macOS)
typealias XTextField = NSTextField
typealias XEdgeInsets = NSEdgeInsets
#endif