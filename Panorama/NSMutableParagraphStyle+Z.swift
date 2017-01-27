//
//  NSMutableParagraphStyle+Z.swift
//  ZKit
//
//  Created by Kaz Yoshikawa on 1/29/17.
//  Copyright © 2017 Electricwoods LLC., Kaz Yoshikawa. All rights reserved.
//


#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif


extension NSMutableParagraphStyle {

	convenience init(_ paragraphStyle: NSParagraphStyle) {
		self.init()
		self.setParagraphStyle(paragraphStyle)
	}

	convenience init(attributes: [String: Any]) {
		self.init()

		#if os(iOS)
		let style = NSMutableParagraphStyle(NSParagraphStyle.default)
		#elseif os(macOS)
		let style = NSMutableParagraphStyle(NSParagraphStyle.default())
		#endif

		self.setParagraphStyle(style)
		self.setValuesForKeys(attributes)
	}

}

