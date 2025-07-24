//
//	UITouch+P.swift
//	Panorama
//
//	Created by Kaz Yoshikawa on 1/18/17.
//	Copyright © 2017 Electricwoods LLC. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UITouch {

	func location(in panorama: Panorama) -> CGPoint? {
		// Avoid recursion by getting location directly from content view
		if let panoramaView = panorama.panoramaView {
			let locationInContentView = self.location(in: panoramaView.contentView)
			// The content view coordinates are the same as panorama coordinates
			return locationInContentView
		}
		return nil
	}

	func location(in viewlet: Viewlet) -> CGPoint? {
		// Get location in the panorama first
		if let panorama = viewlet.panorama,
		   let panoramaView = panorama.panoramaView,
		   let transform = viewlet.transformFromPanorama {
			// Get location directly from content view to avoid recursion
			let locationInContentView = self.location(in: panoramaView.contentView)
			// Apply the transform to get the point in viewlet coordinates
			return locationInContentView.applying(transform)
		}
		return nil
	}

}


public extension UIGestureRecognizer {

	func location(in panorama: Panorama) -> CGPoint? {
		if let panoramaView = panorama.panoramaView {
			return self.location(in: panoramaView.contentView)
		}
		return nil
	}

	func location(in viewlet: Viewlet) -> CGPoint? {
		if let panorama = viewlet.panorama, let point = self.location(in: panorama), let transform = viewlet.transformFromPanorama {
			return point.applying(transform)
		}
		return nil
	}

}
#endif
