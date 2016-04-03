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

	var storyTableView: StoryTableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor.blackColor()

		let scrollView = BackgroundScrollView()
		scrollView.movementDelegate = self
		view.addSubview(scrollView)
		
		storyTableView = StoryTableView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight), storys: [Story]())
		storyTableView.customDelegate = self
		scrollView.addSubview(storyTableView)

	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		view.layer.cornerRadius = 10
		navigationController?.navigationBarHidden = true
		navigationController?.toolbarHidden = false
		setupToolbar()

		delay(seconds: 3.0, completion: { self.reloadDailyStory() })
	}

	func reloadDailyStory() {
		getDailyStory { (storys) in
			self.storyTableView.storys = storys
		}
	}

	func loadSelfStory() {
		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
		storyTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
	}

	func setupToolbar() {
		let segmentedControl = UISegmentedControl(items: ["每日100", "我的故事"])
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 140, height: 29))
		segmentedControl.addTarget(self, action: #selector(segmentedControlSelected(_:)), forControlEvents: .ValueChanged)

		let barButton = UIBarButtonItem(customView: segmentedControl)
		let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
		let toolBarItems = [space, barButton, space]

		navigationController?.toolbar.tintColor = UIColor.blackColor()
		setToolbarItems(toolBarItems, animated: true)
	}

	func segmentedControlSelected(segmentedControl: UISegmentedControl) {
		segmentedControl.selectedSegmentIndex == 0 ? reloadDailyStory() : loadSelfStory()
	}

}

extension MainViewController: BackgroundScrollViewDelegate {

	func didScrollLeftOrRight(scrollType: ScrollType) {
		print(scrollType)
	}
}

extension MainViewController: StoryTableViewDelegate {

	func storyTableViewDidScroll(scrollType: StoryTableViewScrollType) {
		let hide = scrollType == .Down
		navigationController?.setToolbarHidden(hide, animated: true)
	}
}

