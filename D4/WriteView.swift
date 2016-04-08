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
	func willInputText(index: Int, oldText: String, colorCode: Int)
	func canUpLoad(can: Bool)
}

class WriteView: UIView {

	var startLocation: CGPoint!
	var touchMoved = false
	var selectingColor = false

	var firstColor = true

	var ready = false

	var selectedDotIndex: Int!

	var selectedBlockIndex: Int!

	var labels = [UILabel]()
	var dots = [UIView]()
	var colorCodes = [Int]()

	weak var delegate: WriteViewDelegate?

	init() {
		super.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
		backgroundColor = UIColor.clearColor()
		multipleTouchEnabled = false
		exclusiveTouch = true
		clipsToBounds = true
		
		colorCodes = fiveRandomColorCode()

		var index = 0
		repeat {
			let label = SLabel(frame: blockFrame(index))
			label.backgroundColor = MyColor.code(colorCodes[index]).BTColors[0]
			label.textColor = MyColor.code(colorCodes[index]).BTColors[1]
			label.textAlignment = .Center
			label.text = ""
			label.numberOfLines = 0
			label.adjustsFontSizeToFitWidth = true
			label.drawTextInRect(CGRectMake(10, 10, label.frame.width - 20, label.frame.height - 20))
			label.addBorder(borderColor: UIColor.clearColor(), width: 0.0)
			labels.append(label)
			addSubview(label)

			if index == 0 {
				label.font = UIFont.boldSystemFontOfSize(19)
				addShadowForButton(label)
			}

			if index == 4 {
				label.font = UIFont.italicSystemFontOfSize(19)
				addShadowForButton(label)
				bringSubviewToFront(label)
				bringSubviewToFront(labels[0])
			}

			if index != 4 {
				let dot = UIView(frame: dotFrame(index))
				dot.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
				dot.layer.cornerRadius = dotLength / 2
				addSubview(dot)
				dots.append(dot)
			}

			index += 1
		} while index < 5

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
		tapGesture.delegate = self
		addGestureRecognizer(tapGesture)

	}

	func addShadowForButton(label: UILabel) {
		label.layer.masksToBounds = false
		label.layer.shadowRadius = 10
		label.layer.shadowOpacity = 0.5
		label.layer.shadowColor = UIColor.blackColor().CGColor
		label.layer.shadowOffset = CGSizeMake(0, 0)
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touch = touches.first else { return }
		startLocation = touch.locationInView(self)
		locationToDotIndex(startLocation)
		if selectedDotIndex != nil {
			selectingColor = true
			delegate?.selectingColor(selectingColor)
		}

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


	}

	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		if selectingColor {
			selectingColor = false
			delegate?.selectingColor(selectingColor)
		}
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if selectingColor {
			selectingColor = false
			delegate?.selectingColor(selectingColor)
		}
	}

	func tapped() {
		let text = labels[selectedBlockIndex].text == nil ? "" : labels[selectedBlockIndex].text
		delegate?.willInputText(selectedBlockIndex, oldText: text!, colorCode: colorCodes[selectedBlockIndex])
	}


	func changeLabelText(index: Int, text: String) {
		labels[index].text = text
		checkText()
	}

	func checkText() {
		let empty = labels.filter( { $0.text == "" })
		ready = empty.count == 0
	}

	func labelsGetRandomColors() {
		self.colorCodes = fiveRandomColorCode()
		for i in 0..<4 {
			changeLabelBackgoundColorAtDotIndex(i, colorCode: colorCodes[i])
		}
	}

	func changeLabelBackgoundColorAtDotIndex(dotIndex: Int, colorCode: Int) {

		colorCodes[dotIndex] = colorCode
		labels[dotIndex].backgroundColor = MyColor.code(colorCode).BTColors[0]
		labels[dotIndex].textColor = MyColor.code(colorCode).BTColors[1]

		if dotIndex == 0 {
			colorCodes[4] = colorCode
			labels[4].backgroundColor = MyColor.code(colorCode).BTColors[0]
			labels[4].textColor = MyColor.code(colorCode).BTColors[1]
		}

	}



	func newStory() -> Story? {
		if ready {
			ready = false
			let sentences: [String] = [labels[0].text!, labels[1].text!, labels[2].text!, labels[3].text!, labels[4].text!]
			let story = Story(sentences: sentences, colors: colorCodes)
			return story
		} else {
			return nil
		}

	}

	func clearContent() {
		var i = 0
		repeat {
			labels[i].text = ""
			i += 1
		} while i < labels.count

	}

	func locationToColorCode(location: CGPoint) -> Int {
		let x = floor(location.x / (ScreenWidth / 5))
		let y = floor(location.y / (ScreenHeight / 6))
		return Int(x * 10 + y)
	}

	func locationToBlockIndex(location: CGPoint) {
		selectedBlockIndex = nil
		var i = 0
		repeat {
			if activateBlockFrame(i).contains(location) {
				selectedBlockIndex = i
			}
			i += 1
		} while selectedBlockIndex == nil && i < labels.count
	}

	func locationToDotIndex(location: CGPoint) {
		selectedDotIndex = nil
		var i = 0
		repeat {
			if dots[i].frame.contains(location) {
				selectedDotIndex = i
			}
			i += 1
		} while selectedDotIndex == nil && i < dots.count
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

//extension WriteView: ColorSelectingDotDelegate {
//
//	func selectingColor(selecting: Bool) {
//		delegate?.selectingColor(selecting)
//	}
//}