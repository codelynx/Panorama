//
//	PanoramaBackView.swift
//	Panorama
//
//	Created by Kaz Yoshikawa on 1/18/17.
//	Copyright © 2017 Electricwoods LLC. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif


open class PanoramaBackView: XView {

	weak var panoramaView: PanoramaView?

	var contentView: XView {
		return self.panoramaView!.contentView
	}

	#if os(macOS)
	open override func layout() {
		super.layout()
		assert(panoramaView != nil)
		self.backgroundColor = XColor.clear
	}
	#endif
	
	#if os(iOS)
	open override func layoutSubviews() {
		super.layoutSubviews()
		assert(panoramaView != nil)
		self.backgroundColor = XColor.clear
	}
	#endif

	#if os(macOS)
	open override var isFlipped: Bool { return true }
	#endif

/*
	var drawingTransform: CGAffineTransform {
		guard let scene = self.scene else { return CGAffineTransform.identity }
		let targetRect = contentView.convert(self.contentView.bounds, to: self.mtkView)
		let transform0 = CGAffineTransform(translationX: 0, y: self.contentView.bounds.height).scaledBy(x: 1, y: -1)
		let transform1 = scene.bounds.transform(to: targetRect)
		let transform2 = self.mtkView.bounds.transform(to: CGRect(x: -1.0, y: -1.0, width: 2.0, height: 2.0))
		let transform3 = CGAffineTransform.identity.translatedBy(x: 0, y: +1).scaledBy(x: 1, y: -1).translatedBy(x: 0, y: 1)
		#if os(iOS)
		let transform = transform1 * transform2 * transform3
		#elseif os(macOS)
		let transform = transform0 * transform1 * transform2
		#endif
		return transform
	}
*/


	open override func draw(_ rect: CGRect) {

		guard let panorama = self.panoramaView?.panorama else { return }
		#if os(iOS)
		guard let context = UIGraphicsGetCurrentContext() else { return }
		#elseif os(macOS)
		guard let context = NSGraphicsContext.current?.cgContext else { return }
		#endif

		let targetRect = contentView.convert(self.contentView.bounds, to: self)
		let transform = panorama.bounds.transform(to: targetRect)
		context.concatenate(transform)

		context.saveGState()
		panorama.drawRecursively(in: context)
		context.restoreGState()
	}

}














