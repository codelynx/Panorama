# Changelog

All notable changes to Panorama will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-07-24

### Added
- **TextFieldViewlet**: Full-featured text input component with keyboard support
  - Cross-platform text input (iOS UITextInputDelegate, macOS NSTextInputClient)
  - Focus management with visual cursor
  - Placeholder text support
  - Customizable styling (colors, fonts, corner radius)
  - Event callbacks for text changes and return key
- **NoteCardViewlet**: Draggable sticky note component
  - Drag to reposition
  - Delete button functionality
  - Customizable colors and fonts
  - Drop shadow effects
- **FormExampleViewlet**: Example implementation showing form layouts
- Comprehensive Getting Started Guide with architecture details
- API Reference documentation
- Migration Guide for upgrading from older versions
- Xcode Configuration Guide

### Changed
- Modernized codebase to Swift 5.9+
- Replaced ZKit dependency with built-in XPlatform module
- Enhanced type safety throughout the framework
- Improved memory management with proper weak references
- Updated `findViewlet` method parameter from `point` to `at` for clarity
- Made ButtonViewlet properties public for external access

### Fixed
- **Critical**: Fixed infinite recursion in `findViewlet(at:)` method
  - Added bounds checking before recursing through subviewlets
  - Prevents stack overflow with circular viewlet references
- **Critical**: Fixed touch handling recursion for nested Panoramas
  - Added type checking to prevent forwarding touches to Panorama instances
  - Prevents infinite recursion in touch event handling
- **Critical**: Fixed touch location calculation stack overflow
  - Modified `location(in:)` to get coordinates directly from content view
  - Avoids circular calls between UITouch and Panorama
- **Critical**: Fixed upside-down rendering on iOS platforms
  - Removed unnecessary coordinate flipping in PanoramaBackView for iOS
  - iOS UIView already provides a flipped context, no additional flipping needed
- **Critical**: Fixed inconsistent text rendering on macOS
  - Updated Viewlet's drawText method to use NSAttributedString.draw() on macOS
  - Ensures all text renders correctly without manual coordinate flipping
- **Improved**: iOS text rendering now uses UIKit's native string drawing
  - Changed from Core Text with manual coordinate flipping to UIGraphicsPushContext/PopContext
  - Fixes issues where some labels appeared upside down after TextFieldViewlet rendering
  - Provides more consistent text rendering across all viewlet types

### Removed
- ZKit dependency (functionality integrated or replaced)
- Deprecated support email from documentation

## [0.1.0] - Previous Release

Initial release with basic Panorama functionality.