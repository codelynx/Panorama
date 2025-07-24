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

// MARK: - ViewletState

/// Represents the visual state of a viewlet.
public enum ViewletState: CaseIterable {
	case normal
	case highlighted
	case selected
	case disabled
}

// MARK: - ViewletFill

/// Defines how a viewlet's background should be filled.
public enum ViewletFill {
	/// No fill applied.
	case none
	/// Solid color fill.
	case solid(XColor)
	/// Linear gradient fill with normalized start and end points (0.0 to 1.0).
	case gradient(start: CGPoint, end: CGPoint, gradient: Gradient)
	
	/// Fills the specified rectangle with this fill style.
	public func fill(rect: CGRect, in context: CGContext) {
		switch self {
		case .none:
		    break
		    
		case .solid(let color):
		    context.setFillColor(color.cgColor)
		    context.fill(rect)
		    
		case .gradient(let startPoint, let endPoint, let gradient):
		    let colorSpace = CGColorSpaceCreateDeviceRGB()
		    let colors = gradient.colors.map(\.cgColor) as CFArray
		    var locations = gradient.locations
		    
		    guard let cgGradient = CGGradient(
		        colorsSpace: colorSpace,
		        colors: colors,
		        locations: &locations
		    ) else { return }
		    
		    let transform = CGRect(x: 0, y: 0, width: 1, height: 1).transform(to: rect)
		    let transformedStart = startPoint.applying(transform)
		    let transformedEnd = endPoint.applying(transform)
		    
		    context.drawLinearGradient(
		        cgGradient,
		        start: transformedStart,
		        end: transformedEnd,
		        options: []
		    )
		}
	}
	
	/// Creates a linear gradient fill.
	public static func linearGradient(
		direction: GradientDirection,
		colors: [XColor]
	) -> ViewletFill {
		guard colors.count >= 2 else {
		    fatalError("Linear gradient requires at least 2 colors")
		}
		
		guard let gradient = Gradient(colors: colors) else {
		    fatalError("Failed to create gradient")
		}
		
		let (start, end) = direction.points
		return .gradient(start: start, end: end, gradient: gradient)
	}
}

// MARK: - GradientDirection

/// Defines the direction of a linear gradient.
public enum GradientDirection: CaseIterable {
	case horizontal
	case vertical
	case diagonal
	case diagonalReverse
	
	/// The normalized start and end points for this direction.
	var points: (start: CGPoint, end: CGPoint) {
		switch self {
		case .horizontal:
		    return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
		case .vertical:
		    return (CGPoint(x: 0.5, y: 0.0), CGPoint(x: 0.5, y: 1.0))
		case .diagonal:
		    return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1.0, y: 1.0))
		case .diagonalReverse:
		    return (CGPoint(x: 1.0, y: 0.0), CGPoint(x: 0.0, y: 1.0))
		}
	}
}

// MARK: - ViewletStyle

/// Defines the visual style properties for viewlets.
public class ViewletStyle {
	
	// MARK: - Properties
	
	/// The name of this style.
	public var name: String?
	
	/// The parent style from which this style inherits.
	public weak var parent: ViewletStyle?
	
	/// Foreground colors for different states.
	private var foregroundColors: [ViewletState: XColor] = [:]
	
	/// Background fills for different states.
	private var backgroundFills: [ViewletState: ViewletFill] = [:]
	
	/// The corner radius for rounded viewlets.
	public var cornerRadius: CGFloat?
	
	/// The font to use for text rendering.
	public var font: XFont?
	
	/// The text alignment.
	public var textAlignment: NSTextAlignment?
	
	// MARK: - Initialization
	
	public init(name: String? = nil, parent: ViewletStyle? = nil) {
		self.name = name
		self.parent = parent
	}
	
	// MARK: - Color Management
	
	/// Sets the foreground color for a specific state.
	public func setForegroundColor(_ color: XColor?, for state: ViewletState) {
		foregroundColors[state] = color
	}
	
	/// Returns the foreground color for a specific state.
	public func foregroundColor(for state: ViewletState) -> XColor? {
		if let color = foregroundColors[state] {
		    return color
		}
		return parent?.foregroundColor(for: state)
	}
	
	// MARK: - Fill Management
	
	/// Sets the background fill for a specific state.
	public func setBackgroundFill(_ fill: ViewletFill?, for state: ViewletState) {
		if let fill = fill {
		    backgroundFills[state] = fill
		} else {
		    backgroundFills.removeValue(forKey: state)
		}
	}
	
	/// Returns the background fill for a specific state.
	public func backgroundFill(for state: ViewletState) -> ViewletFill? {
		if let fill = backgroundFills[state] {
		    return fill
		}
		return parent?.backgroundFill(for: state)
	}
}

// MARK: - Gradient

/// Represents a color gradient with multiple color stops.
public struct Gradient {
	
	// MARK: - Properties
	
	/// The color stops as an array of (location, color) tuples.
	private let colorStops: [(location: CGFloat, color: XColor)]
	
	/// The locations of the gradient stops (0.0 to 1.0).
	public var locations: [CGFloat] {
		colorStops.map(\.location)
	}
	
	/// The colors at each gradient stop.
	public var colors: [XColor] {
		colorStops.map(\.color)
	}
	
	// MARK: - Initialization
	
	/// Creates a gradient with the specified color stops.
	/// - Parameter colorStops: Array of (location, color) tuples where location must be between 0.0 and 1.0.
	public init?(colorStops: [(CGFloat, XColor)]) {
		// Validate that we have at least 2 stops
		guard colorStops.count >= 2 else { return nil }
		
		// Sort by location
		let sortedStops = colorStops.sorted { $0.0 < $1.0 }
		
		// Validate first and last locations
		guard sortedStops.first?.0 == 0.0,
		      sortedStops.last?.0 == 1.0 else { return nil }
		
		// Validate all locations are in range
		guard sortedStops.allSatisfy({ (0.0...1.0).contains($0.0) }) else { return nil }
		
		self.colorStops = sortedStops.map { (location: $0.0, color: $0.1) }
	}
	
	/// Creates a gradient with evenly spaced colors.
	public init?(colors: [XColor]) {
		guard colors.count >= 2 else { return nil }
		
		let step = 1.0 / CGFloat(colors.count - 1)
		let stops = colors.enumerated().map { index, color in
		    (CGFloat(index) * step, color)
		}
		
		self.init(colorStops: stops)
	}
	
	/// Creates a four-color gradient with stops at 0.0, 0.5, 0.5, and 1.0.
	public init(topLeft: XColor, topRight: XColor, bottomLeft: XColor, bottomRight: XColor) {
		self.colorStops = [
		    (location: 0.0, color: topLeft),
		    (location: 0.5, color: topRight),
		    (location: 0.5, color: bottomLeft),
		    (location: 1.0, color: bottomRight)
		]
	}
	
	// MARK: - Transformations
	
	/// Returns a reversed version of this gradient.
	public var reversed: Gradient {
		let reversedStops = colorStops.reversed().enumerated().map { index, stop in
		    (locations[index], stop.color)
		}
		
		// Force unwrap is safe here because we know the stops are valid
		return Gradient(colorStops: reversedStops)!
	}
}