//
//  TestView.swift
//  D4
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

protocol WriteViewDelegate: class {
	func selectingColor(selecting: Bool)
}

class WriteView: UIView {

	var startPosition: Int!

	let rect = Rect()

	var label_0: UILabel!
	var label_1: UILabel!
	var label_2: UILabel!
	var label_3: UILabel!

	weak var delegate: WriteViewDelegate?

	init() {
		super.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
		backgroundColor = UIColor.purpleColor()
		exclusiveTouch = true

		label_0 = UILabel(frame: rect.writeViewBlockFrame(0))
		label_1 = UILabel(frame: rect.writeViewBlockFrame(1))
		label_2 = UILabel(frame: rect.writeViewBlockFrame(2))
		label_3 = UILabel(frame: rect.writeViewBlockFrame(3))

		addSubview(label_0)
		addSubview(label_1)
		addSubview(label_2)
		addSubview(label_3)

		let image = UIImage.imageWithColor(UIColor.blackColor(), rect: CGRectMake(50, 50, 100, 100))
		let imageView = UIImageView(image: image)
		addSubview(imageView)
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		print(#function)

		guard let touch = touches.first else { return }
		let location = touch.locationInView(self)
		let rect = CGRectMake(50, 50, 100, 100)
		if rect.contains(location) {
			delegate?.selectingColor(true)
		}
		startPosition = locationToColorCode(location)

	}

	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touch = touches.first else { return }
		let currentPosition = locationToColorCode(touch.locationInView(self))
		if currentPosition != startPosition {
			print(startPosition)
			label_3.backgroundColor = MyColor.code(currentPosition).BTColors[0]
			startPosition = currentPosition
		}
		print(currentPosition)

	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		delegate?.selectingColor(false)
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

extension WriteView: ColorSelectingDotDelegate {

	func selectingColor(selecting: Bool) {
		delegate?.selectingColor(selecting)
	}
}