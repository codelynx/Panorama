# Panorama - Getting Started Guide

A comprehensive guide to building your first cross-platform graphics application with Panorama.

## Table of Contents

1. [Introduction](#introduction)
2. [Understanding the Architecture](#understanding-the-architecture)
3. [Setting Up Your Project](#setting-up-your-project)
4. [Creating Your First Panorama](#creating-your-first-panorama)
5. [Working with PanoramaView](#working-with-panoramaview)
6. [Handling User Input](#handling-user-input)
7. [Advanced Topics](#advanced-topics)
8. [Debugging and Troubleshooting](#debugging-and-troubleshooting)
9. [Best Practices](#best-practices)
10. [Complete Example Project](#complete-example-project)

---

## Introduction

Panorama is a powerful framework for creating cross-platform 2D graphics applications that work seamlessly on both iOS and macOS. This guide will walk you through everything you need to know to get started.

### What You'll Learn

- How Panorama's architecture works
- Setting up a new project with Panorama
- Creating custom drawings with Core Graphics
- Implementing zooming and panning
- Handling touch and mouse events
- Building a complete drawing application

### Prerequisites

- Basic knowledge of Swift
- Familiarity with iOS/macOS development
- Xcode 15.0 or later installed
- Swift 5.9 or later

---

## Understanding the Architecture

Before diving into code, it's essential to understand how Panorama works under the hood.

### The Layer Architecture

Panorama uses a sophisticated layered architecture to provide smooth scrolling and zooming while maintaining cross-platform compatibility:

```
┌─────────────────────────────────────────┐
│          Your Application               │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│            PanoramaView                 │  ← UIView/NSView subclass
│  ┌─────────────────────────────────┐   │
│  │         BackView                │   │  ← Renders your content
│  │  (Handles all drawing)          │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │        ScrollView               │   │  ← Manages pan & zoom
│  │  ┌───────────────────────────┐ │   │
│  │  │     ContentView           │ │   │  ← Captures user input
│  │  │  (Transparent overlay)    │ │   │
│  │  └───────────────────────────┘ │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│             Panorama                    │  ← Your content & logic
│         (Your subclass)                 │
└─────────────────────────────────────────┘
```

### Deep Dive: How It Works

#### The Rendering Pipeline

1. **PanoramaView** creates three key components:
   - **BackView**: A custom view that renders your content
   - **ScrollView**: Native UIScrollView/NSScrollView for scrolling and zooming
   - **ContentView**: Transparent view that forwards events to your Panorama

2. **Event Flow**:
   ```
   User Touch/Click → ContentView → Panorama → Viewlets
   ```

3. **Drawing Flow**:
   ```
   setNeedsDisplay() → BackView → Panorama.draw() → Viewlets.draw()
   ```

#### Key Implementation Details

```swift
// PanoramaView internally manages the view hierarchy
class PanoramaView {
    // BackView renders content at the bottom layer
    let backView = PanoramaBackView()
    
    // ScrollView handles pan/zoom gestures
    let scrollView: XScrollView
    
    // ContentView captures touches/clicks
    let contentView = PanoramaContentView()
    
    // Your panorama content
    var panorama: Panorama? {
        didSet {
            // Updates scroll view constraints
            // Configures zoom scales
            // Triggers initial render
        }
    }
}
```

### Key Concepts

1. **Panorama**: Your content container where you implement drawing logic
   - Subclass of Viewlet with special responsibilities
   - Manages the drawable canvas size
   - Routes events to child viewlets

2. **PanoramaView**: The host view that manages the display infrastructure
   - Creates and manages the view hierarchy
   - Handles platform-specific scroll view setup
   - Provides public API for zoom/scroll control

3. **BackView**: Performs the actual rendering using Core Graphics
   - Calls panorama's draw method when needed
   - Manages the Core Graphics context
   - Handles coordinate system transformations

4. **ContentView**: Transparent view that captures user interactions
   - Same size as your panorama's bounds
   - Forwards touch/mouse events to panorama
   - Enables hit testing on viewlets

5. **ScrollView**: Native scroll view that handles pan and zoom gestures
   - UIScrollView on iOS, NSScrollView on macOS
   - ContentView is its zooming view
   - Manages content insets for padding

### Coordinate Systems

Panorama handles platform differences automatically:

- **iOS**: Origin at top-left, Y increases downward
- **macOS**: Origin at bottom-left, Y increases upward (flipped)

The framework handles this through:

```swift
// macOS uses a flipped clip view
class FlippedClipView: NSClipView {
    override var isFlipped: Bool { return true }
}
```

You don't need to worry about these differences - just draw in your panorama's coordinate system.

---

## Setting Up Your Project

### Step 1: Create a New Xcode Project

1. Open Xcode and create a new project
2. Choose "App" template
3. Configure your project:
   - Product Name: `MyPanoramaApp`
   - Interface: `Storyboard` (or SwiftUI with UIViewRepresentable)
   - Language: `Swift`

### Step 2: Add Panorama Dependency

#### Using Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/yourusername/Panorama.git
   ```
3. Choose version 2.0.0 or later
4. Add to your app target

#### Manual Installation

Alternatively, add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Panorama.git", from: "2.0.0")
],
targets: [
    .target(
        name: "MyPanoramaApp",
        dependencies: ["Panorama"]
    )
]
```

### Step 3: Configure Project Settings

#### Info.plist Configuration

For iOS, if you're supporting multiple orientations:

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

#### Build Settings

Ensure these settings in your target:
- **Swift Language Version**: 5.9
- **Deployment Target**: iOS 13.0+ / macOS 10.13+

---

## Creating Your First Panorama

Let's create a simple panorama that displays a grid pattern.

### Step 1: Create a Panorama Subclass

Create a new file `GridPanorama.swift`:

```swift
import Panorama
import CoreGraphics

class GridPanorama: Panorama {
    // Grid properties
    let gridSize: CGFloat = 50
    var gridColor = XColor.lightGray
    var backgroundColor = XColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPanorama()
    }
    
    private func setupPanorama() {
        // Configure zoom limits
        minimumZoomScale = 0.25
        maximumZoomScale = 4.0
    }
    
    override func draw(in context: CGContext) {
        // Fill background
        context.setFillColor(backgroundColor.cgColor)
        context.fill(bounds)
        
        // Draw grid
        drawGrid(in: context)
        
        // Draw content
        drawContent(in: context)
    }
    
    private func drawGrid(in context: CGContext) {
        context.setStrokeColor(gridColor.cgColor)
        context.setLineWidth(1.0 / (panoramaView?.zoomScale ?? 1.0))
        
        // Draw vertical lines
        var x: CGFloat = 0
        while x <= bounds.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: bounds.height))
            x += gridSize
        }
        
        // Draw horizontal lines
        var y: CGFloat = 0
        while y <= bounds.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: bounds.width, y: y))
            y += gridSize
        }
        
        context.strokePath()
    }
    
    private func drawContent(in context: CGContext) {
        // Draw a sample shape
        let rect = CGRect(x: 200, y: 200, width: 300, height: 200)
        
        // Shadow
        context.setShadow(offset: CGSize(width: 5, height: 5), blur: 10)
        
        // Fill
        context.setFillColor(XColor.systemBlue.cgColor)
        context.fillEllipse(in: rect)
        
        // Border
        context.setStrokeColor(XColor.darkGray.cgColor)
        context.setLineWidth(3.0)
        context.strokeEllipse(in: rect)
        
        // Text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: XFont.boldSystemFont(ofSize: 24),
            .foregroundColor: XColor.white
        ]
        let text = NSAttributedString(string: "Hello Panorama!", attributes: attributes)
        drawText(in: context, rect: rect, attributedString: text, verticalAlignment: .center)
    }
    
    override func didMove(to panoramaView: PanoramaView?) {
        super.didMove(to: panoramaView)
        
        if panoramaView != nil {
            print("Panorama attached to view")
            // Perform any setup that requires the view
        } else {
            print("Panorama detached from view")
            // Cleanup if needed
        }
    }
}
```

### Performance Architecture

Panorama is designed for high-performance graphics:

1. **Direct Core Graphics Rendering**: No intermediate view hierarchy
2. **Efficient Invalidation**: Only redraws when needed
3. **Optimized Event Routing**: Direct hit testing without view traversal
4. **Memory Efficient**: Viewlets are lightweight objects, not views

---

## Working with PanoramaView

### Xcode Project Configuration

#### Required Build Settings

Ensure these settings in your target's Build Settings:

1. **Swift Language Version**: Swift 5.9
2. **Deployment Targets**:
   - iOS: 13.0 or later
   - macOS: 10.13 or later
3. **Enable Modules**: Yes
4. **Link Frameworks Automatically**: Yes

#### Info.plist Configuration

For iOS apps supporting multiple orientations:

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
</array>
```

For iPad multitasking support:

```xml
<key>UIRequiresFullScreen</key>
<false/>
<key>UISupportsDocumentBrowser</key>
<true/>
```

### Setting Up in Storyboard

1. Open your storyboard
2. Add a `UIView` (iOS) or `NSView` (macOS) to your view controller
3. Set its class to `PanoramaView` in the Identity Inspector
4. Create an outlet connection

### View Controller Implementation

Create your view controller:

```swift
import UIKit // or Cocoa for macOS
import Panorama

class ViewController: XViewController {
    @IBOutlet weak var panoramaView: PanoramaView!
    
    var gridPanorama: GridPanorama!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPanorama()
        setupUI()
    }
    
    private func setupPanorama() {
        // Create panorama with content size
        let contentSize = CGSize(width: 2048, height: 2048)
        gridPanorama = GridPanorama(frame: CGRect(origin: .zero, size: contentSize))
        
        // Attach to view
        panoramaView.panorama = gridPanorama
        
        // Configure view
        panoramaView.contentInset = 20 // Padding around content
        
        // Optional: Set initial zoom to fit
        DispatchQueue.main.async {
            self.panoramaView.scaleToFit()
        }
    }
    
    private func setupUI() {
        // Add toolbar or controls
        setupToolbar()
        
        // Add gesture recognizers if needed
        setupGestures()
    }
    
    private func setupToolbar() {
        #if os(iOS)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Fit", style: .plain, target: self, action: #selector(fitToScreen)),
            UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetZoom))
        ]
        #endif
    }
    
    private func setupGestures() {
        #if os(iOS)
        // Add double-tap to zoom
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        panoramaView.addGestureRecognizer(doubleTap)
        #endif
    }
    
    @objc private func fitToScreen() {
        panoramaView.scaleToFit()
    }
    
    @objc private func resetZoom() {
        panoramaView.zoomScale = 1.0
    }
    
    #if os(iOS)
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: panoramaView)
        
        if panoramaView.zoomScale == 1.0 {
            // Zoom in
            panoramaView.scrollView.zoom(to: CGRect(x: location.x - 50, y: location.y - 50, width: 100, height: 100), animated: true)
        } else {
            // Zoom out
            panoramaView.zoomScale = 1.0
        }
    }
    #endif
}
```

### Programmatic Setup (No Storyboard)

If you prefer to create views programmatically:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create PanoramaView
    let panoramaView = PanoramaView(frame: view.bounds)
    panoramaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(panoramaView)
    
    // Create and attach panorama
    let panorama = GridPanorama(frame: CGRect(x: 0, y: 0, width: 2048, height: 2048))
    panoramaView.panorama = panorama
}
```

### Working with ScrollView Properties

Panorama provides access to the underlying scroll view for advanced customization:

```swift
// Access the scroll view
let scrollView = panoramaView.scrollView

#if os(iOS)
// iOS-specific scroll view customization
scrollView.showsHorizontalScrollIndicator = false
scrollView.showsVerticalScrollIndicator = false
scrollView.decelerationRate = .fast
scrollView.bounces = true
scrollView.bouncesZoom = true

// Customize scroll behavior
scrollView.panGestureRecognizer.minimumNumberOfTouches = 2  // Require 2 fingers
scrollView.pinchGestureRecognizer?.isEnabled = true         // Enable pinch zoom

// Add custom gesture recognizers
let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
doubleTapGesture.numberOfTapsRequired = 2
scrollView.addGestureRecognizer(doubleTapGesture)

#elseif os(macOS)
// macOS-specific scroll view customization
scrollView.hasVerticalScroller = true
scrollView.hasHorizontalScroller = true
scrollView.usesPredominantAxisScrolling = false
scrollView.scrollerStyle = .overlay
scrollView.autohidesScrollers = true

// Enable elastic scrolling
scrollView.horizontalScrollElasticity = .allowed
scrollView.verticalScrollElasticity = .allowed
#endif
```

### Advanced Zooming Control

```swift
class ZoomablePanoramaViewController: XViewController {
    @IBOutlet weak var panoramaView: PanoramaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPanorama()
        setupZoomControls()
    }
    
    private func setupZoomControls() {
        // Programmatic zoom with animation
        func zoomToRect(_ rect: CGRect, animated: Bool = true) {
            #if os(iOS)
            panoramaView.scrollView.zoom(to: rect, animated: animated)
            #elseif os(macOS)
            if animated {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.25
                    panoramaView.scrollView.animator().magnify(toFit: rect)
                }
            } else {
                panoramaView.scrollView.magnify(toFit: rect)
            }
            #endif
        }
        
        // Zoom to specific scale
        func setZoomScale(_ scale: CGFloat, animated: Bool = true) {
            #if os(iOS)
            panoramaView.scrollView.setZoomScale(scale, animated: animated)
            #elseif os(macOS)
            if animated {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.25
                    panoramaView.scrollView.animator().magnification = scale
                }
            } else {
                panoramaView.scrollView.magnification = scale
            }
            #endif
        }
        
        // Center on point at specific zoom
        func zoomToPoint(_ point: CGPoint, scale: CGFloat, animated: Bool = true) {
            let size = panoramaView.bounds.size
            let rect = CGRect(
                x: point.x - size.width / (2 * scale),
                y: point.y - size.height / (2 * scale),
                width: size.width / scale,
                height: size.height / scale
            )
            zoomToRect(rect, animated: animated)
        }
    }
    
    // Smart zoom on double tap/click
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: panoramaView.scrollView)
        let currentScale = panoramaView.zoomScale
        
        // Zoom levels: 1x → 2x → 4x → 1x
        let newScale: CGFloat
        if currentScale < 1.5 {
            newScale = 2.0
        } else if currentScale < 3.0 {
            newScale = 4.0
        } else {
            newScale = 1.0
        }
        
        if newScale == 1.0 {
            // Zoom out to fit
            panoramaView.scaleToFit()
        } else {
            // Zoom in centered on tap location
            let size = panoramaView.bounds.size
            let rect = CGRect(
                x: location.x - size.width / (2 * newScale),
                y: location.y - size.height / (2 * newScale),
                width: size.width / newScale,
                height: size.height / newScale
            )
            #if os(iOS)
            panoramaView.scrollView.zoom(to: rect, animated: true)
            #endif
        }
    }
}
```

### Content Insets and Safe Areas

```swift
// Configure content insets for padding
panoramaView.contentInset = 20  // Uniform inset

// Or platform-specific insets
#if os(iOS)
// Respect safe area on iOS
let safeArea = view.safeAreaInsets
panoramaView.scrollView.contentInset = UIEdgeInsets(
    top: safeArea.top + 20,
    left: safeArea.left + 20,
    bottom: safeArea.bottom + 20,
    right: safeArea.right + 20
)
#elseif os(macOS)
// Custom insets on macOS
panoramaView.scrollView.contentInsets = NSEdgeInsets(
    top: 20, left: 20, bottom: 20, right: 20
)
#endif
```

---

## Handling User Input

### Creating an Interactive Drawing Panorama

Let's create a panorama that allows users to draw:

```swift
import Panorama

class DrawingPanorama: Panorama {
    // Drawing properties
    private var paths: [DrawingPath] = []
    private var currentPath: DrawingPath?
    
    var strokeColor = XColor.black
    var strokeWidth: CGFloat = 2.0
    
    struct DrawingPath {
        var points: [CGPoint] = []
        var color: XColor
        var width: CGFloat
        
        func draw(in context: CGContext) {
            guard points.count > 1 else { return }
            
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(width)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            
            context.move(to: points[0])
            for point in points.dropFirst() {
                context.addLine(to: point)
            }
            context.strokePath()
        }
    }
    
    override func draw(in context: CGContext) {
        // White background
        context.setFillColor(XColor.white.cgColor)
        context.fill(bounds)
        
        // Draw all paths
        for path in paths {
            path.draw(in: context)
        }
        
        // Draw current path
        currentPath?.draw(in: context)
    }
    
    // MARK: - Touch Handling (iOS)
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let location = touch.location(in: self) else { return }
        
        // Start new path
        currentPath = DrawingPath(
            points: [location],
            color: strokeColor,
            width: strokeWidth
        )
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let location = touch.location(in: self) else { return }
        
        // Add point to current path
        currentPath?.points.append(location)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let path = currentPath {
            paths.append(path)
            currentPath = nil
            setNeedsDisplay()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentPath = nil
        setNeedsDisplay()
    }
    #endif
    
    // MARK: - Mouse Handling (macOS)
    
    #if os(macOS)
    private var isDrawing = false
    
    override func mouseDown(with event: NSEvent) {
        guard let location = event.location(in: self) else { return }
        
        isDrawing = true
        currentPath = DrawingPath(
            points: [location],
            color: strokeColor,
            width: strokeWidth
        )
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard isDrawing,
              let location = event.location(in: self) else { return }
        
        currentPath?.points.append(location)
        setNeedsDisplay()
    }
    
    override func mouseUp(with event: NSEvent) {
        if let path = currentPath {
            paths.append(path)
            currentPath = nil
            isDrawing = false
            setNeedsDisplay()
        }
    }
    #endif
    
    // MARK: - Public Methods
    
    func clear() {
        paths.removeAll()
        currentPath = nil
        setNeedsDisplay()
    }
    
    func undo() {
        if !paths.isEmpty {
            paths.removeLast()
            setNeedsDisplay()
        }
    }
}
```

### Adding Drawing Controls

Update your view controller to add drawing controls:

```swift
class DrawingViewController: XViewController {
    @IBOutlet weak var panoramaView: PanoramaView!
    var drawingPanorama: DrawingPanorama!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDrawingPanorama()
        setupControls()
    }
    
    private func setupDrawingPanorama() {
        drawingPanorama = DrawingPanorama(frame: CGRect(x: 0, y: 0, width: 2048, height: 2048))
        drawingPanorama.minimumZoomScale = 0.5
        drawingPanorama.maximumZoomScale = 5.0
        
        panoramaView.panorama = drawingPanorama
    }
    
    private func setupControls() {
        #if os(iOS)
        // Create toolbar
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Add buttons
        toolbar.items = [
            UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearDrawing)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Undo", style: .plain, target: self, action: #selector(undoDrawing)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            createColorButton(color: .black),
            createColorButton(color: .red),
            createColorButton(color: .blue),
            createColorButton(color: .green)
        ]
        #endif
    }
    
    #if os(iOS)
    private func createColorButton(color: UIColor) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.backgroundColor = color
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        drawingPanorama.strokeColor = sender.backgroundColor ?? .black
    }
    #endif
    
    @objc private func clearDrawing() {
        drawingPanorama.clear()
    }
    
    @objc private func undoDrawing() {
        drawingPanorama.undo()
    }
}
```

---

## Advanced Topics

### Real-World Example: Image Viewer with Annotations

Here's a complete example of an image viewer with annotation support:

```swift
import Panorama
import CoreGraphics

// Custom annotation viewlet
class ImageAnnotation: Viewlet {
    var text: String
    var author: String
    var timestamp: Date
    var color: XColor
    var isSelected = false
    private var isDragging = false
    private var dragOffset: CGPoint = .zero
    
    init(text: String, author: String, color: XColor, at point: CGPoint) {
        self.text = text
        self.author = author
        self.color = color
        self.timestamp = Date()
        super.init(frame: CGRect(origin: point, size: CGSize(width: 200, height: 80)))
    }
    
    override func draw(in context: CGContext) {
        // Draw pin
        let pinPath = XBezierPath()
        pinPath.move(to: CGPoint(x: bounds.width/2, y: bounds.height))
        pinPath.addLine(to: CGPoint(x: bounds.width/2 - 10, y: bounds.height - 20))
        pinPath.addLine(to: CGPoint(x: bounds.width/2 + 10, y: bounds.height - 20))
        pinPath.close()
        
        context.setFillColor(color.cgColor)
        context.addPath(pinPath.cgPath)
        context.fillPath()
        
        // Draw bubble
        let bubbleRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 20)
        let bubblePath = XBezierPath(roundedRect: bubbleRect, cornerRadius: 8)
        
        // Shadow
        context.setShadow(offset: CGSize(width: 2, height: 2), blur: 4, color: XColor.black.withAlphaComponent(0.3).cgColor)
        context.setFillColor(color.cgColor)
        context.addPath(bubblePath.cgPath)
        context.fillPath()
        
        // Border
        if isSelected {
            context.setStrokeColor(XColor.white.cgColor)
            context.setLineWidth(3)
            context.addPath(bubblePath.cgPath)
            context.strokePath()
        }
        
        // Text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: XFont.systemFont(ofSize: 12),
            .foregroundColor: XColor.white,
            .paragraphStyle: paragraphStyle
        ]
        
        let textString = "\(text)\n- \(author)"
        let attrString = NSAttributedString(string: textString, attributes: attributes)
        drawText(in: context, rect: bubbleRect.insetBy(dx: 10, dy: 10), attributedString: attrString, verticalAlignment: .center)
    }
    
    override func singleAction() {
        isSelected.toggle()
        setNeedsDisplay()
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first,
              let location = touch.location(in: parent) else { return }
        
        isDragging = true
        dragOffset = CGPoint(x: location.x - frame.origin.x,
                           y: location.y - frame.origin.y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard isDragging,
              let touch = touches.first,
              let location = touch.location(in: parent) else { return }
        
        frame.origin = CGPoint(x: location.x - dragOffset.x,
                              y: location.y - dragOffset.y)
        parent?.setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isDragging = false
    }
    #endif
}

// Image viewer panorama
class ImageViewerPanorama: Panorama {
    var image: XImage? {
        didSet {
            if let image = image {
                // Resize panorama to match image
                frame = CGRect(origin: .zero, size: image.size)
            }
            setNeedsDisplay()
        }
    }
    
    var annotations: [ImageAnnotation] = []
    var showGrid = false
    var gridSize: CGFloat = 50
    
    override func draw(in context: CGContext) {
        // Background
        context.setFillColor(XColor.darkGray.cgColor)
        context.fill(bounds)
        
        // Draw image
        if let image = image, let cgImage = image.cgImage {
            context.draw(cgImage, in: bounds)
        }
        
        // Draw grid overlay
        if showGrid {
            drawGrid(in: context)
        }
    }
    
    private func drawGrid(in context: CGContext) {
        context.setStrokeColor(XColor.white.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(1.0)
        
        // Vertical lines
        var x: CGFloat = 0
        while x <= bounds.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: bounds.height))
            x += gridSize
        }
        
        // Horizontal lines
        var y: CGFloat = 0
        while y <= bounds.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: bounds.width, y: y))
            y += gridSize
        }
        
        context.strokePath()
    }
    
    func addAnnotation(text: String, author: String, at point: CGPoint, color: XColor = .systemYellow) {
        let annotation = ImageAnnotation(text: text, author: author, color: color, at: point)
        annotations.append(annotation)
        addViewlet(annotation)
    }
    
    func removeSelectedAnnotations() {
        let selectedAnnotations = annotations.filter { $0.isSelected }
        for annotation in selectedAnnotations {
            removeViewlet(annotation)
            if let index = annotations.firstIndex(where: { $0 === annotation }) {
                annotations.remove(at: index)
            }
        }
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if we hit any annotations first
        if let touch = touches.first,
           let location = touch.location(in: self),
           let _ = findViewlet(at: location) {
            // Let the viewlet handle it
            super.touchesBegan(touches, with: event)
            return
        }
        
        // Otherwise, deselect all annotations
        for annotation in annotations {
            annotation.isSelected = false
        }
        setNeedsDisplay()
        super.touchesBegan(touches, with: event)
    }
    #endif
}

// View controller implementation
class ImageViewerViewController: XViewController {
    @IBOutlet weak var panoramaView: PanoramaView!
    var imageViewerPanorama: ImageViewerPanorama!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageViewer()
        setupToolbar()
        loadSampleImage()
    }
    
    private func setupImageViewer() {
        imageViewerPanorama = ImageViewerPanorama(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
        imageViewerPanorama.minimumZoomScale = 0.1
        imageViewerPanorama.maximumZoomScale = 10.0
        
        panoramaView.panorama = imageViewerPanorama
        panoramaView.contentInset = 20
    }
    
    private func setupToolbar() {
        #if os(iOS)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAnnotation)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelected)),
            UIBarButtonItem(title: "Grid", style: .plain, target: self, action: #selector(toggleGrid))
        ]
        #endif
    }
    
    private func loadSampleImage() {
        // Load your image
        if let image = XImage(named: "sample-image") {
            imageViewerPanorama.image = image
            
            // Fit to screen after loading
            DispatchQueue.main.async {
                self.panoramaView.scaleToFit()
            }
        }
    }
    
    @objc private func addAnnotation() {
        // Add annotation at center of visible area
        let visibleRect = panoramaView.scrollView.bounds
        let center = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        #if os(iOS)
        let alert = UIAlertController(title: "Add Annotation", message: "Enter annotation text:", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Annotation text"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            let text = alert.textFields?.first?.text ?? "Note"
            let author = "User"
            self.imageViewerPanorama.addAnnotation(text: text, author: author, at: center)
        })
        present(alert, animated: true)
        #endif
    }
    
    @objc private func deleteSelected() {
        imageViewerPanorama.removeSelectedAnnotations()
    }
    
    @objc private func toggleGrid() {
        imageViewerPanorama.showGrid.toggle()
        imageViewerPanorama.setNeedsDisplay()
    }
}
```

### Working with Viewlets

Create reusable components using the Viewlet system:

```swift
class AnnotationViewlet: Viewlet {
    var text: String
    var author: String
    var timestamp: Date
    var isSelected = false
    
    init(text: String, author: String, at point: CGPoint) {
        self.text = text
        self.author = author
        self.timestamp = Date()
        
        let size = CGSize(width: 200, height: 100)
        super.init(frame: CGRect(origin: point, size: size))
    }
    
    override func draw(in context: CGContext) {
        // Background
        let fillColor = isSelected ? XColor.systemBlue : XColor.systemYellow
        context.setFillColor(fillColor.cgColor)
        
        let path = XBezierPath(roundedRect: bounds, cornerRadius: 8)
        context.addPath(path.cgPath)
        context.fillPath()
        
        // Border
        context.setStrokeColor(XColor.darkGray.cgColor)
        context.setLineWidth(1)
        context.addPath(path.cgPath)
        context.strokePath()
        
        // Text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: XFont.systemFont(ofSize: 12),
            .foregroundColor: XColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        let string = "\(text)\n\n- \(author)"
        let attrString = NSAttributedString(string: string, attributes: attributes)
        
        let textRect = bounds.insetBy(dx: 10, dy: 10)
        drawText(in: context, rect: textRect, attributedString: attrString, verticalAlignment: .top)
    }
    
    override func singleAction() {
        isSelected.toggle()
        setNeedsDisplay()
    }
}

// Using viewlets in your panorama
class AnnotatedPanorama: Panorama {
    override func draw(in context: CGContext) {
        // Draw background
        context.setFillColor(XColor.white.cgColor)
        context.fill(bounds)
        
        // Viewlets are drawn automatically by the superclass
    }
    
    func addAnnotation(text: String, author: String, at point: CGPoint) {
        let annotation = AnnotationViewlet(text: text, author: author, at: point)
        addViewlet(annotation)
    }
}
```

### Custom Scroll Indicators

Add custom scroll position indicators:

```swift
extension PanoramaView {
    func addScrollIndicator() {
        let indicator = ScrollIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            indicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            indicator.widthAnchor.constraint(equalToConstant: 100),
            indicator.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        indicator.panoramaView = self
    }
}

class ScrollIndicatorView: XView {
    weak var panoramaView: PanoramaView? {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        guard let panoramaView = panoramaView,
              let panorama = panoramaView.panorama else { return }
        
        let context = XGraphicsContext.current?.cgContext
        
        // Background
        context?.setFillColor(XColor.black.withAlphaComponent(0.3).cgColor)
        context?.fill(bounds)
        
        // Calculate visible rect
        let scale = min(bounds.width / panorama.bounds.width,
                       bounds.height / panorama.bounds.height) * 0.9
        
        let visibleRect = panoramaView.scrollView.bounds
        let scaledRect = CGRect(
            x: visibleRect.origin.x * scale,
            y: visibleRect.origin.y * scale,
            width: visibleRect.width * scale,
            height: visibleRect.height * scale
        )
        
        // Draw visible area
        context?.setStrokeColor(XColor.white.cgColor)
        context?.setLineWidth(2)
        context?.stroke(scaledRect)
    }
}
```

### Performance Optimization

For better performance with complex content:

```swift
class OptimizedPanorama: Panorama {
    private var cachedImage: XImage?
    private var needsRedraw = true
    
    override func draw(in context: CGContext) {
        // Use cached image if available
        if let cachedImage = cachedImage, !needsRedraw {
            context.draw(cachedImage.cgImage!, in: bounds)
            return
        }
        
        // Create off-screen context for caching
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        guard let cacheContext = UIGraphicsGetCurrentContext() else { return }
        
        // Draw expensive content
        drawExpensiveContent(in: cacheContext)
        
        // Cache the result
        cachedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Draw cached image
        if let cachedImage = cachedImage {
            context.draw(cachedImage.cgImage!, in: bounds)
        }
        
        needsRedraw = false
    }
    
    private func drawExpensiveContent(in context: CGContext) {
        // Your complex drawing code here
    }
    
    override func setNeedsDisplay() {
        needsRedraw = true
        super.setNeedsDisplay()
    }
}
```

---

## Debugging and Troubleshooting

### Common Issues and Solutions

#### Content Not Visible

```swift
// Check panorama bounds
print("Panorama bounds: \(panorama.bounds)")
print("PanoramaView bounds: \(panoramaView.bounds)")

// Ensure panorama is attached
assert(panoramaView.panorama != nil, "Panorama not attached")

// Check zoom scale
print("Current zoom: \(panoramaView.zoomScale)")
```

#### Touch/Mouse Events Not Working

```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event) // Don't forget super!
    
    // Debug touch location
    if let touch = touches.first {
        let viewLocation = touch.location(in: panoramaView)
        let panoramaLocation = touch.location(in: self)
        print("Touch in view: \(viewLocation), in panorama: \(panoramaLocation)")
    }
}
```

#### Performance Issues

Enable performance debugging:

```swift
class DebugPanorama: Panorama {
    override func draw(in context: CGContext) {
        let startTime = CACurrentMediaTime()
        
        // Your drawing code
        super.draw(in: context)
        
        let elapsed = CACurrentMediaTime() - startTime
        print("Draw time: \(elapsed * 1000)ms")
        
        // Show FPS
        drawFPS(in: context, elapsed: elapsed)
    }
    
    private func drawFPS(in context: CGContext, elapsed: TimeInterval) {
        let fps = 1.0 / elapsed
        let text = String(format: "FPS: %.1f", fps)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: XFont.systemFont(ofSize: 16),
            .foregroundColor: XColor.red
        ]
        
        let attrString = NSAttributedString(string: text, attributes: attributes)
        drawText(in: context, rect: CGRect(x: 10, y: 10, width: 100, height: 30),
                attributedString: attrString, verticalAlignment: .top)
    }
}
```

### Debug Overlay

Add a debug overlay to visualize the view hierarchy:

```swift
extension PanoramaView {
    func enableDebugMode() {
        #if DEBUG
        // Add border to views
        layer.borderColor = XColor.red.cgColor
        layer.borderWidth = 2
        
        backView.layer.borderColor = XColor.green.cgColor
        backView.layer.borderWidth = 1
        
        contentView.layer.borderColor = XColor.blue.cgColor
        contentView.layer.borderWidth = 1
        
        // Add labels
        addDebugLabel(to: self, text: "PanoramaView", color: .red)
        addDebugLabel(to: backView, text: "BackView", color: .green)
        addDebugLabel(to: contentView, text: "ContentView", color: .blue)
        #endif
    }
    
    private func addDebugLabel(to view: XView, text: String, color: XColor) {
        let label = XLabel()
        label.text = text
        label.textColor = color
        label.font = XFont.boldSystemFont(ofSize: 12)
        label.sizeToFit()
        view.addSubview(label)
    }
}
```

---

## Best Practices

### 1. Memory Management

Always use weak references to avoid retain cycles:

```swift
class MyPanorama: Panorama {
    private weak var delegate: MyPanoramaDelegate?
    
    private var timer: Timer?
    
    func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateAnimation()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
```

### 2. Efficient Drawing

Minimize drawing operations:

```swift
override func draw(in context: CGContext) {
    // Only draw visible content
    guard let visibleRect = panoramaView?.scrollView.bounds else { return }
    
    // Cull objects outside visible area
    let objectsToD draw = objects.filter { object in
        return object.frame.intersects(visibleRect)
    }
    
    // Draw only visible objects
    for object in objectsToDraw {
        object.draw(in: context)
    }
}
```

### 3. Coordinate System Consistency

Always use panorama coordinates:

```swift
// Good: Using panorama coordinates
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first,
          let location = touch.location(in: self) else { return }
    
    handleTouch(at: location) // location is in panorama coordinates
}

// Bad: Mixing coordinate systems
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    
    let viewLocation = touch.location(in: panoramaView) // Wrong coordinate system!
    handleTouch(at: viewLocation)
}
```

### 4. State Management

Keep state in the panorama, not the view controller:

```swift
// Good: State in Panorama
class DocumentPanorama: Panorama {
    private var document: Document
    private var selectedObject: DrawableObject?
    
    func save() -> Data {
        return document.serialize()
    }
}

// Bad: State in ViewController
class ViewController: XViewController {
    var document: Document // Should be in Panorama
    var selectedObject: DrawableObject? // Should be in Panorama
}
```

### Creating a Mini-Map Viewlet

Here's an example of a mini-map that shows the current viewport:

```swift
class MiniMapViewlet: Viewlet {
    weak var targetPanoramaView: PanoramaView?
    var mapScale: CGFloat = 0.1
    
    override func draw(in context: CGContext) {
        // Background
        context.setFillColor(XColor.black.withAlphaComponent(0.7).cgColor)
        context.fill(bounds)
        
        // Border
        context.setStrokeColor(XColor.white.cgColor)
        context.setLineWidth(1)
        context.stroke(bounds)
        
        guard let panoramaView = targetPanoramaView,
              let panorama = panoramaView.panorama else { return }
        
        // Draw miniature content
        context.saveGState()
        context.scaleBy(x: mapScale, y: mapScale)
        
        // Clip to scaled bounds
        let scaledBounds = CGRect(x: 0, y: 0, 
                                 width: bounds.width / mapScale,
                                 height: bounds.height / mapScale)
        context.clip(to: scaledBounds)
        
        // Draw panorama content at small scale
        panorama.draw(in: context)
        context.restoreGState()
        
        // Draw viewport indicator
        drawViewportIndicator(in: context)
    }
    
    private func drawViewportIndicator(in context: CGContext) {
        guard let panoramaView = targetPanoramaView else { return }
        
        let visibleRect = panoramaView.scrollView.bounds
        let scaledRect = CGRect(
            x: visibleRect.origin.x * mapScale,
            y: visibleRect.origin.y * mapScale,
            width: visibleRect.width * mapScale,
            height: visibleRect.height * mapScale
        )
        
        // Draw viewport rectangle
        context.setStrokeColor(XColor.systemYellow.cgColor)
        context.setLineWidth(2)
        context.stroke(scaledRect)
        
        // Fill with transparent color
        context.setFillColor(XColor.systemYellow.withAlphaComponent(0.1).cgColor)
        context.fill(scaledRect)
    }
    
    override func singleAction() {
        // Handle click to navigate
        // Implementation depends on your needs
    }
}

// Usage in your panorama:
class DocumentPanorama: Panorama {
    let miniMap = MiniMapViewlet(frame: CGRect(x: 10, y: 10, width: 200, height: 150))
    
    override func didMove(to panoramaView: PanoramaView?) {
        super.didMove(to: panoramaView)
        
        if let panoramaView = panoramaView {
            miniMap.targetPanoramaView = panoramaView
            addViewlet(miniMap)
            
            // Update mini-map when scrolling
            NotificationCenter.default.addObserver(
                self, 
                selector: #selector(scrollViewDidChange),
                name: NSScrollView.didLiveScrollNotification,
                object: panoramaView.scrollView
            )
        }
    }
    
    @objc private func scrollViewDidChange() {
        miniMap.setNeedsDisplay()
    }
}
```

---

## Complete Example Project

Here's a complete example of a simple drawing application:

### AppDelegate.swift (iOS)

```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13.0, *) {
            // Scene delegate will handle window creation
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = DrawingViewController()
            window?.makeKeyAndVisible()
        }
        
        return true
    }
}
```

### DrawingViewController.swift

```swift
import UIKit
import Panorama

class DrawingViewController: UIViewController {
    private var panoramaView: PanoramaView!
    private var drawingPanorama: DrawingPanorama!
    private var colorPicker: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Panorama Drawing"
        view.backgroundColor = .systemBackground
        
        setupPanoramaView()
        setupToolbar()
        setupNavigationBar()
    }
    
    private func setupPanoramaView() {
        // Create PanoramaView
        panoramaView = PanoramaView(frame: view.bounds)
        panoramaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(panoramaView)
        
        // Create DrawingPanorama
        let canvasSize = CGSize(width: 2048, height: 2048)
        drawingPanorama = DrawingPanorama(frame: CGRect(origin: .zero, size: canvasSize))
        
        // Configure panorama
        drawingPanorama.minimumZoomScale = 0.25
        drawingPanorama.maximumZoomScale = 5.0
        
        // Attach to view
        panoramaView.panorama = drawingPanorama
        panoramaView.contentInset = 20
        
        // Initial zoom
        DispatchQueue.main.async {
            self.panoramaView.scaleToFit()
        }
    }
    
    private func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Color picker
        colorPicker = UISegmentedControl(items: ["Black", "Red", "Blue", "Green"])
        colorPicker.selectedSegmentIndex = 0
        colorPicker.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        
        // Width slider
        let widthSlider = UISlider()
        widthSlider.minimumValue = 1
        widthSlider.maximumValue = 20
        widthSlider.value = 2
        widthSlider.addTarget(self, action: #selector(widthChanged(_:)), for: .valueChanged)
        widthSlider.frame.size.width = 100
        
        toolbar.items = [
            UIBarButtonItem(customView: colorPicker),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: widthSlider),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearCanvas)),
            UIBarButtonItem(title: "Undo", style: .plain, target: self, action: #selector(undo))
        ]
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Fit", style: .plain, target: self, action: #selector(fitToScreen)),
            UIBarButtonItem(title: "1:1", style: .plain, target: self, action: #selector(resetZoom))
        ]
    }
    
    // MARK: - Actions
    
    @objc private func colorChanged() {
        let colors: [UIColor] = [.black, .red, .blue, .green]
        drawingPanorama.strokeColor = colors[colorPicker.selectedSegmentIndex]
    }
    
    @objc private func widthChanged(_ sender: UISlider) {
        drawingPanorama.strokeWidth = CGFloat(sender.value)
    }
    
    @objc private func clearCanvas() {
        let alert = UIAlertController(title: "Clear Canvas", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            self.drawingPanorama.clear()
        })
        present(alert, animated: true)
    }
    
    @objc private func undo() {
        drawingPanorama.undo()
    }
    
    @objc private func fitToScreen() {
        panoramaView.scaleToFit()
    }
    
    @objc private func resetZoom() {
        UIView.animate(withDuration: 0.3) {
            self.panoramaView.zoomScale = 1.0
        }
    }
}
```

### Info.plist Configuration

Add these keys for a better experience:

```xml
<key>UIRequiresFullScreen</key>
<false/>
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>
```

---

## Common Patterns and Tips

### 1. Implementing Undo/Redo

```swift
class UndoablePanorama: Panorama {
    private var undoManager = UndoManager()
    
    func performAction(action: @escaping () -> Void, undo: @escaping () -> Void, name: String) {
        // Perform the action
        action()
        
        // Register undo
        undoManager.registerUndo(withTarget: self) { target in
            target.performAction(action: undo, undo: action, name: "Undo " + name)
        }
        undoManager.setActionName(name)
        
        setNeedsDisplay()
    }
    
    func undo() {
        undoManager.undo()
        setNeedsDisplay()
    }
    
    func redo() {
        undoManager.redo()
        setNeedsDisplay()
    }
}
```

### 2. Exporting Content

```swift
extension Panorama {
    func exportToImage(scale: CGFloat = 1.0) -> XImage? {
        #if os(iOS)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        draw(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
        #elseif os(macOS)
        let image = NSImage(size: bounds.size)
        image.lockFocus()
        guard let context = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            return nil
        }
        
        draw(in: context)
        image.unlockFocus()
        
        return image
        #endif
    }
    
    func exportToPDF(url: URL) throws {
        let pdfContext = CGContext(url as CFURL, mediaBox: &bounds, nil)
        pdfContext?.beginPage()
        
        if let context = pdfContext {
            draw(in: context)
        }
        
        pdfContext?.endPage()
        pdfContext?.closePDF()
    }
}
```

### 3. Performance Monitoring

```swift
#if DEBUG
class PerformancePanorama: Panorama {
    private var frameCount = 0
    private var lastFrameTime: TimeInterval = 0
    private var fps: Double = 0
    
    override func draw(in context: CGContext) {
        let startTime = CACurrentMediaTime()
        
        // Your drawing code
        super.draw(in: context)
        
        // Calculate FPS
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastFrameTime
        if deltaTime > 0.1 {
            fps = Double(frameCount) / deltaTime
            frameCount = 0
            lastFrameTime = currentTime
        }
        frameCount += 1
        
        // Draw FPS counter
        drawFPS(in: context)
        
        // Log slow frames
        let drawTime = CACurrentMediaTime() - startTime
        if drawTime > 0.016 { // Slower than 60fps
            print("⚠️ Slow frame: \(drawTime * 1000)ms")
        }
    }
    
    private func drawFPS(in context: CGContext) {
        let fpsText = String(format: "FPS: %.1f", fps)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: XFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: fps < 30 ? XColor.red : XColor.green
        ]
        
        let attrString = NSAttributedString(string: fpsText, attributes: attributes)
        let rect = CGRect(x: 10, y: 10, width: 100, height: 20)
        
        // Draw background
        context.setFillColor(XColor.black.withAlphaComponent(0.5).cgColor)
        context.fill(rect)
        
        // Draw text
        drawText(in: context, rect: rect, attributedString: attrString, verticalAlignment: .center)
    }
}
#endif
```

### 4. Touch/Mouse Coordinate Conversion

```swift
extension XEvent {
    func location(in panorama: Panorama) -> CGPoint? {
        #if os(iOS)
        // For UITouch
        if let touch = self.allTouches?.first,
           let panoramaView = panorama.panoramaView {
            let locationInContentView = touch.location(in: panoramaView.contentView)
            return panorama.convert(locationInContentView, from: panoramaView.contentView)
        }
        #elseif os(macOS)
        // For NSEvent
        if let panoramaView = panorama.panoramaView {
            let locationInWindow = self.locationInWindow
            let locationInContentView = panoramaView.contentView.convert(locationInWindow, from: nil)
            return panorama.transformFromPanorama?.transform(locationInContentView) ?? locationInContentView
        }
        #endif
        return nil
    }
}
```

## Troubleshooting Common Issues

### Issue: Content Not Visible

**Checklist:**
1. Verify panorama bounds are non-zero
2. Check if panorama is attached to PanoramaView
3. Ensure drawing code is in `draw(in:)` method
4. Call `setNeedsDisplay()` after changes

```swift
// Debug helper
func debugPanorama() {
    print("Panorama bounds: \(panorama.bounds)")
    print("Attached to view: \(panorama.panoramaView != nil)")
    print("View bounds: \(panoramaView.bounds)")
    print("Zoom scale: \(panoramaView.zoomScale)")
}
```

### Issue: Touch/Click Events Not Working

**Solution:**
```swift
// Ensure viewlet is enabled
viewlet.isEnabled = true

// Check hit testing
override func findViewlet(at point: CGPoint) -> Viewlet? {
    let result = super.findViewlet(at: point)
    print("Hit test at \(point): \(result)")
    return result
}
```

### Issue: Poor Scrolling Performance

**Optimizations:**
1. Implement viewport culling
2. Cache complex drawings
3. Use appropriate zoom scale limits
4. Profile with Instruments

```swift
override func draw(in context: CGContext) {
    // Only draw visible content
    guard let visibleRect = panoramaView?.scrollView.bounds else { return }
    
    // Cull objects outside visible area
    let objectsToDraw = objects.filter { object in
        return object.frame.intersects(visibleRect)
    }
    
    // Draw only visible objects
    for object in objectsToDraw {
        object.draw(in: context)
    }
}
```

### Issue: Memory Leaks

**Prevention:**
1. Use weak references for delegates
2. Remove observers in `deinit`
3. Clear timers when done

```swift
class SafePanorama: Panorama {
    private weak var delegate: PanoramaDelegate?
    private var timer: Timer?
    
    override func didMove(to panoramaView: PanoramaView?) {
        super.didMove(to: panoramaView)
        
        if panoramaView != nil {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.update()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
        NotificationCenter.default.removeObserver(self)
    }
}
```

## Platform-Specific Considerations

### iOS Specific

1. **Handle memory warnings:**
```swift
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Clear caches
    imageCache.removeAll()
}
```

2. **Support Dynamic Type:**
```swift
override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
        updateFonts()
        setNeedsDisplay()
    }
}
```

### macOS Specific

1. **Handle window resizing:**
```swift
override func viewDidLayout() {
    super.viewDidLayout()
    panoramaView.setNeedsDisplay()
}
```

2. **Support Dark Mode:**
```swift
override func updateLayer() {
    super.updateLayer()
    // Update colors for current appearance
    updateColors()
    panorama.setNeedsDisplay()
}
```

## Next Steps

Now that you have a solid understanding of Panorama, here are some ideas to explore:

1. **Add Persistence**: Save and load drawings
2. **Network Collaboration**: Real-time collaborative drawing
3. **Advanced Tools**: Shapes, text, images
4. **Layers**: Implement a layer system
5. **Animations**: Animate viewlet properties
6. **Custom Gestures**: Implement rotate and scale gestures
7. **Export**: Export to PDF or image formats

## Resources

- [API Reference](API_Reference.md) - Detailed API documentation
- [Migration Guide](Migration_Guide.md) - Upgrading from 1.x
- [Xcode Configuration Guide](Xcode_Configuration_Guide.md) - Detailed Xcode setup
- [GitHub Repository](https://github.com/yourusername/Panorama) - Source code
- [Sample Projects](https://github.com/yourusername/Panorama/tree/main/Examples) - More examples

## Getting Help

If you run into issues:

1. Enable debug logging with environment variables
2. Check the [GitHub Issues](https://github.com/yourusername/Panorama/issues)
3. Ask on [GitHub Discussions](https://github.com/yourusername/Panorama/discussions)
4. Review the [API Reference](API_Reference.md)
5. Profile with Instruments for performance issues

Happy coding with Panorama!