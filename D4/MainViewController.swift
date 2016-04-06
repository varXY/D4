//
//  ViewController.swift
//  D4
//
//  Created by 文川术 on 3/30/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit
import AVOSCloud


class MainViewController: UIViewController, LeanCloud {

	var xyScrollView: XYScrollView!
	var statusView: UIVisualEffectView!

	var statusBarHidden = false

	override func prefersStatusBarHidden() -> Bool {
		return statusBarHidden
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor.blackColor()
		automaticallyAdjustsScrollViewInsets = false

		xyScrollView = XYScrollView(VC: self)
		xyScrollView.XYDelegate = self
		view.addSubview(xyScrollView)
		xyScrollView.X1_storyTableView.scrollsToTop = true

		let blurEffect = UIBlurEffect(style: .Light)
		statusView = UIVisualEffectView(effect: blurEffect)
		statusView.frame = CGRectMake(0, 0, ScreenWidth, 20)
		view.addSubview(statusView)
		
		setupBars()

		delay(seconds: 2.0, completion: { self.reloadDailyStory() })

	}

 	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		hideStatusView(true)
	}


	func reloadDailyStory() {
		getDailyStory { (storys) in
			self.xyScrollView.storys = storys
		}
	}

	func loadSelfStory() {
		
	}

	func hideStatusView(hide: Bool) {
		statusBarHidden = hide
		if hide { setNeedsStatusBarAppearanceUpdate() }

		if (hide && statusView.frame.origin.y == 0) || (!hide && statusView.frame.origin.y == -20) {

			let distance: CGFloat = hide ? -20 : 20

			UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {

				self.statusView.frame.origin.y += distance

				}, completion: { (finished) in

					if !hide { self.setNeedsStatusBarAppearanceUpdate() }
					
			})

//			UIView.animateWithDuration(0.3, animations: {
//				self.statusView.frame.origin.y += distance
//			}) { (_) in
//				if !hide { self.setNeedsStatusBarAppearanceUpdate() }
//			}

		}


	}

	func setupBars() {
		let segmentedControl = UISegmentedControl(items: ["每日100", "我的故事"])
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 140, height: 29))
		segmentedControl.addTarget(self, action: #selector(segmentedControlSelected(_:)), forControlEvents: .ValueChanged)

		let barButton = UIBarButtonItem(customView: segmentedControl)

		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(goToAddPage))

		let infoButton = UIButton(type: .InfoDark)
		infoButton.addTarget(self, action: #selector(goToInfoPage), forControlEvents: .TouchUpInside)
		let infoBarButton = UIBarButtonItem(customView: infoButton)

		let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
		let toolBarItems = [addButton, space, barButton, space, infoBarButton]

		navigationController?.navigationBarHidden = true
		navigationController?.toolbarHidden = false
		navigationController?.toolbar.tintColor = UIColor.blackColor()
		setToolbarItems(toolBarItems, animated: true)
	}

	func segmentedControlSelected(segmentedControl: UISegmentedControl) {
		segmentedControl.selectedSegmentIndex == 0 ? reloadDailyStory() : loadSelfStory()
	}

	func goToAddPage() {
		xyScrollView.moveContentViewToTop(.Left)

		let hidden = xyScrollView.topViewIndex != 1
		navigationController?.setToolbarHidden(hidden, animated: true)
		hideStatusView(hidden)

		if xyScrollView.writeView.firstColor == false {
			xyScrollView.writeView.labelsGetRandomColors()
		}
	}

	func goToInfoPage() {
		xyScrollView.moveContentViewToTop(.Right)

		let hidden = xyScrollView.topViewIndex != 1
		navigationController?.setToolbarHidden(hidden, animated: true)
		hideStatusView(hidden)
	}

}

extension MainViewController: XYScrollViewDelegate {

	func didSelectedStory(storyIndex: Int, touchPoint: CGPoint) {

		let detailVC = DetailViewController()
		detailVC.storys = xyScrollView.storys
		detailVC.topStoryIndex = storyIndex
		detailVC.touchPoint = touchPoint
		detailVC.delegate = self
		presentViewController(detailVC, animated: true, completion: nil)
	}

	func writeViewWillInputText(index: Int, oldText: String?, colorCode: Int) {
		let inputVC = InputViewController()
		inputVC.index = index
		inputVC.oldText = oldText
		inputVC.colorCode = colorCode
		inputVC.delegate = self
		presentViewController(inputVC, animated: true, completion: nil)
	}

	func xyScrollViewWillScroll(scrollType: XYScrollType, topViewIndex: Int) {
		print(#function)
	}

	func xyScrollViewDidScroll(scrollType: XYScrollType, topViewIndex: Int) {
		let hidden = topViewIndex != 1
		navigationController?.setToolbarHidden(hidden, animated: true)
		hideStatusView(hidden)

		if scrollType == .Left {
			if xyScrollView.writeView.firstColor == false {
				xyScrollView.writeView.labelsGetRandomColors()
			}
		}

		if scrollType == .Up && topViewIndex == 0 {
			if xyScrollView.writeView.ready {
				let story = xyScrollView.writeView.newStory()!
				saveStory(story, completion: { (success, error) in
					self.xyScrollView.moveContentViewToTop(.Right)
					self.navigationController?.setToolbarHidden(false, animated: true)
					self.hideStatusView(false)
					self.reloadDailyStory()
				})
			}
		}
	}

	func setToolBarHiddenByStoryTableView(hidden: Bool) {
		navigationController?.setToolbarHidden(hidden, animated: true)
	}
}

extension MainViewController: DetailViewControllerDelegate {

	func detailViewControllerWillDismiss() {
		delay(seconds: 0.4) {
			self.hideStatusView(false)
		}
	}
}

extension MainViewController: InputTextViewDelegate {

	func inputTextViewDidReturn(index: Int, text: String) {
		navigationController?.toolbarHidden = true
		xyScrollView.writeView.changeLabelText(index, text: text)
	}
}


