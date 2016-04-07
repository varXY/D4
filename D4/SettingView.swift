//
//  InputView.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

class SettingView: UIView {

	var startPosition: Int!

	init() {
		super.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
		backgroundColor = UIColor.purpleColor()
		layer.cornerRadius = globalRadius
		clipsToBounds = true
		exclusiveTouch = true
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

	}

	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {


	}


	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}