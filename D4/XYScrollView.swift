//
//  XYScrollView.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

enum XYScrollType {
	case Up, Down, Left, Right
}

protocol XYScrollViewDelegate: class {
	func setToolBarHiddenByStoryTableView(hidden: Bool)
	func xyScrollViewDidScroll(scrollType: XYScrollType, topViewIndex: Int)
}

class XYScrollView: UIScrollView {

	var X0_contentView: UIScrollView!
	var X1_storyTableView: StoryTableView!
	var X2_contentView: UIScrollView!

	var writeView: WriteView!
	var settingView: SettingView!

	var Y0_contentView: UIScrollView!
	var Y1_contentView: UIScrollView!
	var Y2_contentView: UIScrollView!

	var storys: [Story]! {
		didSet {
			if X1_storyTableView != nil {
				X1_storyTableView.storys = storys
			}
		}
	}

	var inMainVC = false
	var topViewIndex = 1

	var triggeredLeft = false
	var triggeredRight = false
	var triggeredUp = false
	var triggeredDown = false

	weak var XYDelegate: XYScrollViewDelegate?

	init(VC: UIViewController) {
		super.init(frame: VC.view.bounds)
		backgroundColor = UIColor.clearColor()
		contentSize = CGSize(width: frame.width, height: 0)
		alwaysBounceHorizontal = true
		directionalLockEnabled = true
		delegate = self

		switch VC {
		case is MainViewController:
			inMainVC = true

			X0_contentView = UIScrollView(frame: bounds)
			X0_contentView.frame.origin.x = -ScreenWidth
			X0_contentView.contentSize = CGSize(width: 0, height: frame.height)
			X0_contentView.alwaysBounceVertical = true
			X0_contentView.directionalLockEnabled = true
			X0_contentView.delegate = self
			writeView = WriteView()
			writeView.delegate = self
			X0_contentView.addSubview(writeView)
			X0_contentView.alpha = 0.0

			X1_storyTableView = StoryTableView(frame: bounds, storys: [Story]())
			X1_storyTableView.SDelegate = self

			X2_contentView = UIScrollView(frame: bounds)
			X2_contentView.frame.origin.x = ScreenWidth
			X2_contentView.contentSize = CGSize(width: 0, height: frame.height)
			X2_contentView.alwaysBounceVertical = true
			X2_contentView.directionalLockEnabled = true
			X2_contentView.delegate = self
			settingView = SettingView()
			X2_contentView.addSubview(settingView)
			X2_contentView.alpha = 0.0

			addSubview(X1_storyTableView)
			addSubview(X0_contentView)
			addSubview(X2_contentView)

		default:
			break

		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesEnded(touches, withEvent: event)
		
		guard let touch = touches.first else { return }
		print(#function)
		print(touch.locationInView(self))
	}


	func moveContentViewToTop(scrollType: XYScrollType) {
		if inMainVC {
			if topViewIndex == 1 {
				switch scrollType {
				case .Left:
					topViewIndex = 0
					UIView.animateWithDuration(0.3, animations: { 
						self.X1_storyTableView.alpha = 0.0
						self.X0_contentView.alpha = 1.0
						self.X0_contentView.frame.origin.x += ScreenWidth
					})
				case .Right:
					topViewIndex = 2
					UIView.animateWithDuration(0.3, animations: {
						self.X1_storyTableView.alpha = 0.0
						self.X2_contentView.alpha = 1.0
						self.X2_contentView.frame.origin.x -= ScreenWidth
					})
					
				default: break
				}
			}

			if topViewIndex == 0 {
				switch scrollType {
				case .Right:
					topViewIndex = 1
					UIView.animateWithDuration(0.3, animations: {
						self.X1_storyTableView.alpha = 1.0
						self.X0_contentView.alpha = 0.0
						self.X0_contentView.frame.origin.x -= ScreenWidth
					})
				default: break
				}
			}

			if topViewIndex == 2 {
				switch scrollType {
				case .Left:
					topViewIndex = 1
					UIView.animateWithDuration(0.3, animations: {
						self.X1_storyTableView.alpha = 1.0
						self.X2_contentView.alpha = 0.0
						self.X2_contentView.frame.origin.x += ScreenWidth
					})
				default: break
				}
			}

		}
	}


}


extension XYScrollView: UIScrollViewDelegate {

	func scrollViewDidScroll(scrollView: UIScrollView) {

		if self.contentOffset.x < -TriggerDistance {
			triggeredLeft = true
			triggeredRight = false
		} else if self.contentOffset.x > TriggerDistance {
			triggeredLeft = false
			triggeredRight = true
		} else {
			triggeredLeft = false
			triggeredRight = false
		}

		if scrollView.contentOffset.y > TriggerDistance {
			triggeredUp = true
			triggeredDown = false
		} else if scrollView.contentOffset.y < -TriggerDistance {
			triggeredUp = false
			triggeredDown = true
		} else {
			triggeredUp = false
			triggeredDown = false
		}
	}

	func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

	}

	func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if triggeredLeft {
			moveContentViewToTop(.Left)
			XYDelegate?.xyScrollViewDidScroll(.Left, topViewIndex: topViewIndex)
		}
		if triggeredRight {
			moveContentViewToTop(.Right)
			XYDelegate?.xyScrollViewDidScroll(.Right, topViewIndex: topViewIndex)
		}
		if triggeredUp { XYDelegate?.xyScrollViewDidScroll(.Up, topViewIndex: topViewIndex) }
		if triggeredDown { XYDelegate?.xyScrollViewDidScroll(.Down, topViewIndex: topViewIndex) }
	}
}

extension XYScrollView: StoryTableViewDelegate {

	func showOrHideToolbar(show: Bool) {
		XYDelegate?.setToolBarHiddenByStoryTableView(show)
	}
}

extension XYScrollView: WriteViewDelegate {

	func selectingColor(selecting: Bool) {
		scrollEnabled = !selecting
		X0_contentView.scrollEnabled = !selecting
	}

}






