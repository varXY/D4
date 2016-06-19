//
//  InputViewController.swift
//  D4
//
//  Created by 文川术 on 4/4/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

protocol InputViewControllerDelegate: class {
	func inputTextViewDidReturn(index: Int, text: String)
}

class InputViewController: UIViewController {

	var index: Int! {
		didSet {
			switch index {
			case 0: textLimit = 7
			case 1, 2, 3: textLimit = 100
			case 4: textLimit = 20
			default: break
			}
		}
	}

	var oldText = ""
	var colorCode: Int!
	var textLimit = 0
	var newLimit = 0
	var numberLabel: UILabel!
	var textView: UITextView!

	var allowInput = true

	let elementAlpha: CGFloat = 0.6

	weak var delegate: InputViewControllerDelegate?

	override func prefersStatusBarHidden() -> Bool {
		return true
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = MyColor.code(colorCode).BTColors[0]
//		transitioningDelegate = self

		numberLabel = UILabel(frame: CGRectMake(0, 0, ScreenWidth, 60))
		numberLabel.backgroundColor = UIColor.clearColor()
		numberLabel.textColor = MyColor.code(colorCode).BTColors[1]
		numberLabel.alpha = elementAlpha
		numberLabel.textAlignment = .Center
		numberLabel.font = UIFont.boldSystemFontOfSize(28)
		numberLabel.text = String(textLimit)
		view.addSubview(numberLabel)

		let factor: CGFloat = ScreenHeight != 480 ? 0.38 : 0.3
		textView = UITextView(frame: CGRectMake(0, 60, ScreenWidth, ScreenHeight * factor))
		textView.backgroundColor = UIColor.clearColor()
		textView.tintColor = MyColor.code(colorCode).BTColors[1]
		textView.textColor = MyColor.code(colorCode).BTColors[1]
		textView.font = UIFont.systemFontOfSize(25)
		textView.textAlignment = .Center
		textView.textContainerInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
		textView.delegate = self
		view.addSubview(textView)

		if index == 0 || index == 4 {
			let length = textView.frame.size.height / 2 - 40
			textView.frame.size.height -= length
			textView.frame.origin.y += length

			if index == 0 {
				var addend: CGFloat = 0
				if ScreenHeight == 568 { addend = -40 }
				if ScreenHeight == 480 { addend = -70 }

				let dayLabel = UILabel(frame: CGRectMake(0, textView.frame.origin.y + textView.frame.height + addend, ScreenWidth, 40))
				dayLabel.text = "的一天"
				dayLabel.backgroundColor = UIColor.clearColor()
				dayLabel.textColor = MyColor.code(colorCode).BTColors[1]
				dayLabel.alpha = elementAlpha
				dayLabel.textAlignment = .Center
				dayLabel.font = UIFont.boldSystemFontOfSize(28)
				view.addSubview(dayLabel)
			}

		}

	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if index == 0 && oldText != "" && oldText.characters.count >= 3 {
			oldText = String(oldText.characters.dropLast())
			oldText = String(oldText.characters.dropLast())
			oldText = String(oldText.characters.dropLast())
		}

		textView.text = oldText
		numberLabel.text = String(textLimit - oldText.characters.count)

		if ScreenWidth != 320 { textView.becomeFirstResponder() }
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if ScreenWidth == 320 { textView.becomeFirstResponder() }
	}

	func addBackButton() {
		let backButton = UIButton(type: .System)
		backButton.frame = CGRectMake(0, ScreenHeight / 2 + 20, ScreenWidth, ScreenHeight / 2 - 20)
		backButton.setImage(UIImage(named: "Pointer"), forState: .Normal)
		backButton.transform = CGAffineTransformMakeRotation(CGFloat(180 * M_PI / 180))
		backButton.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
		backButton.tintColor = MyColor.code(colorCode).BTColors[1]
		backButton.exclusiveTouch = true
		view.addSubview(backButton)
	}

	func back() {
		if newLimit >= 0 {
			delegate?.inputTextViewDidReturn(index, text: textView.text)
			dismissViewControllerAnimated(true, completion: nil)
		}
	}

	func randomAlertText() -> String {
		let alertTexts = [
			"写那么多干嘛",
			"注意简洁",
			"话太多",
			"少说两句"
		]
		let index = random() % alertTexts.count
		return alertTexts[index]
	}
}

extension InputViewController: UITextViewDelegate {

	func textViewDidChange(textView: UITextView) {
		let alertColor = colorCode == 14 ? MyColor.code(34).BTColors[0] : UIColor.redColor()

		if let range = textView.text.rangeOfString("\n") {
			textView.text.removeRange(range)

			if newLimit >= 0 {
				textView.resignFirstResponder()

				var text = ""
				if index == 0 {
					if textView.text != "" {
						text = textView.text + "的一天"
					}
				} else {
					text = textView.text
				}

				delegate?.inputTextViewDidReturn(index, text: text)
				dismissViewControllerAnimated(true, completion: nil)
			} else {
				UIView.animateWithDuration(0.1, animations: {
					self.numberLabel.alpha = 0.0
					}, completion: { (_) in
						self.numberLabel.text = self.randomAlertText()
						self.numberLabel.textColor = MyColor.code(self.colorCode).BTColors[1]
						UIView.animateWithDuration(0.2, animations: { 
							self.numberLabel.alpha = self.elementAlpha
							}, completion: { (_) in
								delay(seconds: 0.3, completion: { 
									self.numberLabel.text = String(self.newLimit)
									self.numberLabel.textColor = alertColor
								})
						})
				})
			}

		} else {
			let count = textView.text.characters.count
			newLimit = textLimit - count
			numberLabel.text = String(newLimit)
			numberLabel.textColor = newLimit < 0 ? alertColor : MyColor.code(colorCode).BTColors[1]
		}

	}

	func textViewDidEndEditing(textView: UITextView) {
		delay(seconds: 1.5) { self.addBackButton() }
	}
}

extension InputViewController: UIViewControllerTransitioningDelegate {

	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BounceAnimationController()
	}

	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return FadeOutAnimationController()
	}
}