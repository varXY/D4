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
	func ratingChanged(index: Int, rating: Int)
}

class DetailViewController: UIViewController, LeanCloud, UserDefaults {

	var xyScrollView: XYScrollView!
	var pointerView: PointerView!
	var rateViews: RateViews!

	var storys: [Story]!
	var topStoryIndex: Int!
	var cellRectHeight: Int!

	var blurEffect: UIBlurEffect!

	var rateViewShowed = false

	weak var delegate: DetailViewControllerDelegate?

	override func prefersStatusBarHidden() -> Bool {
		return true
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		transitioningDelegate = self
		
		pointerView = PointerView(VC: self)
		view = pointerView

		xyScrollView = XYScrollView(VC: self)
		xyScrollView.storys = storys
		xyScrollView.initTopStoryIndex = topStoryIndex
		xyScrollView.XYDelegate = self
		view.addSubview(xyScrollView)

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureReceived))
		view.addGestureRecognizer(tapGesture)

	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		showPointerTextBaseOnStoryIndex(topStoryIndex)
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		rateViews = RateViews(VC: self, effect: blurEffect)
		rateViews.likedIndexes = likedStoryIndexes()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		delegate?.detailViewControllerWillDismiss(topStoryIndex)
	}

	func showPointerTextBaseOnStoryIndex(index: Int) {
		pointerView.showNoMore(nil)
		
		if index == 0 {
			pointerView.showNoMore(true)
			if storys.count == 1 {
				pointerView.showNoMore(false)
			}
		} else if index == storys.count - 1 {
			pointerView.showNoMore(false)
		} else {
			pointerView.showNoMore(nil)
		}
	}

	func rateButtonTapped(sender: UIButton) {
		let like = sender.tag == 100
		storys[topStoryIndex].rating += like ? 1 : -1
		updateRating(storys[topStoryIndex].ID, rating: storys[topStoryIndex].rating)
		delegate?.ratingChanged(topStoryIndex, rating: storys[topStoryIndex].rating)
		
		rateViews.ratingLabel.text = "\(storys[topStoryIndex].rating)"
		rateViews.hideAfterTapped()
		rateViewShowed = false

		saveLikedStoryIndex(topStoryIndex)
		rateViews.likedIndexes = likedStoryIndexes()
	}

	func tapGestureReceived() {
		rateViewShowed = !rateViewShowed
		rateViews.show(rateViewShowed, rating: storys[topStoryIndex].rating, storyIndex: topStoryIndex)
	}
}

extension DetailViewController: XYScrollViewDelegate {

	func scrollTypeDidChange(type: XYScrollType) {
		pointerView.changePointerDirection(type)
	}

	func xyScrollViewWillScroll(scrollType: XYScrollType, topViewIndex: Int) {
		if rateViewShowed {
			rateViewShowed = false
			rateViews.show(rateViewShowed, rating: storys[topStoryIndex].rating, storyIndex: topStoryIndex)
		}
	}

	func xyScrollViewDidScroll(scrollType: XYScrollType, topViewIndex: Int) {
		topStoryIndex = topViewIndex
		showPointerTextBaseOnStoryIndex(topStoryIndex)

		switch scrollType {
		case .Left:
			dismissViewControllerAnimated(true, completion: nil)
		case .Right:
			tapGestureReceived()
		default:
			break
		}
	}

}


extension DetailViewController: UIViewControllerTransitioningDelegate {

	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BounceAnimationController()
	}

	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return SlideOutAnimationController()
		
	}
}