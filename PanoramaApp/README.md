# PanoramaApp Example

This example application demonstrates the capabilities of the Panorama framework with interactive labels, text fields, and draggable components.

## Features Demonstrated

### 1. **Form with Text Fields**
- Interactive text input using `TextFieldViewlet`
- Labels with various alignments and styles
- Form layout with proper spacing

### 2. **Draggable Note Cards**
- Colored note cards that can be dragged around
- Editable titles using text fields
- Delete functionality with button interaction
- Different colors for visual variety

### 3. **Label Examples**
- Title and description labels
- Various text alignments and attributes
- Cross-platform font handling

### 4. **Interactive Viewlets**
- Custom `MyViewlet` with colored circles
- Nested viewlet hierarchy
- Button viewlets with custom styling

## Architecture

The example showcases:
- Custom viewlet creation (`TextFieldViewlet`, `FormExampleViewlet`, `NoteCardViewlet`)
- Event handling for both iOS and macOS
- Cross-platform color and font management
- Dragging and interaction patterns

## Building and Running

### Requirements
- Xcode 15.0+
- iOS 13.0+ / macOS 10.13+
- Swift 5.9+

### Steps
1. Open `PanoramaApp.xcodeproj` in Xcode
2. Select the iOS or macOS target
3. Build and run (⌘R)

## Key Components

### TextFieldViewlet
A custom viewlet that provides text input functionality with:
- Keyboard input handling
- Focus management
- Visual feedback (borders, cursor)
- Platform-specific text field integration

### FormExampleViewlet
Demonstrates form layout with:
- Aligned labels and text fields
- Proper spacing and padding
- Background and border styling

### NoteCardViewlet
Interactive cards featuring:
- Drag-and-drop functionality
- Editable content
- Delete buttons
- Custom colors and styling

## Customization

You can customize the example by:
1. Adding new viewlet types
2. Modifying colors and styles
3. Adding more interactive features
4. Creating new layout patterns

## Cross-Platform Considerations

The example handles platform differences:
- Color APIs (system colors vs named colors)
- Touch vs mouse events
- Text field implementations
- Coordinate systems

## Next Steps

Try extending the example with:
- Persistence (save/load cards)
- More complex forms
- Animation effects
- Custom gestures
- Data binding