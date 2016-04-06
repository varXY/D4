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

	var index: Int!
	var oldText: String?
	var colorCode: Int!
	var textView: UITextView!

	weak var delegate: InputTextViewDelegate?

	override func prefersStatusBarHidden() -> Bool {
		return true
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		modalPresentationStyle = .Custom
		transitioningDelegate = self

		view.backgroundColor = MyColor.code(colorCode).BTColors[0]

		textView = UITextView(frame: CGRectMake(0, 50, ScreenWidth, ScreenHeight / 2 - 90))
		textView.backgroundColor = UIColor.clearColor()
		textView.tintColor = MyColor.code(colorCode).BTColors[1]
		textView.textColor = MyColor.code(colorCode).BTColors[1]
		textView.font = UIFont.systemFontOfSize(25)
		textView.textAlignment = .Center
		textView.delegate = self
		view.addSubview(textView)

		if oldText != nil {
			textView.text = oldText
		}

		textView.becomeFirstResponder()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		view.backgroundColor = UIColor.clearColor()
	}
}

extension InputViewController: UITextViewDelegate {

	func textViewDidChange(textView: UITextView) {
		if let range = textView.text.rangeOfString("\n") {
			textView.text.removeRange(range)
			textView.resignFirstResponder()
			delegate?.inputTextViewDidReturn(index, text: textView.text)
			dismissViewControllerAnimated(true, completion: nil)
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