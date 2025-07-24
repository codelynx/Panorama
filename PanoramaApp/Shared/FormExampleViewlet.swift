//
//  FormExampleViewlet.swift
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

/// A viewlet that demonstrates a form layout with labels and text fields
class FormExampleViewlet: Viewlet {
    
    // Form components
    private let titleLabel = LabelViewlet(frame: .zero)
    private let nameLabel = LabelViewlet(frame: .zero)
    private let nameField = TextFieldViewlet(frame: .zero)
    private let emailLabel = LabelViewlet(frame: .zero)
    private let emailField = TextFieldViewlet(frame: .zero)
    private let notesLabel = LabelViewlet(frame: .zero)
    private let notesField = TextFieldViewlet(frame: .zero)
    
    // Layout properties
    private let padding: CGFloat = 20
    private let labelWidth: CGFloat = 80
    private let fieldHeight: CGFloat = 30
    private let spacing: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupForm()
    }
    
    private func setupForm() {
        // Configure title
        titleLabel.text = "User Information Form"
        titleLabel.horizontalAlignment = .center
        titleLabel.textAttributes = [
            .font: XFont.boldSystemFont(ofSize: 18),
            .foregroundColor: XColor.black
        ]
        
        // Configure labels
        nameLabel.text = "Name:"
        nameLabel.horizontalAlignment = .right
        nameLabel.textAttributes = [
            .font: XFont.systemFont(ofSize: 14),
            .foregroundColor: XColor.darkGray
        ]
        
        emailLabel.text = "Email:"
        emailLabel.horizontalAlignment = .right
        emailLabel.textAttributes = nameLabel.textAttributes
        
        notesLabel.text = "Notes:"
        notesLabel.horizontalAlignment = .right
        notesLabel.textAttributes = nameLabel.textAttributes
        
        // Configure text fields
        nameField.placeholder = "Enter your name"
        emailField.placeholder = "Enter your email"
        notesField.placeholder = "Enter notes"
        
        // Setup callbacks
        nameField.onTextChanged = { [weak self] text in
            print("Name changed: \(text)")
        }
        
        emailField.onTextChanged = { [weak self] text in
            print("Email changed: \(text)")
        }
        
        // Layout components
        layoutComponents()
        
        // Add all viewlets
        addViewlet(titleLabel)
        addViewlet(nameLabel)
        addViewlet(nameField)
        addViewlet(emailLabel)
        addViewlet(emailField)
        addViewlet(notesLabel)
        addViewlet(notesField)
    }
    
    private func layoutComponents() {
        var y = padding
        
        // Title
        titleLabel.frame = CGRect(
            x: padding,
            y: y,
            width: bounds.width - padding * 2,
            height: 30
        )
        y += 30 + spacing * 2
        
        // Name row
        nameLabel.frame = CGRect(
            x: padding,
            y: y,
            width: labelWidth,
            height: fieldHeight
        )
        
        nameField.frame = CGRect(
            x: padding + labelWidth + spacing,
            y: y,
            width: bounds.width - padding * 2 - labelWidth - spacing,
            height: fieldHeight
        )
        y += fieldHeight + spacing
        
        // Email row
        emailLabel.frame = CGRect(
            x: padding,
            y: y,
            width: labelWidth,
            height: fieldHeight
        )
        
        emailField.frame = CGRect(
            x: padding + labelWidth + spacing,
            y: y,
            width: bounds.width - padding * 2 - labelWidth - spacing,
            height: fieldHeight
        )
        y += fieldHeight + spacing
        
        // Notes row
        notesLabel.frame = CGRect(
            x: padding,
            y: y,
            width: labelWidth,
            height: fieldHeight
        )
        
        notesField.frame = CGRect(
            x: padding + labelWidth + spacing,
            y: y,
            width: bounds.width - padding * 2 - labelWidth - spacing,
            height: fieldHeight * 2
        )
    }
    
    override func draw(in context: CGContext) {
        // Draw background
        context.setFillColor(XColor.white.cgColor)
        let backgroundPath = XBezierPath(roundedRect: bounds, cornerRadius: 8)
        context.addPath(backgroundPath.cgPath)
        context.fillPath()
        
        // Draw border
        context.setStrokeColor(XColor.lightGray.cgColor)
        context.setLineWidth(1)
        context.addPath(backgroundPath.cgPath)
        context.strokePath()
        
        // Draw shadow
        context.setShadow(offset: CGSize(width: 2, height: 2), blur: 4, color: XColor.black.withAlphaComponent(0.1).cgColor)
    }
}