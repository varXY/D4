//
//  TestView.swift
//  D4
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

class TestView: UIView {

	var startPosition: Int!

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.whiteColor()
		exclusiveTouch = true

		let subView = UIView(frame: self.bounds)
		subView.backgroundColor = UIColor.clearColor()
		self.addSubview(subView)
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
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

//	func simpleLocation(location: CGPoint) -> CGPoint {
//		let x = location.x / (ScreenWidth / 5)
//		let y = location.y / (ScreenHeight / 6)
//		let simplePoint = CGPoint(x: floor(x), y: floor(y))
//		return simplePoint
//	}
//
//	func locationToColorValue(location: CGPoint) -> (Int, Int) {
//		let x = location.x / (ScreenWidth / 5)
//		let y = location.y / (ScreenHeight / 6)
//		let value = (x: Int(floor(y)), y: Int(floor(x)))
//		return value
//	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}