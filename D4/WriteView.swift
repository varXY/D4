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
}

class WriteView: UIView, UserDefaults {

	var touchMoved = false
	var selectingColor = false
	var ready = false
	var doneWriting = false

	var selectedDotIndex: Int!
	var selectedBlockIndex: Int!

	var startPosition: Int!

	var labels = [UILabel]()
	var dots = [UIView]()

	var colorCodes = [Int]()
	var sentences: [String]!

	var backgroundSound: BackgroundSound!

	var nightStyle = false {
		didSet {
			let color = nightStyle ? UIColor(white: 0.3, alpha: 0.75) : MyColor.code(0).BTColors[0]
			dots.forEach({ $0.backgroundColor = color })
		}
	}

	let placeHolderTexts = [
		"标 题",
		"上 午",
		"下 午",
		"晚 上",
		"睡 前 哲 思"
	]

	weak var delegate: WriteViewDelegate?

	init() {
		super.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
		backgroundColor = UIColor.clearColor()
		multipleTouchEnabled = false
		exclusiveTouch = true
		clipsToBounds = true

		sentences = getSentences() != nil ? getSentences()! : placeHolderTexts
		colorCodes = getColors() != nil ? getColors()! : fiveRandomColorCodes()

		labels = blockFrames().map({ SLabel(frame: $0) })
		labels.forEach({
			let index = labels.indexOf($0)!
			$0.backgroundColor = MyColor.code(colorCodes[index]).BTColors[0]
			$0.textColor = MyColor.code(colorCodes[index]).BTColors[1]
			$0.textAlignment = .Center
			$0.numberOfLines = 0
			$0.adjustsFontSizeToFitWidth = true
			$0.text = sentences[index]
			addSubview($0)
			changeLabelTextFont(index, inputted: sentences[index] != placeHolderTexts[index])
		})

		dots = dotFrames().map({ UIView(frame: $0) })
		dots.forEach({
			$0.backgroundColor = UIColor.whiteColor()
			$0.alpha = 0.6
			$0.layer.cornerRadius = $0.frame.width / 2
		})
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.locationInView(self)
		locationToDotIndex(location)
		if selectedDotIndex != nil {
			startPosition = locationToColorCode(location)
			selectingColor = true
			delegate?.selectingColor(selectingColor)
			backgroundSound.playSound(true, sound: backgroundSound.switchOn_sound)
			bringSubviewToFront(dots[selectedDotIndex])
			dots[selectedDotIndex].alpha = 1.0
			UIView.animateWithDuration(0.25, animations: {
				self.dots[self.selectedDotIndex].transform = CGAffineTransformMakeScale(1.8, 1.8)
				}, completion: { (_) in
			})

		}

	}

	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touch = touches.first else { return }
		let currentLocation = touch.locationInView(self)
		let currentPosition = locationToColorCode(currentLocation)

		if selectingColor {
			dots[selectedDotIndex].center = currentLocation

			if currentPosition != startPosition {
				startPosition = currentPosition
				changeLabelBackgoundColorAtDotIndex(selectedDotIndex, colorCode: currentPosition)
				touchMoved = true
				addtipLabels(false, removeIndex: 1)
			}

		}

	}

	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		if touches!.count >= 2 { return }
		if selectingColor {
			UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {
				self.dots[self.selectedDotIndex].transform = CGAffineTransformMakeScale(1.0, 1.0)
				self.dots[self.selectedDotIndex].alpha = 0.6
				self.dots[self.selectedDotIndex].frame.origin = self.dotFrames()[self.selectedDotIndex].origin
				}, completion: nil)

			selectingColor = false
			delegate?.selectingColor(selectingColor)
		}
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if touches.count >= 2 { return }
		guard let touch = touches.first else { return }
		let currentLocation = touch.locationInView(self)

		if selectingColor {
			UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {
				self.dots[self.selectedDotIndex].transform = CGAffineTransformMakeScale(1.0, 1.0)
				self.dots[self.selectedDotIndex].alpha = 0.6
				self.dots[self.selectedDotIndex].frame.origin = self.dotFrames()[self.selectedDotIndex].origin
				}, completion: nil)
			selectingColor = false
			delegate?.selectingColor(selectingColor)
		}

		if !touchMoved {
			locationToBlockIndex(currentLocation)
			if selectedBlockIndex != nil {
				let text = labels[selectedBlockIndex].text == placeHolderTexts[selectedBlockIndex] ? "" : labels[selectedBlockIndex].text
				delegate?.willInputText(selectedBlockIndex, oldText: text!, colorCode: colorCodes[selectedBlockIndex])
			}
		} else {
			touchMoved = false
		}
	}

	func addDots(add: Bool) {
		add ? dots.forEach({ addSubview($0) }) : dots.forEach({ $0.removeFromSuperview() })
	}

	func changeLabelText(index: Int, text: String) {
		addtipLabels(false, removeIndex: 0)
		let inputted = text != ""
		let newText = inputted ? text : placeHolderTexts[index]
		changeLabelTextFont(index, inputted: inputted)
		labels[index].text = newText
		checkText()

		sentences = labels.map({ $0.text! })
	}

	func changeLabelTextFont(index: Int, inputted: Bool) {
		if inputted {
			labels[index].font = UIFont.systemFontOfSize(17)
		} else {
			labels[index].font = UIFont.boldSystemFontOfSize(35)
		}

		if index == 0 {
			labels[index].font = UIFont.boldSystemFontOfSize(17)
		}

		if index == 4 {
			labels[index].font = UIFont.italicSystemFontOfSize(17)
			labels[index].numberOfLines = 1
		}
	}

	func checkText() {
		let emptyLabel = labels.filter({ $0.text == placeHolderTexts[labels.indexOf($0)!] })
		doneWriting = emptyLabel.count == 0
		ready = doneWriting && lastWriteDate().string(.dd) != NSDate().string(.dd)
	}

	func labelsGetRandomColors() {
		colorCodes = fiveRandomColorCodes()
		colorCodes.forEach({ changeLabelBackgoundColorAtDotIndex(colorCodes.indexOf($0)!, colorCode: $0) })
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

	func saveContent() {
		saveSentencesAndColors(sentences, colors: colorCodes)
	}

	func clearContent() {
		labels.forEach({
			let index = labels.indexOf($0)!
			$0.text = placeHolderTexts[index]
			changeLabelTextFont(index, inputted: false)
		})

		sentences = placeHolderTexts
		removeSentencesAndColors()
	}

	func locationToColorCode(location: CGPoint) -> Int {
		let x = floor(location.x / (ScreenWidth / 5))
		let y = floor(location.y / (ScreenHeight / 6))
		return Int(x * 10 + y)
	}

	func locationToBlockIndex(location: CGPoint) {
		selectedBlockIndex = nil
		let frames = activateBlockFrames().filter({ $0.contains(location) })
		if frames.count != 0 { selectedBlockIndex = activateBlockFrames().indexOf(frames[0]) }
	}

	func locationToDotIndex(location: CGPoint) {
		selectedDotIndex = nil
		let frames = activateDotFrames().filter({ $0.contains(location) })
		if frames.count != 0 { selectedDotIndex = activateDotFrames().indexOf(frames[0]) }
	}

	func addtipLabels(add: Bool, removeIndex: Int?) {
		if add {
			var tipLabels = [UILabel]()

			if !tip_A_shown() {
				let label_A = UILabel(frame: tipViewFrames()[0])
				label_A.text = "点击\n中间\n开始\n输入\n"
				label_A.tag = 123
				tipLabels.append(label_A)
			}

			if !tip_B_shown() {
				let label_B = UILabel(frame: tipViewFrames()[1])
				label_B.text = "按住\n圆点\n滑动\n选择\n颜色"
				label_B.tag = 124
				tipLabels.append(label_B)
			}

			if tipLabels.count != 0 {
				tipLabels.forEach({
					$0.textColor = MyColor.code(colorCodes[2]).BTColors[1]
					$0.numberOfLines = 0
					$0.font = UIFont.systemFontOfSize(12)
					$0.adjustsFontSizeToFitWidth = true
					$0.textAlignment = .Center
					addSubview($0)
				})
			}

		} else {
			if let label = viewWithTag(123 + removeIndex!) {
				label.removeFromSuperview()
				removeIndex == 0 ? saveTip_A_asShown() : saveTip_B_asShown()
			}
		}

	}


	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}


extension WriteView {

	var bigBlockHeight: CGFloat! {
		return (ScreenHeight - 100) / 3
	}

	var dotLength: CGFloat! {
		return 50
	}

	var bottomSignFrame: CGRect {
		return CGRectMake(0, ScreenHeight - 20, ScreenWidth, 20)
	}

	func blockFrames() -> [CGRect] {
		func blockFrame(index: Int) -> CGRect {
			let addend = index == 0 ? 0 : smallBlockHeight
			let factor = index == 0 ? 0 : CGFloat(index - 1)
			let y = addend + bigBlockHeight * factor
			let height = (index == 0 || index == 4) ? smallBlockHeight : bigBlockHeight
			return CGRectMake(0, y, ScreenWidth, height)
		}

		let indexes = [0, 1, 2, 3, 4]
		return indexes.map({ blockFrame($0) })
	}

	func activateBlockFrames() -> [CGRect] {
		func activateBlockFrame(index: Int) -> CGRect {
			let smallBlockheight_1: CGFloat = 70
			let bigBlockHeight_1 = (ScreenHeight - smallBlockheight_1 * 2) / 3

			let addend = index == 0 ? 0 : smallBlockheight_1
			let factor = index == 0 ? 0 : CGFloat(index - 1)
			let y = addend + bigBlockHeight_1 * factor
			let height = (index == 0 || index == 4) ? smallBlockheight_1 : bigBlockHeight_1
			return CGRectMake(0, y, ScreenWidth - 100, height)
		}

		let indexes = [0, 1, 2, 3, 4]
		return indexes.map({ activateBlockFrame($0) })
	}

	func dotFrames() -> [CGRect] {
		func dotFrame(index: Int) -> CGRect {
			let activate = activateDotFrame(index)
			let x = activate.origin.x + 5
			let y = activate.origin.y + 5
			return CGRectMake(x, y, activate.width - 10, activate.height - 10)
		}

		let indexes = [0, 1, 2, 3]
		return indexes.map({ dotFrame($0) })
	}

	func activateDotFrames() -> [CGRect] {
		let indexes = [0, 1, 2, 3]
		return indexes.map({ activateDotFrame($0) })
	}

	func activateDotFrame(index: Int) -> CGRect {
		let x = ScreenWidth - 50
		let y = bigBlockHeight * CGFloat(index)
		return CGRectMake(x, y, dotLength, dotLength)
	}

	func tipViewFrames() -> [CGRect] {
		let width: CGFloat = 40
		let twoX = [5, ScreenWidth - width - 5]
		let y = smallBlockHeight + bigBlockHeight + 5
		let height = bigBlockHeight - 60
		return [CGRectMake(twoX[0], y, width, height), CGRectMake(twoX[1], y, width, height)]
	}
}
