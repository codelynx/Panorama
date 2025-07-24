# Panorama 

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)

Panorama is a Swift framework for building Core Graphics-based 2D scrollable and zoomable applications that work seamlessly on both iOS and macOS. It abstracts away the platform differences between UIKit and AppKit, providing a unified API for creating high-performance graphics applications.

## ✨ Features

- 🎯 **Cross-Platform**: Single codebase for iOS and macOS
- 🚀 **High Performance**: Direct Core Graphics rendering
- 🔍 **Zooming & Panning**: Built-in support for smooth interactions
- 📐 **Coordinate System Management**: Handles platform differences automatically
- 🎨 **Viewlet System**: Lightweight custom drawing components
- 📱 **Touch & Mouse Support**: Unified event handling
- 🧩 **Extensible**: Easy to create custom viewlets
- 🛡️ **Type Safe**: Modern Swift 5.9+ with improved type safety

## 📋 Requirements

- Swift 5.9+
- iOS 13.0+ / macOS 10.13+
- Xcode 15.0+

## 📦 Installation

### Swift Package Manager

Add Panorama to your project by adding the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/codelynx/Panorama.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version 1.0.0 or later

## 🚀 Quick Start

### Basic Setup

1. Create a subclass of `Panorama`:

```swift
import Panorama

class MyPanorama: Panorama {
    override func draw(in context: CGContext) {
        // Your Core Graphics drawing code here
        context.setFillColor(XColor.blue.cgColor)
        context.fill(CGRect(x: 100, y: 100, width: 200, height: 200))
    }
    
    override func didMove(to panoramaView: PanoramaView?) {
        super.didMove(to: panoramaView)
        // Setup code when panorama is attached to a view
    }
}
```

2. Set up the PanoramaView in your view controller:

```swift
class ViewController: XViewController {
    @IBOutlet weak var panoramaView: PanoramaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure your panorama
        let myPanorama = MyPanorama(frame: CGRect(x: 0, y: 0, width: 2048, height: 2048))
        myPanorama.minimumZoomScale = 0.5
        myPanorama.maximumZoomScale = 4.0
        
        // Attach to the view
        panoramaView.panorama = myPanorama
    }
}
```

### Event Handling

Handle platform-specific events with unified methods:

```swift
class InteractivePanorama: Panorama {
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        // Handle touch
    }
    #endif
    
    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        // Handle mouse click
    }
    #endif
}
```

## 🏗️ Architecture

### Core Components

#### Panorama
The main content container that manages your drawable scene. It's not a UIView/NSView subclass but provides view-like functionality with platform-agnostic APIs.

#### PanoramaView
A UIView/NSView subclass that hosts the panorama content and manages scrolling/zooming behavior. It automatically creates the necessary scroll view hierarchy.

#### Viewlet System
Lightweight drawable components that can be composed hierarchically:

```swift
class CustomViewlet: Viewlet {
    override func draw(in context: CGContext) {
        // Custom drawing code
    }
    
    override func singleAction() {
        // Handle single tap/click
    }
}
```

### Architecture Diagram

```
┌─────────────────┐
│  PanoramaView   │ (UIView/NSView)
├─────────────────┤
│ ┌─────────────┐ │
│ │  BackView   │ │ ← Renders content
│ └─────────────┘ │
│ ┌─────────────┐ │
│ │ ScrollView  │ │ ← Handles scrolling
│ │ ┌─────────┐ │ │
│ │ │Content  │ │ │ ← Captures events
│ │ │  View   │ │ │
│ │ └─────────┘ │ │
│ └─────────────┘ │
└─────────────────┘
         ↓
    ┌─────────┐
    │Panorama │ ← Your content
    └─────────┘
```

## 📖 Advanced Usage

### Custom Viewlets

Create reusable drawing components:

```swift
class ButtonViewlet: Viewlet {
    var title: String = "Button"
    var isHighlighted = false
    
    override func draw(in context: CGContext) {
        // Draw background
        let fillColor = isHighlighted ? XColor.blue : XColor.gray
        context.setFillColor(fillColor.cgColor)
        context.fillEllipse(in: bounds)
        
        // Draw text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: XFont.systemFont(ofSize: 16),
            .foregroundColor: XColor.white
        ]
        let string = NSAttributedString(string: title, attributes: attributes)
        drawText(in: context, rect: bounds, attributedString: string, verticalAlignment: .center)
    }
    
    override func singleAction() {
        print("Button tapped: \(title)")
    }
}
```

### Styling System

Apply consistent styling across viewlets:

```swift
let style = ViewletStyle()
style.cornerRadius = 8.0
style.font = XFont.boldSystemFont(ofSize: 14)
style.setForegroundColor(.white, for: .normal)
style.setForegroundColor(.gray, for: .highlighted)
style.setBackgroundFill(.linearGradient(direction: .vertical, colors: [.blue, .purple]), for: .normal)
```

### Cross-Platform Type Aliases

Panorama provides unified type aliases for platform-specific types:

| Alias | iOS | macOS |
|-------|-----|-------|
| `XView` | `UIView` | `NSView` |
| `XViewController` | `UIViewController` | `NSViewController` |
| `XColor` | `UIColor` | `NSColor` |
| `XImage` | `UIImage` | `NSImage` |
| `XFont` | `UIFont` | `NSFont` |
| `XBezierPath` | `UIBezierPath` | `NSBezierPath` |
| `XScrollView` | `UIScrollView` | `NSScrollView` |

## 🎯 Use Cases

Panorama is perfect for:
- 🎨 Drawing and sketching applications
- 📊 Diagramming and flowchart tools
- 🗺️ Map viewers and floor plan applications
- 📐 Technical drawing and CAD-like applications
- 🖼️ Image viewers with annotation support
- 🎮 2D games and interactive visualizations

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🙏 Acknowledgments

- Original framework by Kaz Yoshikawa
- Modernized to Swift 5.9+ with community contributions
- Uses [XPlatform](https://github.com/codelynx/XPlatform) for additional cross-platform utilities

## 📚 Documentation

For detailed API documentation, see [API Reference](Documents/API_Reference.md).

For migration from version 1.x, see [Migration Guide](Documents/Migration_Guide.md).

## 💬 Support

- 🐛 Issues: [GitHub Issues](https://github.com/codelynx/Panorama/issues)