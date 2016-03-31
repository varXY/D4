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

	var touchPoint: (Int, Int)!

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.whiteColor()
		exclusiveTouch = true

		let subView = UIView(frame: self.bounds)
		subView.backgroundColor = UIColor.clearColor()
		self.addSubview(subView)
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let touch : UITouch = touches.first {
			touchPoint = locationToColorValue(touch.locationInView(self))
		}
	}

	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let touch : UITouch = touches.first {
			let currentPoint = locationToColorValue(touch.locationInView(self))
			if currentPoint != touchPoint {
				print(touchPoint)
				self.backgroundColor = Background.point(currentPoint.0, currentPoint.1).color
				touchPoint = currentPoint
				print("changed")
			}
			print(currentPoint)
		}
	}

	func simpleLocation(location: CGPoint) -> CGPoint {
		let x = location.x / (ScreenWidth / 5)
		let y = location.y / (ScreenHeight / 6)
		let simplePoint = CGPoint(x: floor(x), y: floor(y))
		return simplePoint
	}

	func locationToColorValue(location: CGPoint) -> (Int, Int) {
		let x = location.x / (ScreenWidth / 5)
		let y = location.y / (ScreenHeight / 6)
		let value = (x: Int(floor(y)), y: Int(floor(x)))
		return value
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}