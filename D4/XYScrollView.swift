//
//  XYScrollView.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

@objc enum XYScrollType: Int {
	case Up, Down, Left, Right, NotScrollYet
}

@objc protocol XYScrollViewDelegate: class {
	func xyScrollViewDidScroll(scrollType: XYScrollType, topViewIndex: Int)
	optional func xyScrollViewWillScroll(scrollType: XYScrollType, topViewIndex: Int)
	optional func writeViewWillInputText(index: Int, oldText: String, colorCode: Int)
	optional func didSelectedStory(storyIndex: Int)
	func scrollTypeDidChange(type: XYScrollType)
}

class XYScrollView: UIScrollView {

	var X0_contentView: UIScrollView!
	var X1_contentView: UIScrollView!
	var X1_storyTableView: StoryTableView!
	var X2_contentView: UIScrollView!

	var writeView: WriteView!
	var settingView: SettingView!

	var Y0_storyView: StoryView!
	var Y1_storyView: StoryView!
	var Y2_storyView: StoryView!

	var topView: UIScrollView!
	var middleView: UIScrollView!
	var bottomView: UIScrollView!

	let topOrigin = CGPoint(x: 0, y: -ScreenHeight)
	let middleOrigin = CGPoint(x: 0, y: 0)
	let bottomOrigin = CGPoint(x: 0, y: ScreenHeight)

	var storys: [Story]! {
		didSet {
			if X1_storyTableView != nil {
				X1_storyTableView.storys = storys
			}
		}
	}

	var initTopStoryIndex: Int! {
		didSet {
			if initTopStoryIndex != 0 {
				let storyView_0 = StoryView(story: storys[initTopStoryIndex - 1])
				storyView_0.tag = 110
				X0_contentView.addSubview(storyView_0)
			} else {
				let storyView_0 = StoryView(story: storys[initTopStoryIndex])
				storyView_0.tag = 110
				X0_contentView.addSubview(storyView_0)
			}

			let storyView_1 = StoryView(story: storys[initTopStoryIndex])
			storyView_1.tag = 110
			X1_contentView.addSubview(storyView_1)

			if initTopStoryIndex != storys.count - 1 {
				let storyView_2 = StoryView(story: storys[initTopStoryIndex + 1])
				storyView_2.tag = 110
				X2_contentView.addSubview(storyView_2)
			} else {
				let storyView_2 = StoryView(story: storys[initTopStoryIndex])
				storyView_2.tag = 110
				X2_contentView.addSubview(storyView_2)
			}

			topStoryIndex = initTopStoryIndex
		}
	}

	var topStoryIndex = 0

	var inMainVC = false
	var doneReorder = true
	var topViewIndex = 1

	var scrolledType: XYScrollType = .NotScrollYet {
		didSet {
			XYDelegate?.scrollTypeDidChange(scrolledType)
		}
	}

	weak var XYDelegate: XYScrollViewDelegate?

	var animateTime: Double = 0.4

	init(VC: UIViewController) {
		super.init(frame: VC.view.bounds)
		backgroundColor = UIColor.clearColor()
		contentSize = CGSize(width: frame.width, height: 0)
		alwaysBounceHorizontal = true
		commonSetUp(self)

		X0_contentView = UIScrollView(frame: bounds)
		X2_contentView = UIScrollView(frame: bounds)
		commonSetUp(X0_contentView)
		commonSetUp(X2_contentView)

		switch VC {
		case is MainViewController:
			inMainVC = true

			X0_contentView.frame.origin.x = -ScreenWidth
			X0_contentView.contentSize = CGSize(width: 0, height: frame.height)
			X0_contentView.alwaysBounceVertical = true
			writeView = WriteView()
			writeView.delegate = self
			X0_contentView.addSubview(writeView)
			X0_contentView.alpha = 0.0
			X0_contentView.decelerationRate = UIScrollViewDecelerationRateFast

			X1_storyTableView = StoryTableView(frame: bounds, storys: [Story]())
			X1_storyTableView.scrollsToTop = false
			X1_storyTableView.SDelegate = self

			X2_contentView.frame.origin.x = ScreenWidth
			X2_contentView.contentSize = CGSize(width: 0, height: frame.height)
			X2_contentView.alwaysBounceVertical = true
			settingView = SettingView()
			X2_contentView.addSubview(settingView)
			X2_contentView.alpha = 0.0
			X2_contentView.decelerationRate = UIScrollViewDecelerationRateFast

			addSubview(X1_storyTableView)
			addSubview(X0_contentView)
			addSubview(X2_contentView)

		case is DetailViewController:
			X0_contentView.frame.origin.y = -ScreenHeight
			X0_contentView.contentSize = CGSize(width: 0, height: frame.height)
			X0_contentView.alwaysBounceVertical = true
			X0_contentView.alpha = 0.0

			X1_contentView = UIScrollView(frame: bounds)
			commonSetUp(X1_contentView)
			X1_contentView.contentSize = CGSize(width: 0, height: frame.height)
			X1_contentView.alwaysBounceVertical = true

			X2_contentView.frame.origin.y = ScreenHeight
			X2_contentView.contentSize = CGSize(width: 0, height: frame.height)
			X2_contentView.alwaysBounceVertical = true
			X2_contentView.alpha = 0.0

			topView = X0_contentView
			middleView = X1_contentView
			bottomView = X2_contentView

			addSubview(X0_contentView)
			addSubview(X1_contentView)
			addSubview(X2_contentView)

		default:
			break

		}

	}

	func commonSetUp(scrollView: UIScrollView) {
		scrollView.layer.cornerRadius = globalRadius
		scrollView.clipsToBounds = true
		scrollView.exclusiveTouch = true
		scrollView.directionalLockEnabled = true
		scrollView.scrollsToTop = false
		scrollView.delegate = self
	}


	func moveContentViewToTop(scrollType: XYScrollType) {
		if inMainVC {
			if topViewIndex == 1 {
				switch scrollType {
				case .Left:
					topViewIndex = 0
					X0_contentView.alpha = 1.0
					let notClear = X1_storyTableView.backgroundColor != UIColor.clearColor()
					if notClear { X1_storyTableView.backgroundColor = UIColor.clearColor() }

					animate({
						self.X1_storyTableView.alpha = 0.0
						self.X0_contentView.frame.origin.x += ScreenWidth
						}, completion: {
							if notClear { self.X1_storyTableView.backgroundColor = MyColor.code(5).BTColors[0] }
							delay(seconds: 0.5, completion: {
								self.writeView.layer.cornerRadius = globalRadius
							})
					})

				case .Right:
					topViewIndex = 2
					X2_contentView.alpha = 1.0
					let notClear = X1_storyTableView.backgroundColor != UIColor.clearColor()
					if notClear { X1_storyTableView.backgroundColor = UIColor.clearColor() }

					animate({
						self.X1_storyTableView.alpha = 0.0
						self.X2_contentView.frame.origin.x -= ScreenWidth
						}, completion: { 
							if notClear { self.X1_storyTableView.backgroundColor = MyColor.code(5).BTColors[0] }
					})
					
				default: break
				}
			}

			if topViewIndex == 0 {
				switch scrollType {
				case .Right:
					topViewIndex = 1
					X1_storyTableView.alpha = 1.0
					
					animate({
						self.X0_contentView.alpha = 0.0
						self.X0_contentView.frame.origin.x -= ScreenWidth
						}, completion: { 
							self.writeView.layer.cornerRadius = 0
					})

				default: break
				}
			}

			if topViewIndex == 2 {
				switch scrollType {
				case .Left:
					topViewIndex = 1
					X1_storyTableView.alpha = 1.0

					animate({
						self.X2_contentView.alpha = 0.0
						self.X2_contentView.frame.origin.x += ScreenWidth
						}, completion: { 

					})

				default: break
				}
			}

		} else {

			switch scrolledType {
			case .Up:
				if topStoryIndex >= 1 && doneReorder {
					topStoryIndex -= 1
					doneReorder = false

					changeStoryForContentView(topView, storyIndex: topStoryIndex)
					bringSubviewToFront(topView)
					topView.alpha = 1.0

					animate({
						self.middleView.alpha = 0.0
						self.topView.frame.origin = self.middleOrigin
						}, completion: {
							self.middleView.frame.origin = self.topOrigin

							if self.topStoryIndex > 1 {
								self.changeStoryForContentView(self.middleView, storyIndex: self.topStoryIndex - 1)
							}

							self.reorderView()
					})



				}


			case .Down:
				if topStoryIndex <= storys.count - 2 && doneReorder {
					topStoryIndex += 1
					doneReorder = false

					changeStoryForContentView(bottomView, storyIndex: topStoryIndex)
					bringSubviewToFront(bottomView)
					bottomView.alpha = 1.0

					animate({
						self.middleView.alpha = 0.0
						self.bottomView.frame.origin = self.middleOrigin
						}, completion: { 
							self.middleView.frame.origin = self.bottomOrigin

							if self.topStoryIndex < self.storys.count - 1 {
								self.changeStoryForContentView(self.middleView, storyIndex: self.topStoryIndex + 1)
							}

							self.reorderView()
					})

				}


			default:
				break
			}

		}

	}

	func animate(animations: () -> (), completion: (() -> ())?) {
		UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: {
			animations()
			}) { (_) in
				completion!()
		}
	}

	func changeStoryForContentView(contentView: UIScrollView, storyIndex: Int) {
		if let storyView = contentView.viewWithTag(110) as? StoryView {
			storyView.reloadStory(storys[storyIndex])
		}
	}

	func reorderView() {
		let contentViews = [X0_contentView, X1_contentView, X2_contentView]
		for contentView in contentViews {
			if contentView.frame.origin == topOrigin { topView = contentView }
			if contentView.frame.origin == middleOrigin { middleView = contentView }
			if contentView.frame.origin == bottomOrigin { bottomView = contentView }
		}
		doneReorder = true
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


}


extension XYScrollView: UIScrollViewDelegate {

	func scrollViewDidScroll(scrollView: UIScrollView) {
		if scrollView != self {
			if scrollView.contentOffset.y > TriggerDistance {
				if scrolledType != .Down { scrolledType = .Down }
			} else if scrollView.contentOffset.y < -TriggerDistance {
				if scrolledType != .Up { scrolledType = .Up }
			} else {
				if scrolledType != .NotScrollYet { scrolledType = .NotScrollYet }
			}
		} else {
			if scrollView.contentOffset.x < -TriggerDistance {
				if scrolledType != .Left { scrolledType = .Left }
			} else if scrollView.contentOffset.x > TriggerDistance {
				if scrolledType != .Right { scrolledType = .Right }
			} else {
				if scrolledType != .NotScrollYet { scrolledType = .NotScrollYet }
			}
		}

	}

	func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		XYDelegate?.xyScrollViewWillScroll?(scrolledType, topViewIndex: topViewIndex)
		moveContentViewToTop(scrolledType)
		if !inMainVC { topViewIndex = topStoryIndex }
		XYDelegate?.xyScrollViewDidScroll(scrolledType, topViewIndex: topViewIndex)
		scrolledType = .NotScrollYet
	}

}

extension XYScrollView: StoryTableViewDelegate {

	func didSelectedStory(storyIndex: Int) {
		XYDelegate?.didSelectedStory!(storyIndex)
	}
}

extension XYScrollView: WriteViewDelegate {

	func selectingColor(selecting: Bool) {
		scrollEnabled = !selecting
		X0_contentView.scrollEnabled = !selecting
	}

	func willInputText(index: Int, oldText: String, colorCode: Int) {
		XYDelegate?.writeViewWillInputText!(index, oldText: oldText, colorCode: colorCode)
	}

}






