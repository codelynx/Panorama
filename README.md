# Panorama 

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)

`Panorama` is a Swift framework for building Core Graphics-based 2D scrollable and zoomable applications that work seamlessly on both iOS and macOS. It abstracts away the platform differences between UIView/NSView and UIScrollView/NSScrollView, providing a unified API for creating high-performance graphics applications.

## ✨ Features

- 🎯 **Cross-Platform**: Single codebase for iOS and macOS
- 🚀 **High Performance**: Direct Core Graphics rendering
- 🔍 **Zooming & Panning**: Built-in support for smooth interactions
- 📐 **Coordinate System Management**: Handles platform differences automatically
- 🎨 **Viewlet System**: Lightweight custom drawing components
- 📱 **Touch & Mouse Support**: Unified event handling
- 🧩 **Extensible**: Easy to create custom viewlets

## Cross Platform

As you can see, Panorama defines some type aliases to be able to use for both iOS and macOS.  So, your `MyView` can be a subclasss of `XView`, and it is `UIView` on iOS, `NSView` on macOS.  This makes your coding life a bit easier, but you still need `#if os()` directives to write platform specific code. 

```
#if os(iOS)

import UIKit
typealias XView = UIView
typealias XImage = UIImage
typealias XColor = UIColor
typealias XBezierPath = UIBezierPath
typealias XScrollView = UIScrollView
typealias XScrollViewDelegate = UIScrollViewDelegate
typealias XViewController = UIViewController

#elseif os(macOS)

import Cocoa
typealias XView = NSView
typealias XImage = NSImage
typealias XColor = NSColor
typealias XBezierPath = NSBezierPath
typealias XScrollView = NSScrollView
typealias XViewController = NSViewController

protocol XScrollViewDelegate {}

#endif
```

For example, you may still have to use `#if os()` directive and write similar code for iOS and macOS, but still.  Still much than maintaining the separate code base.


```
class MyView: XView {
	// ...
	#if os(iOS)
	override func layoutSubviews() {
		super.layoutSubviews()
		// some layout code here
	}
	#endif
	
	#if os(macOS)
	override func layout() {
		super.layout()
		// some layout code here
	}
	#endif
```

## Archiecture

The cross platform related utility code are not the main dish here.  In `Panorama` following two classes are the main dish here.  

* Panorama
* PanoramaView

### Panorama

`Panorama` is a class that represent visual content, and your subclass override `draw()` method to draw content with Core Graphics.  `Panorama` is not a subclass of `UIView` nor `NSView`, but will work like a view.  So you don't have to worry about behavior differences of UI/NSView nor UI/NSScrollView differences to display a core graphics content.

```
	override func draw(in context: CGContext) {
		// draw with core graphics
	}
```

Here are the basic properties for the `Panorama`. 

```
	var bounds: CGRect
	var maximumZoomScale: CGFloat
	var minimumZoomScale: CGFloat
```

Here is the good override point to initialize the panorama, because this `Panorama` is set to be displayed.  Be aware, when this scene is removed from the view, this is also get called with `nil`.

```
	override func didMove(to panoramaView: PanoramaView?) {
		// 
	}
```

touch and mouse related events are propagated to Panorama, you can override appropriate methods to handle events.  You need to `#if os()` directive to implement for your desired platform.

#### Touch related methods

```
	func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
	func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
	func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
```

#### Mouse related methods

```
	func mouseDown(with event: NSEvent)
	func mouseDragged(with event: NSEvent)
	func mouseUp(with event: NSEvent)
	func mouseMoved(with event: NSEvent)
	func rightMouseDown(with event: NSEvent)
	func rightMouseDragged(with event: NSEvent)
	func rightMouseUp(with event: NSEvent)
	func otherMouseDown(with event: NSEvent)
	func otherMouseDragged(with event: NSEvent)
	func otherMouseUp(with event: NSEvent)
	func mouseExited(with event: NSEvent)
	func mouseEntered(with event: NSEvent)
```

You may use `location(in: Panorama)` method for both `NSEvent` or `UITouch`, so touch location can be handled easily.

If you like to use `GestureRecognizer`, stay tuned.

### PanoramaView

`PanoramaView` is a subclass of UIView/NSView.  It constructs necessary subcomponents like UI/NSScrollView and others by code.  So, you only needs to place `PanoramaView` directory on your storyboard, and your view controller or other part of your code need to set your subclass of Panorama to this PanoramaView.

## Behind the PanoramaView

In fact, there are some supporting views behind the `PanoramaView`.   `PanoramaContentView` is the one who sits within the scroll view and represent `Panorama`'s content and coordinate system, so `PanoramaContentView`'s width and height actually represents `Panorama`'s content size.   Then when you zoom or scroll your screen, `PanoramaContentView` is the one actually scrolled or zoomed.  But strange to say, both `PanoramaContentView` and `UI/NSScrollView` are transparent and cannot be seen on your screen directory.

On the other hand, the view actually to be displayed is `PanoramaBackView`.  `PanoramaBackView` just sits behind `UI/NSScrollView` it does not zoomed or scrolled.  But when it came a moment to display `Panorama`, `PanoramaBackView` is the one to organize drawing process.  `PanoramaBackView` usues `PanoramaContentView`'s coordinate system to setup graphic context, and call `Panorama`'s `draw()` method.  So `Panorama` doesn't have worry about any drawing transformation, just draw things on your own coordinate systems.  

When you touch or click on your screen, `PanoramaContentView` is the one to receive those events, and forwards them to `Panorama`.  Since, `PanoramaContentView`'s local coordinate represents `Panorama` coordinate, touch location and mouse location should not require complex math.  However, we provide `location(in: Panorama)` method for both `UITouch` and `NSEvent` as an extension, so you may use those methods to find location in `Panorama`.

All supported views will be constructed by `PanoramaView`, and you don't have to worry about them while writing code Panorama.  But when you needs to add some features on `PanoramaView` or supporting more events, it is still good to know.

<img width="640" src="https://qiita-image-store.s3.amazonaws.com/0/65634/4c1060a7-7c2d-0019-1ee4-7ad9e87dbebe.png"/>


## Sample App

This project contains living example how to use `Panorama` as a drawing app. `MyPanorama` is a subclass of `Panorama` and handles touch or mouse event to draw a picture.  It does not provide a feature to erase or save.  These features can be your practice if you are interested in learning `Panorama`.


![Screen Shot.png](https://qiita-image-store.s3.amazonaws.com/0/65634/64d86514-fb20-0f68-5c5d-f566d094110e.png)

## Requirements

- **Swift 5.9+** (modernized from original Swift 3.0.2)
- **iOS 13.0+** / **macOS 10.13+**
- **Xcode 15.0+**

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Panorama.git", from: "2.0.0")
]
```



