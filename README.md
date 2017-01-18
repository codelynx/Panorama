# Panorama 


`Panorama` is a utility set of code for Core Graphics based 2D scrollable app for both iOS and macOS.  If you like to develop an 2D zoomable scrollable content app for both iOS and macOS.  There are so many pain points because of the differences of UIView/NSView, UIScrollView/NSScrollView and other classes.  Also there are some differences in the graphics coordinate system.  This `Panorama` may be fit into your needs for developing 2D zoomable scrollable core graphics based app.

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


## Sample App

This project contains living example how to use `Panorama` as a drawing app. `MyPanorama` is a subclass of `Panorama` and handles touch or mouse event to draw a picture.  It does not provide a feature to erase or save.  These features can be your practice if you are interested in learning `Panorama`.


![Screen Shot.png](https://qiita-image-store.s3.amazonaws.com/0/65634/64d86514-fb20-0f68-5c5d-f566d094110e.png)

## Xcode Version

```
Xcode Version 8.2.1 (8C1002)
Apple Swift version 3.0.2 (swiftlang-800.0.63 clang-800.0.42.1)
```



