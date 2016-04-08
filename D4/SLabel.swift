//
//  SLabel.swift
//  D4
//
//  Created by 文川术 on 4/8/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

class SLabel: UILabel {

	override func drawTextInRect(rect: CGRect) {
		let insets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
		super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
	}
}