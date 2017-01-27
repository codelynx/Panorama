//
//	UITouch+P.swift
//	Panorama
//
//	Created by Kaz Yoshikawa on 1/18/17.
//	Copyright © 2017 Electricwoods LLC. All rights reserved.
//

#if os(iOS)
import UIKit

extension UITouch {

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


extension UIGestureRecognizer {

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
