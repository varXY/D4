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

	lazy var previewActions: [UIPreviewActionItem] = {
		func previewActionForTitle(title: String, style: UIPreviewActionStyle = .Default) -> UIPreviewAction {
			return UIPreviewAction(title: title, style: style) { previewAction, viewController in
				guard let detailViewController = viewController as? DetailViewController else { return }
				let like = previewAction.title == "顶"
				detailViewController.likeItOrNot(like, forceTouchWay: true)
			}
		}

		let action0 = previewActionForTitle("顶")
		let action1 = previewActionForTitle("踩")

		return [action0, action1]
	}()

	var xyScrollView: XYScrollView!
	var pointerView: PointerView!
	var rateViews: RateViews!

	var storys: [Story]!
	var topStoryIndex: Int!

	var nightStyle = false
	var netOrLocalStory = 0
	var rateViewShowed = false

	weak var delegate: DetailViewControllerDelegate?

	override func previewActionItems() -> [UIPreviewActionItem] {
		return !likedStoryIndexes().contains(topStoryIndex) && netOrLocalStory != 1 ? previewActions : []
	}

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

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showOrHideRateViews))
		view.addGestureRecognizer(tapGesture)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		showPointerTextBaseOnStoryIndex(topStoryIndex)
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		pointerView.nightStyle = nightStyle
		
		rateViews = RateViews(VC: self)
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
		view.userInteractionEnabled = false

		let like = sender.tag == 100
		let amount = like ? 1 : -1
		let newRating = storys[topStoryIndex].rating + amount

		saveLikedStoryIndex(topStoryIndex)
		rateViews.likedIndexes = likedStoryIndexes()
		likeItOrNot(like, forceTouchWay: false)

		rateViews.ratingLabel.text = "\(newRating)"
		rateViews.hideAfterTapped({ self.view.userInteractionEnabled = true })
		rateViewShowed = false
	}

	func likeItOrNot(like: Bool, forceTouchWay: Bool) {
		let amount = like ? 1 : -1
		let newRating = storys[topStoryIndex].rating + amount

		if forceTouchWay {
			saveLikedStoryIndex(topStoryIndex)
			rateViews.likedIndexes = likedStoryIndexes()
		}

		let topIndex = topStoryIndex
		updateRating(storys[topIndex].ID, rating: newRating, done: { (success) in
			if success {
				self.storys[topIndex].rating = newRating
				self.delegate?.ratingChanged(topIndex, rating: self.storys[topIndex].rating)
			} else {
				self.removeLikedStoryIndex(self.topStoryIndex)
				self.rateViews.likedIndexes = self.likedStoryIndexes()

				let hudView = HudView.hudInView(self.view, animated: true)
				hudView.text = "无法联网\n操作失效"
				hudView.nightStyle = self.nightStyle
			}
		})

	}

	func showOrHideRateViews() {
		rateViewShowed = !rateViewShowed
		rateViews.show(rateViewShowed, rating: storys[topStoryIndex].rating, storyIndex: topStoryIndex)
	}
}

extension DetailViewController: XYScrollViewDelegate {

	func xyScrollViewDidBeginScroll(begin: Bool, type: XYScrollType) {
//		pointerView.showAllSubviews(begin, VC: self, type: type)
	}

	func scrollTypeDidChange(type: XYScrollType) {
		pointerView.showPointer(type)
	}

	func xyScrollViewWillScroll(scrollType: XYScrollType, topViewIndex: Int) {
		pointerView.hidePointersAndLabels()

//		if scrollType != .NotScrollYet {
//			pointerView.pointers[scrollType.rawValue].alpha = 0.0
//			pointerView.UDLR_labels[scrollType.rawValue].alpha = 0.0
//		}

		if rateViewShowed && (scrollType == .Up || scrollType == .Down) {
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
			netOrLocalStory != 1 ? showOrHideRateViews() : copyTextOfStory()

		default:
			break
		}
	}

	func copyTextOfStory() {
		let text = storys[topStoryIndex].sentences.reduce("", combine: { $0 + $1 + "\n\n" })
		UIPasteboard.generalPasteboard().string = text

		let hudView = HudView.hudInView(view, animated: true)
		hudView.text = "已复制"
		hudView.nightStyle = nightStyle
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