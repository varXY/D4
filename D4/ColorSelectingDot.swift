//
//  ColorButton.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

protocol ColorSelectingDotDelegate: class {
	func selectingColor(selecting: Bool)
}


class ColorSelectingDot: UIView {

	weak var delegate: ColorSelectingDotDelegate?

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = UIColor.grayColor()
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		delegate?.selectingColor(true)
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		delegate?.selectingColor(false)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}