# Changelog

All notable changes to the Panorama framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2025-07-24

### Added
- Comprehensive documentation comments for all public APIs
- MARK comments throughout codebase for better navigation
- `CaseIterable` conformance to enums where appropriate
- New `GradientDirection` enum with diagonal gradient support
- `removeViewlet(_:)` method for removing child viewlets
- Better access control with `private(set)` modifiers
- Named parameters for better API clarity
- Swift 5.9+ language features and idioms

### Changed
- **BREAKING**: Updated minimum Swift version to 5.9
- **BREAKING**: Renamed `enabled` property to `isEnabled` in Viewlet
- **BREAKING**: Changed parameter labels in NSView extensions for consistency
- Converted `Gradient` from class to struct for value semantics
- Improved optional handling with guard statements throughout
- Modernized property declarations with better encapsulation
- Updated `ViewletStyle` with clearer API methods
- Reorganized file structure with clear sections using MARK comments
- Enhanced error handling with guard statements instead of force unwrapping

### Fixed
- Memory management issues with proper `[weak self]` in closures
- Potential retain cycles in parent-child relationships
- Force unwrapping in several locations replaced with safe unwrapping

### Documentation
- Added comprehensive project review report
- Created detailed improvement report with roadmap
- Added Swift modernization summary
- Created this changelog

### Technical Details

#### XPlatform.swift
- Removed duplicate UIKit import
- Added documentation for all extensions
- Improved NSView extension methods with better parameter labels
- Cleaned up commented code

#### Viewlet.swift
- Complete refactoring with modern Swift patterns
- Added comprehensive documentation
- Improved access control throughout
- Better memory management in touch/mouse handlers
- Separated nested types into top-level declarations

#### ViewletStyle.swift
- Converted Gradient to struct with validation
- Added GradientDirection enum
- Improved initialization patterns
- Better encapsulation of properties

## [Previous Versions]

### Notes
- Original version was written for Swift 3.0.2
- Framework initially created by Kaz Yoshikawa in 2017
- Licensed under MIT License