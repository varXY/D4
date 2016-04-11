//
//  InputViewController.swift
//  D4
//
//  Created by 文川术 on 4/4/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

protocol InputTextViewDelegate: class {
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

	weak var delegate: InputTextViewDelegate?

	override func prefersStatusBarHidden() -> Bool {
		return true
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		modalPresentationStyle = .Custom
		transitioningDelegate = self

		view.backgroundColor = MyColor.code(colorCode).BTColors[0]

		numberLabel = UILabel(frame: CGRectMake(0, 0, ScreenWidth, 60))
		numberLabel.backgroundColor = UIColor.clearColor()
		numberLabel.textColor = MyColor.code(colorCode).BTColors[1]
		numberLabel.alpha = 0.5
		numberLabel.textAlignment = .Center
		numberLabel.font = UIFont.boldSystemFontOfSize(28)
		numberLabel.text = String(textLimit)
		view.addSubview(numberLabel)

		textView = UITextView(frame: CGRectMake(0, 60, ScreenWidth, ScreenHeight / 2 - 100))
		textView.backgroundColor = UIColor.clearColor()
		textView.tintColor = MyColor.code(colorCode).BTColors[1]
		textView.textColor = MyColor.code(colorCode).BTColors[1]
		textView.font = UIFont.systemFontOfSize(25)
		textView.textAlignment = .Center
		textView.delegate = self
		view.addSubview(textView)

		if index == 0 || index == 4 {
			let length = textView.frame.size.height / 2 - 40
			textView.frame.size.height -= length
			textView.frame.origin.y += length

			if index == 0 {
				let dayLabel = UILabel(frame: CGRectMake(0, textView.frame.origin.y + textView.frame.height, ScreenWidth, 40))
				dayLabel.text = "的一天"
				dayLabel.backgroundColor = UIColor.clearColor()
				dayLabel.textColor = MyColor.code(colorCode).BTColors[1]
				dayLabel.alpha = 0.5
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


		textView.becomeFirstResponder()
	}

	func randomAlertText() -> String {
		let alertTexts = [
			"写那么多干嘛",
			"要相信简洁的力量",
			"浓缩的是精华",
			"话太多",
			"少说两句"
		]
		let index = random() % alertTexts.count
		return alertTexts[index]
	}
}

extension InputViewController: UITextViewDelegate {

	func textViewDidChange(textView: UITextView) {

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
				UIView.animateWithDuration(0.2, animations: { 
					self.numberLabel.alpha = 0.0
					}, completion: { (_) in
						self.numberLabel.text = self.randomAlertText()
						UIView.animateWithDuration(0.2, animations: { 
							self.numberLabel.alpha = 0.5
							}, completion: { (_) in
								delay(seconds: 0.3, completion: { 
									self.numberLabel.text = String(self.newLimit)
								})
						})
				})
			}

		} else {
			let count = textView.text.characters.count
			newLimit = textLimit - count
			numberLabel.text = String(newLimit)
			numberLabel.textColor = newLimit < 0 ? UIColor.redColor() : MyColor.code(colorCode).BTColors[1]
		}
	}
}

extension InputViewController: UIViewControllerTransitioningDelegate {

	func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
		return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)

	}

	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BounceAnimationController()
	}

	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return SlideOutAnimationController()

	}
}