//
//	PanoramaView.swift
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



class PanoramaView: XView {

	var panorama: Panorama? {
		willSet {
		}
		didSet {
			oldValue?.didMove(to: nil)
			self.panorama?.didMove(to: self)
			if let panorama = self.panorama {
				let contentSize = panorama.bounds.size
				self.contentView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
				#if os(iOS)
				self.scrollView.contentOffset = CGPoint.zero
				self.scrollView.contentSize = panorama.bounds.size
				self.scrollView.maximumZoomScale = panorama.maximumZoomScale
				self.scrollView.minimumZoomScale = panorama.minimumZoomScale
				#endif
				self.backView.setNeedsDisplay()
			}
		}
	}

	let backView = PanoramaBackView(frame: CGRect.zero)
	let contentView: PanoramaContentView = PanoramaContentView(frame: CGRect.zero)

	#if os(iOS)
	private (set) lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView(frame: self.bounds)
		scrollView.delegate = self
		scrollView.backgroundColor = UIColor.clear
		scrollView.maximumZoomScale = 4.0
		scrollView.minimumZoomScale = 1.0
//		scrollView.autoresizesSubviews = true
		scrollView.delaysContentTouches = false
		scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
		self.addSubviewToFit(scrollView)
		scrollView.addSubview(self.contentView)
		self.contentView.frame = self.bounds
		return scrollView
	}()
	#endif

	#if os(macOS)
	private (set) lazy var scrollView: NSScrollView = {
		let scrollView = NSScrollView(frame: self.bounds)
		scrollView.hasVerticalScroller = true
		scrollView.hasHorizontalScroller = true
		scrollView.borderType = .noBorder
		scrollView.drawsBackground = false
		self.addSubviewToFit(scrollView)

		// isFlipped cannot be set, then replace clipView with subclass it does
		let clipView = FlippedClipView(frame: self.contentView.frame)
		clipView.drawsBackground = false
		clipView.backgroundColor = .clear
		
		scrollView.contentView = clipView // scrollView's contentView is NSClipView
		scrollView.documentView = self.contentView
		scrollView.contentView.postsBoundsChangedNotifications = true

		// posting notification when zoomed, scrolled or resized
		typealias T = PanoramaView
		NotificationCenter.default.addObserver(self, selector: #selector(T.scrollContentDidChange(_:)),
					name: NSNotification.Name.NSViewBoundsDidChange, object: nil)
		scrollView.allowsMagnification = true
		scrollView.maxMagnification = self.maximumZoomScale
		scrollView.minMagnification = self.minimumZoomScale

		return scrollView
	}()
	#endif

	#if os(macOS)
	@objc func scrollContentDidChange(_ notification: Notification) {
		self.backView.setNeedsDisplay()
	}
	#endif


	lazy var setup: (()->()) = {
		self.backView.frame = self.frame
		self.addSubviewToFit(self.backView)
		self.backView.panoramaView = self
		self.scrollView.frame = self.frame
		self.contentView.backgroundColor = XColor.clear
		self.scrollView.backgroundColor = XColor.clear
		self.sendSubview(toBack: self.backView)
		self.contentView.panoramaView = self
		self.contentView.translatesAutoresizingMaskIntoConstraints = false
		#if os(iOS)
		self.scrollView.delegate = self
		#endif
		return {}
	}()

	#if os(iOS)
	override func layoutSubviews() {
		super.layoutSubviews()
		self.setup()
		if let panorama = self.panorama {
			let contentSize = panorama.bounds.size
			self.contentView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
			// todo: if panorama content is smaller than scrollview, then ...
		}

	}
	#endif
	
	#if os(macOS)
	override func layout() {
		super.layout()
		self.setup()
		if let panorama = self.panorama {
			let contentSize = panorama.bounds.size
			self.contentView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
			// todo: if panorama content is smaller than scrollview, then ...
		}
	}
	#endif

	#if os(iOS)
	override func setNeedsDisplay() {
		super.setNeedsDisplay()
		self.backView.setNeedsDisplay()
	}
	#elseif os(macOS)
	override func setNeedsDisplay() {
		super.setNeedsDisplay()
		self.backView.setNeedsDisplay()
	}
	#endif

	#if os(macOS)
	override var isFlipped: Bool {
		return true
	}
	#endif

	var maximumZoomScale: CGFloat {
		return self.panorama?.maximumZoomScale ?? 1.0
	}

	var minimumZoomScale: CGFloat {
		return self.panorama?.minimumZoomScale ?? 1.0
	}

	#if os(iOS)
	var minimumNumberOfTouchesToScroll: Int {
		get { return self.scrollView.panGestureRecognizer.minimumNumberOfTouches }
		set { self.scrollView.panGestureRecognizer.minimumNumberOfTouches = newValue }
	}
	#endif
	
	#if os(iOS)
	var scrollEnabled: Bool {
		get { return self.scrollView.isScrollEnabled }
		set { self.scrollView.isScrollEnabled = newValue }
	}
	#endif
	
	#if os(iOS)
	var delaysContentTouches: Bool {
		get { return self.scrollView.delaysContentTouches }
		set { self.scrollView.delaysContentTouches = newValue }
	}
	#endif

}

#if os(iOS)
extension PanoramaView: UIScrollViewDelegate {

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.contentView
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		self.setNeedsDisplay()
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.setNeedsDisplay()
	}
	
}
#endif

#if os(macOS)
class FlippedClipView: NSClipView {

	override var isFlipped: Bool { return true }

}
#endif

