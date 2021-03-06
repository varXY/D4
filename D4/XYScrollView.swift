//
//  XYScrollView.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

@objc enum XYScrollType: Int {
	case up, down, left, right, notScrollYet
}

@objc protocol XYScrollViewDelegate: class {
	func xyScrollViewDidScroll(_ scrollType: XYScrollType, topViewIndex: Int)
	@objc optional func xyScrollViewWillScroll(_ scrollType: XYScrollType, topViewIndex: Int)
	@objc optional func writeViewWillInputText(_ index: Int, oldText: String, colorCode: Int)
	@objc optional func didSelectedStory(_ storyIndex: Int)
	func scrollTypeDidChange(_ type: XYScrollType)
}

class XYScrollView: UIScrollView {

	var contentViews: [UIScrollView]!

	var storyTableView: StoryTableView!
	var writeView: WriteView!
	var settingView: SettingView!

	fileprivate let topOrigin = CGPoint(x: 0, y: -ScreenHeight)
	fileprivate let middleOrigin = CGPoint(x: 0, y: 0)
	fileprivate let bottomOrigin = CGPoint(x: 0, y: ScreenHeight)

	var storys: [Story]! {
		didSet {
			if storyTableView != nil {
				storyTableView.storys = storys
			}
		}
	}

	var topViewIndex = 1
	var topStoryIndex = 0

	var inMainVC = false
	var doneReorder = true


	var scrolledType: XYScrollType = .notScrollYet {
		didSet {
			if scrolledType != oldValue {
				XYDelegate?.scrollTypeDidChange(scrolledType)
			}
		}
	}

	weak var XYDelegate: XYScrollViewDelegate?

	var animateTime: Double = 0.4

	init(VC: UIViewController, storys: [Story]?, topStoryIndex: Int?) {
		super.init(frame: VC.view.bounds)
		backgroundColor = UIColor.clear
		contentSize = CGSize(width: frame.width, height: 0)
		alwaysBounceHorizontal = true
		commonSetUp(self)

		switch VC {
		case is MainViewController:
			inMainVC = true

			writeView = WriteView()
			writeView.delegate = self

			settingView = SettingView()

			let origins_X = [-ScreenWidth, 0, ScreenWidth]
			contentViews = origins_X.map({
				let index = origins_X.index(of: $0)
				if index != 1 {
					let contentView = UIScrollView(frame: bounds)
					commonSetUp(contentView)
					contentView.frame.origin.x = $0
					contentView.contentSize = CGSize(width: 0, height: frame.height)
					contentView.alwaysBounceVertical = true
					contentView.alpha = 0.0
					contentView.addSubview(index == 0 ? writeView : settingView)
					addSubview(contentView)
					return contentView
				} else {
					storyTableView = StoryTableView(frame: bounds, storys: [Story]())
					storyTableView.SDelegate = self
					addSubview(storyTableView)
					return storyTableView
				}
			})

		case is DetailViewController:
			self.storys = storys
			self.topStoryIndex = topStoryIndex!
			let storyIndexes = threeIndex(topStoryIndex!)

			let origins_Y = [-ScreenHeight, 0, ScreenHeight]
			contentViews = origins_Y.map({
				let index = origins_Y.index(of: $0)!
				let contentView = UIScrollView(frame: bounds)
				commonSetUp(contentView)
				contentView.frame.origin.y = $0
				contentView.contentSize = CGSize(width: 0, height: frame.height)
				contentView.alwaysBounceVertical = true
				if index != 1 { contentView.alpha = 0.0 }

				let storyView = StoryView(story: storys![storyIndexes[index]])
				contentView.addSubview(storyView)

				addSubview(contentView)
				return contentView
			})

		default:
			break

		}

	}

	func commonSetUp(_ scrollView: UIScrollView) {
		scrollView.layer.cornerRadius = globalRadius
		scrollView.clipsToBounds = true
		scrollView.isExclusiveTouch = true
		scrollView.isDirectionalLockEnabled = true
		scrollView.isPagingEnabled = false
		scrollView.scrollsToTop = false
		scrollView.delegate = self
		scrollView.decelerationRate = UIScrollViewDecelerationRateFast
	}

	func threeIndex(_ topIndex: Int) -> [Int] {
        if storys.count == 1 { return [0, 0, 0] }
		switch topIndex {
		case 0:
			return [0, 0, 1]
		case (storys.count - 1):
			return [topIndex - 1, topIndex, topIndex]
		default:
			return [topIndex - 1, topIndex, topIndex + 1]
		}
	}


	func moveContentViewToTop(_ scrollType: XYScrollType) {
		if inMainVC {

			if topViewIndex == 1 {
				switch scrollType {
				case .left:
					topViewIndex = 0
					contentViews[0].alpha = 1.0
					contentViews[1].removeFromSuperview()
					contentViews[1].alpha = 0.0

					animate({
						self.contentViews[0].frame.origin.x += ScreenWidth
						}, completion: {
							self.addSubview(self.contentViews[1])
							self.sendSubview(toBack: self.contentViews[1])
							delay(seconds: 0.5, completion: {
								self.writeView.layer.cornerRadius = globalRadius
							})
					})

				case .right:
					topViewIndex = 2
					contentViews[2].alpha = 1.0
					contentViews[1].removeFromSuperview()
					contentViews[1].alpha = 0.0

					animate({
						self.contentViews[2].frame.origin.x -= ScreenWidth
						}, completion: {
							self.addSubview(self.contentViews[1])
							self.sendSubview(toBack: self.contentViews[1])
					})
					
				default:
					break
				}
			}

			if topViewIndex == 0 && scrollType == .right {
				topViewIndex = 1
				contentViews[1].alpha = 1.0
					
				animate({
					self.contentViews[0].alpha = 0.0
					self.contentViews[0].frame.origin.x -= ScreenWidth
					}, completion: {
						self.writeView.layer.cornerRadius = 0
				})

			}

			if topViewIndex == 2 && scrollType == .left {
				topViewIndex = 1
				contentViews[1].alpha = 1.0

				animate({ 
					self.contentViews[2].alpha = 0.0
					self.contentViews[2].frame.origin.x += ScreenWidth
					}, completion: nil)
			}

		} else {

			switch scrolledType {
			case .up:
				if topStoryIndex >= 1 && doneReorder {
					topStoryIndex -= 1
					doneReorder = false

					contentViews[0].frame.origin = middleOrigin
					contentViews[0].transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
					contentViews[0].alpha = 1.0
					removePartOfStory(contentViews[1], labelIndex: 4)

					animate({
						self.contentViews[0].transform = CGAffineTransform.identity
						self.contentViews[1].frame.origin = self.bottomOrigin
						}, completion: {
							self.sendSubview(toBack: self.contentViews[1])
							self.contentViews[1].alpha = 0.0
							self.contentViews[1].frame.origin = self.topOrigin

							let threeIndex = self.threeIndex(self.topStoryIndex)
							self.changeStoryForContentView(self.contentViews[1], storyIndex: threeIndex[0])
							self.changeStoryForContentView(self.contentViews[2], storyIndex: threeIndex[2])

							self.contentViews = [self.contentViews[1], self.contentViews[0], self.contentViews[2]]
							self.doneReorder = true
					})
				}

			case .down:
				if topStoryIndex <= storys.count - 2 && doneReorder {
					topStoryIndex += 1
					doneReorder = false

					bringSubview(toFront: contentViews[2])
					contentViews[2].alpha = 1.0
					removePartOfStory(contentViews[1], labelIndex: 0)

					animate({
						self.contentViews[1].alpha = 0.4
						self.contentViews[1].transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
						self.contentViews[2].frame.origin = self.middleOrigin
						}, completion: {
							self.contentViews[1].transform = CGAffineTransform.identity
							self.contentViews[1].alpha = 0.0
							self.contentViews[1].frame.origin = self.bottomOrigin

							let threeIndex = self.threeIndex(self.topStoryIndex)
							self.changeStoryForContentView(self.contentViews[0], storyIndex: threeIndex[0])
							self.changeStoryForContentView(self.contentViews[1], storyIndex: threeIndex[2])

							self.contentViews = [self.contentViews[0], self.contentViews[2], self.contentViews[1]]
							self.doneReorder = true
					})
				}

			default:
				break
			}

		}

	}

	func animate(_ animations: @escaping () -> (), completion: (() -> ())?) {
		UIView.perform(.delete, on: [], options: [], animations: {
			animations()
			}) { (_) in
				if completion != nil { completion!() }
		}
	}

	func changeStoryForContentView(_ contentView: UIScrollView, storyIndex: Int) {
		if let storyView = contentView.subviews[0] as? StoryView {
			storyView.reloadStory(storys[storyIndex])
		}
	}

	func removePartOfStory(_ contentView: UIScrollView, labelIndex: Int) {
		if let storyView = contentView.subviews[0] as? StoryView {
			storyView.labels[labelIndex].text = ""
			if labelIndex == 0 {
				storyView.labels[0].text = ""
				storyView.labels[0].backgroundColor = storyView.labels[1].backgroundColor
			} else {
				storyView.labels[4].text = ""
				storyView.labels[4].backgroundColor = storyView.labels[3].backgroundColor
			}
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


}


extension XYScrollView: UIScrollViewDelegate {

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView != self {
			if scrollView.contentOffset.y > TriggerDistance {
				if scrolledType != .down { scrolledType = .down }
			} else if scrollView.contentOffset.y < -TriggerDistance {
				if scrolledType != .up { scrolledType = .up }
			} else {
				if scrolledType != .notScrollYet { scrolledType = .notScrollYet }
			}
		} else {
			if scrollView.contentOffset.x < -TriggerDistance {
				if scrolledType != .left { scrolledType = .left }
			} else if scrollView.contentOffset.x > TriggerDistance {
				if scrolledType != .right { scrolledType = .right }
			} else {
				if scrolledType != .notScrollYet { scrolledType = .notScrollYet }
			}
		}
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		XYDelegate?.xyScrollViewWillScroll?(scrolledType, topViewIndex: topViewIndex)
		moveContentViewToTop(scrolledType)
		if !inMainVC { topViewIndex = topStoryIndex }
		XYDelegate?.xyScrollViewDidScroll(scrolledType, topViewIndex: topViewIndex)
	}

}


extension XYScrollView: StoryTableViewDelegate {

	func didSelectedStory(_ storyIndex: Int) {
		XYDelegate?.didSelectedStory!(storyIndex)
	}
}


extension XYScrollView: WriteViewDelegate {

	func selectingColor(_ selecting: Bool) {
		isScrollEnabled = !selecting
		contentViews[0].isScrollEnabled = !selecting
	}

	func willInputText(_ index: Int, oldText: String, colorCode: Int) {
		XYDelegate?.writeViewWillInputText!(index, oldText: oldText, colorCode: colorCode)
	}
}






