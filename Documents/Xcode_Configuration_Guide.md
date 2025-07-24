# Xcode Configuration Guide for Panorama

This guide covers all the Xcode-specific configuration needed to use Panorama effectively in your projects.

## Table of Contents

1. [Project Setup](#project-setup)
2. [Build Settings](#build-settings)
3. [Storyboard Configuration](#storyboard-configuration)
4. [SwiftUI Integration](#swiftui-integration)
5. [Cross-Platform Targets](#cross-platform-targets)
6. [Debugging Configuration](#debugging-configuration)
7. [Performance Optimization](#performance-optimization)
8. [Common Issues](#common-issues)

---

## Project Setup

### Creating a New Project

1. **Open Xcode** → File → New → Project
2. Choose platform:
   - **iOS**: App template
   - **macOS**: App template
   - **Multiplatform**: Multiplatform App (for both)

3. Configure project settings:
   ```
   Product Name: YourAppName
   Team: Your Team
   Organization Identifier: com.yourcompany
   Interface: Storyboard (or SwiftUI)
   Language: Swift
   Use Core Data: No (unless needed)
   Include Tests: Yes (recommended)
   ```

### Adding Panorama via Swift Package Manager

1. Select your project in the navigator
2. Select your app target
3. Go to "General" tab → "Frameworks, Libraries, and Embedded Content"
4. Click "+" → "Add Package Dependency"
5. Enter: `https://github.com/codelynx/Panorama.git`
6. Version rules: "Up to Next Major Version" → 2.0.0

### Project Structure Recommendations

```
YourPanoramaApp/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift (iOS 13+)
│   └── Info.plist
├── Views/
│   ├── Main.storyboard
│   └── LaunchScreen.storyboard
├── ViewControllers/
│   ├── MainViewController.swift
│   └── DrawingViewController.swift
├── Panoramas/
│   ├── DrawingPanorama.swift
│   ├── GridPanorama.swift
│   └── CustomViewlets.swift
├── Resources/
│   └── Assets.xcassets
└── Supporting Files/
    └── Configuration.swift
```

---

## Build Settings

### Recommended Build Settings

Navigate to your target's Build Settings and configure:

#### Swift Compiler - Language
- **Swift Language Version**: Swift 5
- **Enable Modules**: Yes
- **Enable Bitcode**: No (for better debugging)

#### Deployment
- **iOS Deployment Target**: 13.0 or later
- **macOS Deployment Target**: 10.13 or later

#### Signing & Capabilities
- **Automatically manage signing**: Yes (for development)
- **Provisioning Profile**: Automatic

#### Other Swift Flags
For debugging, add:
```
-D DEBUG
```

### Build Configurations

Create separate configurations for different scenarios:

1. Select project → Info tab
2. Duplicate "Debug" configuration
3. Name it "Debug-Performance" for performance testing
4. Configure settings:
   - **Optimization Level**: Optimize for Speed [-O]
   - **Enable Testability**: No

---

## Storyboard Configuration

### Adding PanoramaView to Storyboard

1. Open your storyboard
2. Drag a `UIView` (iOS) or `NSView` (macOS) from the Object Library
3. Select the view and go to Identity Inspector
4. Set **Custom Class**:
   - Class: `PanoramaView`
   - Module: `Panorama`

### Setting Up Constraints

For full-screen panorama:

```xml
<!-- Leading -->
<constraint firstItem="panoramaView" firstAttribute="leading" 
            secondItem="safeArea" secondAttribute="leading" constant="0"/>

<!-- Trailing -->
<constraint firstItem="panoramaView" firstAttribute="trailing" 
            secondItem="safeArea" secondAttribute="trailing" constant="0"/>

<!-- Top -->
<constraint firstItem="panoramaView" firstAttribute="top" 
            secondItem="safeArea" secondAttribute="top" constant="0"/>

<!-- Bottom -->
<constraint firstItem="panoramaView" firstAttribute="bottom" 
            secondItem="safeArea" secondAttribute="bottom" constant="0"/>
```

### Creating IBOutlet Connections

1. Open Assistant Editor (⌥⌘↩)
2. Control-drag from PanoramaView to your ViewController:

```swift
class ViewController: UIViewController {
    @IBOutlet weak var panoramaView: PanoramaView!
    
    // Optional: Multiple panorama views
    @IBOutlet weak var mainPanoramaView: PanoramaView!
    @IBOutlet weak var miniMapView: PanoramaView!
}
```

### Storyboard Best Practices

1. **Use Size Classes** for adaptive layouts
2. **Set placeholder intrinsic size** for design-time preview:
   - Select PanoramaView
   - Size Inspector → Intrinsic Size → Placeholder
   - Width: 375, Height: 667

3. **Add User Defined Runtime Attributes** if needed:
   ```
   Key Path: layer.borderWidth
   Type: Number
   Value: 1
   ```

---

## SwiftUI Integration

### Creating a SwiftUI Wrapper

```swift
import SwiftUI
import Panorama

struct PanoramaViewRepresentable: UIViewRepresentable {
    let panorama: Panorama
    @Binding var zoomScale: CGFloat
    var contentInset: CGFloat = 20
    
    func makeUIView(context: Context) -> PanoramaView {
        let panoramaView = PanoramaView()
        panoramaView.panorama = panorama
        panoramaView.contentInset = contentInset
        return panoramaView
    }
    
    func updateUIView(_ panoramaView: PanoramaView, context: Context) {
        panoramaView.zoomScale = zoomScale
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: PanoramaViewRepresentable
        
        init(_ parent: PanoramaViewRepresentable) {
            self.parent = parent
        }
    }
}
```

### Using in SwiftUI

```swift
struct ContentView: View {
    @State private var zoomScale: CGFloat = 1.0
    let drawingPanorama = DrawingPanorama(frame: CGRect(x: 0, y: 0, width: 2048, height: 2048))
    
    var body: some View {
        VStack(spacing: 0) {
            // Panorama View
            PanoramaViewRepresentable(
                panorama: drawingPanorama,
                zoomScale: $zoomScale
            )
            .edgesIgnoringSafeArea(.all)
            
            // Controls
            HStack {
                Button("Fit") {
                    withAnimation {
                        zoomScale = 0.5 // Calculate actual fit scale
                    }
                }
                
                Slider(value: $zoomScale, in: 0.25...4.0)
                    .frame(width: 200)
                
                Button("Reset") {
                    withAnimation {
                        zoomScale = 1.0
                    }
                }
            }
            .padding()
        }
    }
}
```

---

## Cross-Platform Targets

### Shared Code Structure

```swift
// Shared/PanoramaWrapper.swift
import Panorama

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class PanoramaWrapper {
    let panoramaView: PanoramaView
    let panorama: Panorama
    
    init(frame: CGRect, contentSize: CGSize) {
        panoramaView = PanoramaView(frame: frame)
        panorama = createPanorama(size: contentSize)
        panoramaView.panorama = panorama
    }
    
    private func createPanorama(size: CGSize) -> Panorama {
        // Create your panorama
        return DrawingPanorama(frame: CGRect(origin: .zero, size: size))
    }
}
```

### Platform-Specific Implementations

#### iOS Specific
```swift
// iOS/iOSViewController.swift
import UIKit
import Panorama

class iOSViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iOS-specific setup
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Common setup
        setupPanorama()
    }
}
```

#### macOS Specific
```swift
// macOS/macOSViewController.swift
import Cocoa
import Panorama

class macOSViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // macOS-specific setup
        view.wantsLayer = true
        
        // Common setup
        setupPanorama()
    }
}
```

### Target Configuration

1. **Shared Framework Target**:
   ```
   Target: PanoramaCore
   Supported Destinations: iOS, macOS
   Deployment: iOS 13.0, macOS 10.13
   ```

2. **Platform Targets**:
   ```
   iOS Target: PanoramaApp-iOS
   macOS Target: PanoramaApp-macOS
   Dependencies: PanoramaCore
   ```

---

## Debugging Configuration

### Scheme Configuration

1. Edit Scheme → Run → Arguments
2. Add environment variables:
   ```
   PANORAMA_DEBUG_DRAWING = 1
   PANORAMA_LOG_PERFORMANCE = 1
   ```

### Debug Build Settings

```swift
// In your panorama subclass
#if DEBUG
var debugDrawing: Bool {
    ProcessInfo.processInfo.environment["PANORAMA_DEBUG_DRAWING"] == "1"
}

override func draw(in context: CGContext) {
    super.draw(in: context)
    
    if debugDrawing {
        drawDebugInfo(in: context)
    }
}
#endif
```

### Console Logging

Create a debug configuration file:

```swift
// Debug/DebugConfiguration.swift
struct DebugConfiguration {
    static let logTouches = true
    static let logDrawingPerformance = true
    static let showFPS = true
    static let highlightViewBounds = true
}

// Usage
if DebugConfiguration.logTouches {
    print("Touch at: \(location)")
}
```

### Memory Debugging

1. Enable **Malloc Stack Logging**:
   - Edit Scheme → Run → Diagnostics
   - ✓ Malloc Stack Logging
   - ✓ Malloc Guard Edges

2. Add memory tracking:
```swift
class MemoryTrackingPanorama: Panorama {
    static var instanceCount = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Self.instanceCount += 1
        print("Panorama instances: \(Self.instanceCount)")
    }
    
    deinit {
        Self.instanceCount -= 1
        print("Panorama deallocated. Remaining: \(Self.instanceCount)")
    }
}
```

---

## Performance Optimization

### Build Settings for Performance

#### Release Configuration
- **Optimization Level**: Optimize for Speed [-O]
- **Whole Module Optimization**: Yes
- **Link-Time Optimization**: Monolithic
- **Strip Debug Symbols**: Yes

### Instruments Configuration

1. **Time Profiler Template**:
   - Sample Interval: 1ms
   - Record Waiting Threads: Yes

2. **Core Animation Template**:
   - Record Display Refresh Rate
   - Color Blended Layers
   - Color Offscreen-Rendered

### Performance Monitoring

```swift
// Add to your scheme's environment variables
CA_DEBUG_TRANSACTIONS = 1
CA_PRINT_TREE = 1

// In code
class PerformanceMonitor {
    static func measure<T>(name: String, block: () throws -> T) rethrows -> T {
        let start = CACurrentMediaTime()
        defer {
            let time = CACurrentMediaTime() - start
            print("⏱ \(name): \(String(format: "%.3f", time * 1000))ms")
        }
        return try block()
    }
}

// Usage
override func draw(in context: CGContext) {
    PerformanceMonitor.measure(name: "Drawing") {
        super.draw(in: context)
    }
}
```

---

## Common Issues

### Issue: PanoramaView not appearing in Interface Builder

**Solution**: Ensure module is specified correctly
1. Clean build folder (⇧⌘K)
2. Close and reopen Xcode
3. In storyboard, explicitly set Module to "Panorama"

### Issue: "No such module 'Panorama'"

**Solution**:
1. File → Packages → Update to Latest Package Versions
2. Clean build folder
3. Quit Xcode, delete DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

### Issue: Performance issues on older devices

**Solution**: Add device-specific optimizations
```swift
var drawingQuality: CGFloat {
    if UIDevice.current.userInterfaceIdiom == .phone {
        // Lower quality for phones
        return UIScreen.main.scale > 2 ? 0.5 : 1.0
    }
    return 1.0
}
```

### Issue: Constraint conflicts in Storyboard

**Solution**: Use priority-based constraints
```xml
<constraint firstItem="panoramaView" firstAttribute="height" 
            relation="greaterThanOrEqual" constant="200" priority="750"/>
```

---

## Build Automation

### Fastlane Configuration

Create `fastlane/Fastfile`:
```ruby
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    run_tests(
      workspace: "PanoramaApp.xcworkspace",
      scheme: "PanoramaApp",
      devices: ["iPhone 14", "iPad Pro (12.9-inch)"]
    )
  end
  
  desc "Build for release"
  lane :build do
    build_app(
      workspace: "PanoramaApp.xcworkspace",
      scheme: "PanoramaApp",
      configuration: "Release",
      export_method: "app-store"
    )
  end
end
```

### GitHub Actions

`.github/workflows/build.yml`:
```yaml
name: Build and Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -switch /Applications/Xcode_15.0.app
      
    - name: Build
      run: xcodebuild build -scheme Panorama -destination 'platform=iOS Simulator,name=iPhone 15'
      
    - name: Test
      run: xcodebuild test -scheme Panorama -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Summary

This configuration guide provides all the Xcode-specific settings needed to successfully integrate and use Panorama in your projects. Follow these guidelines to ensure optimal performance and maintainability of your Panorama-based applications.