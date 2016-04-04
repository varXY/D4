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
	func willInputText(index: Int, oldText: String?, colorCode: Int)
	func canUpLoad(can: Bool)
}

class WriteView: UIView {

	var startLocation: CGPoint!
	var touchMoved = false
	var selectingColor = false

	var firstColor = true

	var ready = false

	var selectedDotIndex: Int! {
		didSet {
			selectingColor = true
		}
	}

	var selectedBlockIndex: Int!

	var labels = [UILabel]()
	var dots = [UIView]()
	var bottomSign: UIView!
	var colorCodes = [Int]()

	weak var delegate: WriteViewDelegate?

	init() {
		super.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
		backgroundColor = UIColor.clearColor()
		multipleTouchEnabled = false
		exclusiveTouch = true

		var index = 0
		repeat {
			let label = UILabel(frame: blockFrame(CGFloat(index)))
			let colorCode = randomColorCode()
			colorCodes.append(colorCode)
			label.backgroundColor = MyColor.code(colorCode).BTColors[0]
			label.textColor = MyColor.code(colorCode).BTColors[1]
			label.textAlignment = .Center
			label.text = ""
			label.adjustsFontSizeToFitWidth = true
			label.addBorder(borderColor: UIColor.clearColor(), width: 0.0)
			labels.append(label)
			addSubview(label)

			if index != 0 {
				let dotIndex = index - 1
				let dot = UIView(frame: dotFrame(CGFloat(dotIndex)))
				dot.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
				addSubview(dot)
				dots.append(dot)
			}

			index += 1
		} while index < 5

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
		tapGesture.delegate = self
		addGestureRecognizer(tapGesture)

	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touch = touches.first else { return }
		startLocation = touch.locationInView(self)
		locationToDotIndex(startLocation)
		delegate?.selectingColor(selectingColor)

	}

	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touch = touches.first else { return }
		let currentLocation = touch.locationInView(self)

		let currentPosition = locationToColorCode(currentLocation)
		var startPosition = locationToColorCode(startLocation)

		if selectingColor && currentPosition != startPosition {
			changeLabelBackgoundColorAtDotIndex(selectedDotIndex, colorCode: currentPosition)
			startPosition = currentPosition
		}

		touchMoved = true

	}

	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		print(#function)

		if !touchMoved {
//			locationToBlockIndex(startLocation)
//			if selectedBlockIndex != nil {
//				delegate?.willInputText(selectedBlockIndex, oldText: labels[selectedBlockIndex].text, colorCode: colorCodes[selectedBlockIndex])
//			}


		} else {
			if selectingColor {
				selectingColor = false
				delegate?.selectingColor(selectingColor)
			}
			touchMoved = false
		}
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

		if !touchMoved {
//			locationToBlockIndex(startLocation)
//			if selectedBlockIndex != nil {
//				delegate?.willInputText(selectedBlockIndex, oldText: labels[selectedBlockIndex].text, colorCode: colorCodes[selectedBlockIndex])
//			}

		} else {
			if selectingColor {
				selectingColor = false
				delegate?.selectingColor(selectingColor)
			}
			touchMoved = false
		}
	}

	func tapped() {
		delegate?.willInputText(selectedBlockIndex, oldText: labels[selectedBlockIndex].text, colorCode: colorCodes[selectedBlockIndex])
	}


	func changeLabelText(index: Int, text: String) {
		labels[index].text = text
		checkText()
	}

	func checkText() {
		let empty = labels.filter( { $0.text == "" })
//		bottomSign.backgroundColor = empty.count == 0 ? UIColor.redColor() : UIColor.whiteColor()
		ready = empty.count == 0
		delegate?.canUpLoad(ready)

	}

	func labelsGetRandomColors() {
		let colorCodes = fourRandomColorCode()
		self.colorCodes.removeAll()
		self.colorCodes = colorCodes + [colorCodes[0]]
		changeLabelBackgoundColorAtDotIndex(3, colorCode: colorCodes[0])
		for i in 0..<3 {
			changeLabelBackgoundColorAtDotIndex(i, colorCode: colorCodes[i + 1])
		}
	}

	func changeLabelBackgoundColorAtDotIndex(dotIndex: Int, colorCode: Int) {
		if dotIndex != 0 {
			colorCodes[dotIndex] = colorCode

			labels[dotIndex].backgroundColor = MyColor.code(colorCode).BTColors[0]
			labels[dotIndex].textColor = MyColor.code(colorCode).BTColors[1]
		} else {
			colorCodes[0] = colorCode
			colorCodes[4] = colorCode

			labels[0].backgroundColor = MyColor.code(colorCode).BTColors[0]
			labels[0].textColor = MyColor.code(colorCode).BTColors[1]

			labels[4].backgroundColor = MyColor.code(colorCode).BTColors[0]
			labels[4].textColor = MyColor.code(colorCode).BTColors[1]
		}
	}



	func newStory() -> Story? {
		if ready {
			let sentences: [String] = [labels[0].text!, labels[1].text!, labels[2].text!, labels[3].text!, labels[4].text!]
			let story = Story(sentences: sentences, colors: colorCodes)
			return story
		} else {
			return nil
		}

	}

	func locationToColorCode(location: CGPoint) -> Int {
		let x = floor(location.x / (ScreenWidth / 5))
		let y = floor(location.y / (ScreenHeight / 6))
		return Int(x * 10 + y)
	}

	func locationToBlockIndex(location: CGPoint) {
		for i in 0..<labels.count {
			let frame = activateBlockFrame(CGFloat(i))
			if frame.contains(location) {
				selectedBlockIndex = i
			}
		}
	}

	func locationToDotIndex(location: CGPoint) {
		for i in 0..<dots.count {
			let frame = dots[i].frame
			if frame.contains(location) {
				selectedDotIndex = i
			}
		}

	}


	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension WriteView: UIGestureRecognizerDelegate {

	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
		let location = touch.locationInView(self)
		locationToBlockIndex(location)
		return selectedBlockIndex != nil
	}
}

extension WriteView: ColorSelectingDotDelegate {

	func selectingColor(selecting: Bool) {
		delegate?.selectingColor(selecting)
	}
}