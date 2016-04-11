//
//  DetailViewController.swift
//  D4
//
//  Created by 文川术 on 4/6/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

protocol DetailViewControllerDelegate: class {
	func detailViewControllerWillDismiss(topStoryIndex: Int)
}

class DetailViewController: UIViewController {

	var xyScrollView: XYScrollView!
	var pointerView: PointerView!

	var storys: [Story]!
	var topStoryIndex: Int!
	var cellRectHeight: Int!

	weak var delegate: DetailViewControllerDelegate?

	override func prefersStatusBarHidden() -> Bool {
		return true
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		modalPresentationStyle = .Custom
		transitioningDelegate = self

		pointerView = PointerView(VC: self)
		view = pointerView

		xyScrollView = XYScrollView(VC: self)
		xyScrollView.storys = storys
		xyScrollView.initTopStoryIndex = topStoryIndex
		xyScrollView.XYDelegate = self
		view.addSubview(xyScrollView)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		delegate?.detailViewControllerWillDismiss(topStoryIndex)
	}
}

extension DetailViewController: XYScrollViewDelegate {

	func scrollTypeDidChange(type: XYScrollType) {
		pointerView.changePointerDirection(type)
	}

	func xyScrollViewDidScroll(scrollType: XYScrollType, topViewIndex: Int) {
		topStoryIndex = topViewIndex

		switch scrollType {
		case .Left:
			dismissViewControllerAnimated(true, completion: nil)
		default:
			break
		}
	}

}

extension DetailViewController: UIViewControllerTransitioningDelegate {

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