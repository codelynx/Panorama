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


public extension NSMutableParagraphStyle {

	convenience init(_ paragraphStyle: NSParagraphStyle) {
		self.init()
		self.setParagraphStyle(paragraphStyle)
	}

	convenience init(attributes: [String: Any]) {
		self.init()

		let style = NSMutableParagraphStyle(NSParagraphStyle.default)
		self.setParagraphStyle(style)
		self.setValuesForKeys(attributes)
	}

}

