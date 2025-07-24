# Migration Guide - Panorama 1.x to 2.0

This guide helps you migrate your existing Panorama 1.x code to version 2.0, which includes Swift 5.9+ modernization and API improvements.

## Overview of Changes

Panorama 2.0 brings significant improvements while maintaining the core architecture:

- **Swift 5.9+ requirement** (previously Swift 3.0.2)
- **Modernized APIs** with better type safety
- **Improved documentation** and code organization
- **Breaking changes** to some property names and method signatures
- **XPlatform dependency** replaces ZKit

## Breaking Changes

### 1. Swift Version Requirement

**Before (1.x):**
- Swift 3.0.2+
- Xcode 8.2+

**After (2.0):**
- Swift 5.9+
- Xcode 15.0+
- iOS 13.0+ / macOS 10.13+

### 2. Property Name Changes

#### Viewlet.enabled → isEnabled

**Before:**
```swift
if viewlet.enabled {
    // Handle enabled state
}
```

**After:**
```swift
if viewlet.isEnabled {
    // Handle enabled state
}
```

### 3. Method Signature Changes

#### findViewlet Parameter Label

**Before:**
```swift
let viewlet = panorama.findViewlet(point: location)
```

**After:**
```swift
let viewlet = panorama.findViewlet(at: location)
```

#### NSView Extension Methods (macOS)

**Before:**
```swift
view.sendSubview(toBack: subview)
view.bringSubview(toFront: subview)
view.replaceSubview(subview: oldView, with: newView)
```

**After:**
```swift
view.sendSubview(toBack: subview)
view.bringSubview(toFront: subview)
// replaceSubview is now provided by AppKit directly
view.replaceSubview(oldView, with: newView)
```

### 4. ViewletStyle API Changes

#### Direct Property Access → Method Calls

**Before:**
```swift
style.foregroundColors = [.normal: XColor.white]
style.backgroundFills = [.normal: ViewletFill.solid(.blue)]
```

**After:**
```swift
style.setForegroundColor(.white, for: .normal)
style.setBackgroundFill(.solid(.blue), for: .normal)
```

### 5. Gradient API Changes

#### Gradient Initialization

**Before:**
```swift
let gradient = Gradient(locations: [(0, XColor.red), (1, XColor.blue)])
```

**After:**
```swift
let gradient = Gradient(colorStops: [(0, XColor.red), (1, XColor.blue)])
```

#### Gradient Type Change

**Before:**
```swift
class Gradient {
    // Reference type
}
```

**After:**
```swift
struct Gradient {
    // Value type - provides better performance and safety
}
```

### 6. ViewletFill Method Changes

#### Fill Method Parameters

**Before:**
```swift
fill.fill(rect: bounds, context: context)
```

**After:**
```swift
fill.fill(rect: bounds, in: context)
```

### 7. Dependency Changes

#### ZKit → XPlatform

**Before:**
```swift
import ZKit
```

**After:**
```swift
// Remove ZKit import - functionality is built-in or use XPlatform if needed
```

## New Features in 2.0

### 1. Enhanced Type Safety

- All enums now conform to `CaseIterable`
- Better optional handling with guard statements
- Reduced force unwrapping

### 2. Improved ViewletStyle

```swift
// New gradient directions
let fill = ViewletFill.linearGradient(
    direction: .diagonal,  // New: diagonal gradients
    colors: [.red, .blue]
)

// Better style inheritance
let childStyle = ViewletStyle(name: "Child", parent: parentStyle)
```

### 3. Better Memory Management

- Proper `[weak self]` in closures
- Fixed potential retain cycles
- Cleaner parent-child relationships

### 4. Modern Swift Features

```swift
// Property access with modern syntax
private(set) var scrollView: XScrollView

// Better error handling patterns
guard let viewlet = findViewlet(at: point) else { return }

// Cleaner optional chaining
panorama?.setNeedsDisplay()
```

## Step-by-Step Migration

### Step 1: Update Dependencies

**Package.swift:**
```swift
dependencies: [
    // Remove ZKit
    // .package(url: "https://github.com/codelynx/ZKit", from: "1.0.0")
    
    // Add XPlatform if needed
    .package(url: "https://github.com/codelynx/XPlatform", from: "1.0.0"),
    
    // Update Panorama
    .package(url: "https://github.com/yourusername/Panorama", from: "2.0.0")
]
```

### Step 2: Update Property References

Search and replace throughout your codebase:
- `viewlet.enabled` → `viewlet.isEnabled`
- `findViewlet(point:` → `findViewlet(at:`
- `Gradient(locations:` → `Gradient(colorStops:`

### Step 3: Update ViewletStyle Usage

**Before:**
```swift
let style = ViewletStyle()
style.foregroundColors[.normal] = .white
style.backgroundFills[.highlighted] = .solid(.blue)
```

**After:**
```swift
let style = ViewletStyle()
style.setForegroundColor(.white, for: .normal)
style.setBackgroundFill(.solid(.blue), for: .highlighted)
```

### Step 4: Update Fill Method Calls

**Before:**
```swift
override func draw(in context: CGContext) {
    backgroundFill?.fill(rect: bounds, context: context)
}
```

**After:**
```swift
override func draw(in context: CGContext) {
    backgroundFill?.fill(rect: bounds, in: context)
}
```

### Step 5: Remove ZKit Imports

Remove any `import ZKit` statements from your code. The functionality you need is either built into Panorama or available through XPlatform.

### Step 6: Test Thoroughly

1. Build your project and fix any remaining compilation errors
2. Run your test suite
3. Test zoom and pan functionality
4. Verify event handling works correctly on both platforms
5. Check that custom viewlets render properly

## Common Issues and Solutions

### Issue: "Cannot find 'enabled' in scope"

**Solution:** Replace with `isEnabled`

### Issue: "Incorrect argument label in call"

**Solution:** Check the migration guide for the specific method and update the parameter labels

### Issue: "'foregroundColors' is inaccessible due to 'private' protection level"

**Solution:** Use the public setter methods instead of direct property access

### Issue: "Value of type 'Gradient' has no member 'someMethod'"

**Solution:** Gradient is now a struct. Check if you're trying to use reference semantics and adjust accordingly

## Best Practices for 2.0

1. **Use Modern Swift Patterns:**
   ```swift
   // Good
   guard let panorama = self.panorama else { return }
   
   // Avoid
   if let panorama = self.panorama {
       // lots of code
   }
   ```

2. **Leverage Type Safety:**
   ```swift
   // Use CaseIterable for enums
   for state in ViewletState.allCases {
       // Process all states
   }
   ```

3. **Proper Memory Management:**
   ```swift
   Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
       guard let self = self else { return }
       self.handleTimeout()
   }
   ```

## Getting Help

If you encounter issues during migration:

1. Check the [API Reference](API_Reference.md) for detailed documentation
2. Review the [CHANGELOG](CHANGELOG.md) for all changes
3. Open an issue on [GitHub](https://github.com/yourusername/Panorama/issues)
4. Join the discussion on [GitHub Discussions](https://github.com/yourusername/Panorama/discussions)

## Summary

While Panorama 2.0 includes several breaking changes, the migration process is straightforward. The improvements in type safety, performance, and modern Swift support make the upgrade worthwhile. Most projects can be migrated in a few hours by following this guide.

The core architecture remains the same, so your existing knowledge of Panorama still applies. The changes primarily improve the developer experience and code maintainability.