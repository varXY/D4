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
		exclusiveTouch = true
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		print(#function)
		
		guard let touch = touches.first else { return }
		startPosition = locationToColorCode(touch.locationInView(self))

	}

	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touch = touches.first else { return }
		let currentPosition = locationToColorCode(touch.locationInView(self))
		if currentPosition != startPosition {
			print(startPosition)
			backgroundColor = MyColor.code(currentPosition).BTColors[0]
			startPosition = currentPosition
		}
		print(currentPosition)

	}

	func locationToColorCode(location: CGPoint) -> Int {
		let x = floor(location.x / (ScreenWidth / 5))
		let y = floor(location.y / (ScreenHeight / 6))
		return Int(x * 10 + y)
	}


	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}