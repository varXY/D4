//
//  InputViewController.swift
//  D4
//
//  Created by 文川术 on 4/4/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

protocol InputViewControllerDelegate: class {
	func inputTextViewDidReturn(_ index: Int, text: String)
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

	override var prefersStatusBarHidden : Bool {
		return true
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = MyColor.code(colorCode).BTColors[0]
//		transitioningDelegate = self

		numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 60))
		numberLabel.backgroundColor = UIColor.clear
		numberLabel.textColor = MyColor.code(colorCode).BTColors[1]
		numberLabel.alpha = elementAlpha
		numberLabel.textAlignment = .center
		numberLabel.font = UIFont.boldSystemFont(ofSize: 28)
		numberLabel.text = String(textLimit)
		view.addSubview(numberLabel)

		let factor: CGFloat = ScreenHeight != 480 ? 0.38 : 0.3
		textView = UITextView(frame: CGRect(x: 0, y: 60, width: ScreenWidth, height: ScreenHeight * factor))
		textView.backgroundColor = UIColor.clear
		textView.tintColor = MyColor.code(colorCode).BTColors[1]
//		textView.textColor = MyColor.code(colorCode).BTColors[1]
//		textView.font = UIFont.systemFontOfSize(25)
//		textView.textAlignment = .Center
		textView.textContainerInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
		textView.delegate = self
		view.addSubview(textView)
        
        textView.typingAttributes = textAttributes(MyColor.code(colorCode).BTColors[1], font: UIFont.systemFont(ofSize: 25))

		if index == 0 || index == 4 {
			let length = textView.frame.size.height / 2 - 40
			textView.frame.size.height -= length
			textView.frame.origin.y += length

			if index == 0 {
				var addend: CGFloat = 0
				if ScreenHeight == 568 { addend = -40 }
				if ScreenHeight == 480 { addend = -70 }

				let dayLabel = UILabel(frame: CGRect(x: 0, y: textView.frame.origin.y + textView.frame.height + addend, width: ScreenWidth, height: 40))
				dayLabel.text = "的一天"
				dayLabel.backgroundColor = UIColor.clear
				dayLabel.textColor = MyColor.code(colorCode).BTColors[1]
				dayLabel.alpha = elementAlpha
				dayLabel.textAlignment = .center
				dayLabel.font = UIFont.boldSystemFont(ofSize: 28)
				view.addSubview(dayLabel)
			}

		}

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if index == 0 && oldText != "" && oldText.characters.count >= 3 {
			oldText = String(oldText.characters.dropLast())
			oldText = String(oldText.characters.dropLast())
			oldText = String(oldText.characters.dropLast())
		}

//		textView.text = oldText
        textView.attributedText = textWithStyle(oldText, color: MyColor.code(colorCode).BTColors[1], font: UIFont.systemFont(ofSize: 25))
		numberLabel.text = String(textLimit - oldText.characters.count)

		if ScreenWidth != 320 { textView.becomeFirstResponder() }
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if ScreenWidth == 320 { textView.becomeFirstResponder() }
	}

	func addBackButton() {
		let backButton = UIButton(type: .system)
		backButton.frame = CGRect(x: 0, y: ScreenHeight / 2 + 20, width: ScreenWidth, height: ScreenHeight / 2 - 20)
		backButton.setImage(UIImage(named: "Pointer"), for: UIControlState())
		backButton.transform = CGAffineTransform(rotationAngle: CGFloat(180 * M_PI / 180))
		backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
		backButton.tintColor = MyColor.code(colorCode).BTColors[1]
		backButton.isExclusiveTouch = true
		view.addSubview(backButton)
	}

	func back() {
		if newLimit >= 0 {
			delegate?.inputTextViewDidReturn(index, text: textView.text)
			dismiss(animated: true, completion: nil)
		}
	}

	func randomAlertText() -> String {
		let alertTexts = [
			"写那么多干嘛",
			"注意简洁",
			"话太多",
			"少说两句"
		]
		let index = Int(arc4random_uniform(UInt32(alertTexts.count)))
		return alertTexts[index]
	}
}

extension InputViewController: UITextViewDelegate {

	func textViewDidChange(_ textView: UITextView) {
		let alertColor = colorCode == 14 ? MyColor.code(34).BTColors[0] : UIColor.red

		if let range = textView.text.range(of: "\n") {
			textView.text.removeSubrange(range)

			if newLimit >= 0 {
				textView.resignFirstResponder()

				var text = ""
				if index == 0 {
					if textView.text != "" {
						text = textView.attributedText.string + "的一天"
					}
				} else {
					text = textView.attributedText.string
				}

				delegate?.inputTextViewDidReturn(index, text: text)
				dismiss(animated: true, completion: nil)
			} else {
				UIView.animate(withDuration: 0.1, animations: {
					self.numberLabel.alpha = 0.0
					}, completion: { (_) in
						self.numberLabel.text = self.randomAlertText()
						self.numberLabel.textColor = MyColor.code(self.colorCode).BTColors[1]
						UIView.animate(withDuration: 0.2, animations: { 
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
			let count = textView.attributedText.string.characters.count
			newLimit = textLimit - count
			numberLabel.text = String(newLimit)
			numberLabel.textColor = newLimit < 0 ? alertColor : MyColor.code(colorCode).BTColors[1]
		}

	}

	func textViewDidEndEditing(_ textView: UITextView) {
		delay(seconds: 1.5) { self.addBackButton() }
	}
}

extension InputViewController: UIViewControllerTransitioningDelegate {

	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BounceAnimationController()
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return FadeOutAnimationController()
	}
}
