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



open class PanoramaView: XView {

	public var panorama: Panorama? {
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
					name: NSView.boundsDidChangeNotification, object: nil)
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


	lazy private var setup: (()->()) = {
		self.backView.frame = self.frame
		self.addSubviewToFit(self.backView)
		self.backView.panoramaView = self
		self.scrollView.frame = self.frame
		self.contentView.backgroundColor = XColor.clear
		self.scrollView.backgroundColor = XColor.clear
		self.sendSubviewToBack(self.backView)
		self.contentView.panoramaView = self
		self.contentView.translatesAutoresizingMaskIntoConstraints = false
		#if os(iOS)
		self.scrollView.delegate = self
		#endif
		return {}
	}()

	#if os(iOS)
	open override func layoutSubviews() {
		super.layoutSubviews()
		self.setup()
		if let panorama = self.panorama {
			// if content size is smaller than scroll view, then set some margins
			let contentSize = panorama.bounds.size
			let delta = self.bounds.size - contentSize
			let (marginH, marginV) = (max(delta.width, 0) * 0.5, max(delta.height, 0) * 0.5)
			self.scrollView.contentInset = UIEdgeInsets(top: marginV, left: marginH, bottom: marginV, right: marginH)
			self.contentView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
		}

	}
	#endif
	
	#if os(macOS)
	open override func layout() {
		super.layout()
		self.setup()
		if let panorama = self.panorama {
			// if content size is smaller than scroll view, then set some margins
			let contentSize = panorama.bounds.size
			let delta = self.bounds.size - contentSize
			let (marginH, marginV) = (max(delta.width, 0) * 0.5, max(delta.height, 0) * 0.5)
			self.scrollView.contentInsets = NSEdgeInsets(top: marginV, left: marginH, bottom: marginV, right: marginH) // working?
			self.contentView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
		}
	}
	#endif

	#if os(iOS)
	open override func setNeedsDisplay() {
		super.setNeedsDisplay()
		self.backView.setNeedsDisplay()
	}
	#elseif os(macOS)
	public override func setNeedsDisplay() {
		super.setNeedsDisplay()
		self.backView.setNeedsDisplay()
	}
	#endif

	#if os(macOS)
	open override var isFlipped: Bool {
		return true
	}
	#endif

	public var maximumZoomScale: CGFloat {
		return self.panorama?.maximumZoomScale ?? 1.0
	}

	public var minimumZoomScale: CGFloat {
		return self.panorama?.minimumZoomScale ?? 1.0
	}

	#if os(iOS)
	private var minimumNumberOfTouchesToScroll: Int {
		get { return self.scrollView.panGestureRecognizer.minimumNumberOfTouches }
		set { self.scrollView.panGestureRecognizer.minimumNumberOfTouches = newValue }
	}
	#endif
	
	#if os(iOS)
	private var scrollEnabled: Bool {
		get { return self.scrollView.isScrollEnabled }
		set { self.scrollView.isScrollEnabled = newValue }
	}
	#endif
	
	#if os(iOS)
	public var delaysContentTouches: Bool {
		get { return self.scrollView.delaysContentTouches }
		set { self.scrollView.delaysContentTouches = newValue }
	}
	#endif

}

#if os(iOS)
extension PanoramaView: UIScrollViewDelegate {

	public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.contentView
	}

	public func scrollViewDidZoom(_ scrollView: UIScrollView) {
		self.setNeedsDisplay()
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.setNeedsDisplay()
	}
	
}
#endif

#if os(macOS)
open class FlippedClipView: NSClipView {

	open override var isFlipped: Bool { return true }

}
#endif

