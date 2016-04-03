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
	var statusView: UIView!

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

		statusView = UIView(frame: CGRectMake(0, 0, ScreenWidth, 20))
		statusView.backgroundColor = UIColor.whiteColor()
		view.addSubview(statusView)
	}

 	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		setupBars()

		delay(seconds: 3.0, completion: { self.reloadDailyStory() })
	}

	func reloadDailyStory() {
		getDailyStory { (storys) in
			self.xyScrollView.storys = storys
		}
	}

	func loadSelfStory() {
		
	}

	func setupBars() {
		let segmentedControl = UISegmentedControl(items: ["每日100", "我的故事"])
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 140, height: 29))
		segmentedControl.addTarget(self, action: #selector(segmentedControlSelected(_:)), forControlEvents: .ValueChanged)

		let barButton = UIBarButtonItem(customView: segmentedControl)
		let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
		let toolBarItems = [space, barButton, space]

		navigationController?.navigationBarHidden = true
		navigationController?.toolbarHidden = false
		navigationController?.toolbar.tintColor = UIColor.blackColor()
		setToolbarItems(toolBarItems, animated: true)
	}

	func segmentedControlSelected(segmentedControl: UISegmentedControl) {
		segmentedControl.selectedSegmentIndex == 0 ? reloadDailyStory() : loadSelfStory()
	}

}

extension MainViewController: XYScrollViewDelegate {

	func xyScrollViewDidScroll(scrollType: XYScrollType, topViewIndex: Int) {
		print(scrollType)
		let hidden = topViewIndex != 1
		navigationController?.setToolbarHidden(hidden, animated: true)
		statusBarHidden = hidden
		setNeedsStatusBarAppearanceUpdate()
		statusView.alpha = hidden ? 0.0 : 1.0
	}

	func setToolBarHiddenByStoryTableView(hidden: Bool) {
		navigationController?.setToolbarHidden(hidden, animated: true)
	}
}


