//
//  MyViewController.swift
//  PanoramaApp_ios
//
//  Created by Kaz Yoshikawa on 1/18/17.
//
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif


class MyViewController: XViewController {

	@IBOutlet weak var panoramaView: PanoramaView!

	override func viewDidLoad() {
		super.viewDidLoad()

		self.panoramaView.panorama = MyPanorama(frame: CGRect(x: 0, y: 0, width: 1024, height: 1024))
	}

	#if os(iOS)
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	#endif

}

