# Panorama API Reference

## Table of Contents

1. [Core Classes](#core-classes)
   - [Panorama](#panorama)
   - [PanoramaView](#panoramaview)
   - [Viewlet](#viewlet)
2. [Supporting Classes](#supporting-classes)
   - [ViewletStyle](#viewletstyle)
   - [Gradient](#gradient)
   - [ViewletFill](#viewletfill)
3. [Type Aliases](#type-aliases)
4. [Enumerations](#enumerations)
5. [Extensions](#extensions)

---

## Core Classes

### Panorama

The main content container that manages the drawable scene.

```swift
open class Panorama: Viewlet
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `minimumZoomScale` | `CGFloat` | The minimum scale factor for zooming (default: 1.0) |
| `maximumZoomScale` | `CGFloat` | The maximum scale factor for zooming (default: 1.0) |
| `panoramaView` | `PanoramaView?` | The view hosting this panorama (weak reference) |

#### Methods

##### Initialization
```swift
public init(frame: CGRect)
```
Creates a new panorama with the specified frame.

##### Lifecycle
```swift
open func didMove(to panoramaView: PanoramaView?)
```
Called when the panorama is attached to or detached from a PanoramaView.

##### Drawing
```swift
open func draw(in context: CGContext)
```
Override this method to perform custom drawing. Called automatically when the panorama needs to be rendered.

##### Event Handling (iOS)
```swift
open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
```

##### Event Handling (macOS)
```swift
open func mouseDown(with event: NSEvent)
open func mouseDragged(with event: NSEvent)
open func mouseUp(with event: NSEvent)
open func mouseMoved(with event: NSEvent)
open func rightMouseDown(with event: NSEvent)
open func rightMouseDragged(with event: NSEvent)
open func rightMouseUp(with event: NSEvent)
open func otherMouseDown(with event: NSEvent)
open func otherMouseDragged(with event: NSEvent)
open func otherMouseUp(with event: NSEvent)
open func mouseEntered(with event: NSEvent)
open func mouseExited(with event: NSEvent)
```

---

### PanoramaView

A UIView/NSView subclass that hosts panorama content and manages scrolling/zooming.

```swift
open class PanoramaView: XView
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `panorama` | `Panorama?` | The panorama to display |
| `contentInset` | `CGFloat` | The inset from the edges (default: 64.0) |
| `zoomScale` | `CGFloat` | The current zoom scale |
| `scrollView` | `XScrollView` | The underlying scroll view (read-only) |

#### Methods

##### Zooming
```swift
open func scaleToFit()
```
Scales the panorama to fit within the view bounds.

##### Coordinate Conversion
```swift
public func convert(_ point: CGPoint, from view: XView?) -> CGPoint
public func convert(_ point: CGPoint, to view: XView?) -> CGPoint
```

---

### Viewlet

A lightweight view-like component that uses Core Graphics for rendering.

```swift
open class Viewlet
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `parent` | `Viewlet?` | The parent viewlet (read-only) |
| `subviewlets` | `[Viewlet]` | Child viewlets (read-only) |
| `bounds` | `CGRect` | The viewlet's bounds rectangle |
| `frame` | `CGRect` | The viewlet's frame rectangle |
| `transform` | `CGAffineTransform` | The transformation matrix |
| `isEnabled` | `Bool` | Whether the viewlet is enabled for interaction |

#### Methods

##### Initialization
```swift
public init(frame: CGRect)
```

##### Hierarchy Management
```swift
public func addViewlet(_ viewlet: Viewlet)
public func removeViewlet(_ viewlet: Viewlet)
```

##### Display
```swift
public func setNeedsDisplay()
open func draw(in context: CGContext)
```

##### Hit Testing
```swift
public func findViewlet(at point: CGPoint) -> Viewlet?
```

##### Drawing Utilities
```swift
public func drawText(in context: CGContext, rect: CGRect, 
                    attributedString: NSAttributedString, 
                    verticalAlignment: VerticalAlignment)
                    
public func drawImage(in context: CGContext, image: XImage, 
                     rect: CGRect, mode: ViewletImageFillMode)
```

##### Actions
```swift
open func singleAction()
open func doubleAction()
open func multipleAction(count: Int)
open func holdAction()
```

#### Nested Types

##### HorizontalAlignment
```swift
public enum HorizontalAlignment: CaseIterable {
    case left
    case center
    case right
}
```

##### VerticalAlignment
```swift
public enum VerticalAlignment: CaseIterable {
    case top
    case center
    case bottom
}
```

---

## Supporting Classes

### ViewletStyle

Defines visual style properties for viewlets.

```swift
public class ViewletStyle
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String?` | The style name |
| `parent` | `ViewletStyle?` | Parent style for inheritance |
| `cornerRadius` | `CGFloat?` | Corner radius for rounded viewlets |
| `font` | `XFont?` | Default font |
| `textAlignment` | `NSTextAlignment?` | Text alignment |

#### Methods

```swift
public init(name: String? = nil, parent: ViewletStyle? = nil)

// Color management
public func setForegroundColor(_ color: XColor?, for state: ViewletState)
public func foregroundColor(for state: ViewletState) -> XColor?

// Fill management
public func setBackgroundFill(_ fill: ViewletFill?, for state: ViewletState)
public func backgroundFill(for state: ViewletState) -> ViewletFill?
```

---

### Gradient

Represents a color gradient with multiple color stops.

```swift
public struct Gradient
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `locations` | `[CGFloat]` | Stop locations (0.0 to 1.0) |
| `colors` | `[XColor]` | Colors at each stop |
| `reversed` | `Gradient` | Returns a reversed gradient |

#### Initialization

```swift
// With color stops
public init?(colorStops: [(CGFloat, XColor)])

// With evenly spaced colors
public init?(colors: [XColor])

// Four-color gradient
public init(topLeft: XColor, topRight: XColor, 
           bottomLeft: XColor, bottomRight: XColor)
```

---

### ViewletFill

Defines how a viewlet's background should be filled.

```swift
public enum ViewletFill
```

#### Cases

| Case | Description |
|------|-------------|
| `none` | No fill |
| `solid(XColor)` | Solid color fill |
| `gradient(start: CGPoint, end: CGPoint, gradient: Gradient)` | Linear gradient |

#### Methods

```swift
public func fill(rect: CGRect, in context: CGContext)

public static func linearGradient(direction: GradientDirection, 
                                 colors: [XColor]) -> ViewletFill
```

---

## Type Aliases

Cross-platform type aliases for unified API:

```swift
// View types
public typealias XView = UIView // NSView on macOS
public typealias XViewController = UIViewController // NSViewController on macOS
public typealias XScrollView = UIScrollView // NSScrollView on macOS

// Graphics types
public typealias XColor = UIColor // NSColor on macOS
public typealias XImage = UIImage // NSImage on macOS
public typealias XFont = UIFont // NSFont on macOS
public typealias XBezierPath = UIBezierPath // NSBezierPath on macOS
public typealias XEvent = UIEvent // NSEvent on macOS
```

---

## Enumerations

### ViewletState

Visual states for viewlets.

```swift
public enum ViewletState: CaseIterable {
    case normal
    case highlighted
    case selected
    case disabled
}
```

### ViewletImageFillMode

Image scaling modes.

```swift
public enum ViewletImageFillMode: CaseIterable {
    case fill      // Scale to fill, may change aspect ratio
    case aspectFit // Scale to fit while maintaining aspect ratio
    case aspectFill // Scale to fill while maintaining aspect ratio
}
```

### GradientDirection

Gradient flow directions.

```swift
public enum GradientDirection: CaseIterable {
    case horizontal
    case vertical
    case diagonal
    case diagonalReverse
}
```

---

## Extensions

### UITouch/NSEvent Extensions

Location conversion for unified event handling:

```swift
extension UITouch {
    public func location(in panorama: Panorama) -> CGPoint?
}

extension NSEvent {
    public func location(in panorama: Panorama) -> CGPoint?
}
```

### CGRect Extensions

Geometry utilities:

```swift
extension CGRect {
    // Transform one rectangle to another
    public func transform(to rect: CGRect) -> CGAffineTransform
    
    // Create path from rectangle
    public var cgPath: CGPath
    public func cgPath(cornerRadius: CGFloat) -> CGPath
    
    // Aspect ratio calculations
    public func aspectFit(_ size: CGSize) -> CGRect
    public func aspectFill(_ size: CGSize) -> CGRect
}
```

### Platform-Specific Extensions

#### NSView (macOS only)
```swift
extension NSView {
    // UIKit compatibility methods
    public func setNeedsLayout()
    public func setNeedsDisplay()
    public func sendSubview(toBack subview: NSView)
    public func bringSubview(toFront subview: NSView)
}
```

#### NSImage (macOS only)
```swift
extension NSImage {
    public var cgImage: CGImage?
}
```

---

## Usage Examples

### Creating a Custom Panorama

```swift
class DrawingPanorama: Panorama {
    private var paths: [XBezierPath] = []
    private var currentPath: XBezierPath?
    
    override func draw(in context: CGContext) {
        // Draw background
        context.setFillColor(XColor.white.cgColor)
        context.fill(bounds)
        
        // Draw paths
        context.setStrokeColor(XColor.black.cgColor)
        context.setLineWidth(2.0)
        
        for path in paths {
            path.stroke()
        }
        
        currentPath?.stroke()
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let location = touch.location(in: self) else { return }
        
        currentPath = XBezierPath()
        currentPath?.move(to: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let location = touch.location(in: self) else { return }
        
        currentPath?.line(to: location)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let path = currentPath {
            paths.append(path)
            currentPath = nil
            setNeedsDisplay()
        }
    }
    #endif
}
```

### Creating a Custom Viewlet

```swift
class CircleViewlet: Viewlet {
    var fillColor: XColor = .blue
    var strokeColor: XColor = .black
    var lineWidth: CGFloat = 2.0
    
    override func draw(in context: CGContext) {
        let insetBounds = bounds.insetBy(dx: lineWidth/2, dy: lineWidth/2)
        
        // Fill
        context.setFillColor(fillColor.cgColor)
        context.fillEllipse(in: insetBounds)
        
        // Stroke
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(lineWidth)
        context.strokeEllipse(in: insetBounds)
    }
    
    override func singleAction() {
        // Toggle color on tap
        fillColor = (fillColor == .blue) ? .red : .blue
        setNeedsDisplay()
    }
}
```

### Applying Styles

```swift
let buttonStyle = ViewletStyle(name: "PrimaryButton")
buttonStyle.cornerRadius = 8.0
buttonStyle.font = XFont.systemFont(ofSize: 16, weight: .medium)
buttonStyle.setForegroundColor(.white, for: .normal)
buttonStyle.setForegroundColor(.lightGray, for: .highlighted)
buttonStyle.setBackgroundFill(
    .linearGradient(direction: .vertical, colors: [.systemBlue, .blue]), 
    for: .normal
)
buttonStyle.setBackgroundFill(
    .solid(.darkGray), 
    for: .highlighted
)
```