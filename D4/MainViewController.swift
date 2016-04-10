//
//  ViewController.swift
//  D4
//
//  Created by 文川术 on 3/30/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, LeanCloud, CoreDataAndStory {

	var xyScrollView: XYScrollView!
	var statusView: UIVisualEffectView!
	var segmentedControl: UISegmentedControl!

	var statusBarStyle = UIStatusBarStyle.Default
	var statusBarHidden = false

	var dailyStoryLoaded = false

	var dailyStorys: [Story]!

	var inputVC: InputViewController!

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return statusBarStyle
	}

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

		setupBars()
		reloadDailyStory()

	}

 	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		inputVC = InputViewController()

	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		hideStatusView(true)
	}


	func reloadDailyStory() {
		if !dailyStoryLoaded {
			xyScrollView.X1_storyTableView.loading(true)
			loadingStory(true)
			getDailyStory { (storys) in
				if storys.count != 0 {
					self.dailyStorys = storys
					self.loadingStory(false)
					self.xyScrollView.X1_storyTableView.loading(false)
					self.xyScrollView.storys = storys
					self.xyScrollView.X1_storyTableView.reloadData()
					self.dailyStoryLoaded = true

					self.save100DailyStorys(storys, completion: { (success) in
						print("save 100 story to coreData:", success)
					})

				} else {
					self.loadingStory(false)
					print("Get zero story online")
				}
			}
			
		} else {
			xyScrollView.storys = dailyStorys
			xyScrollView.X1_storyTableView.reloadData()
		}

	}

	func loadingStory(loading: Bool) {

		if loading {
			var images = [UIImage]()
			for i in 0..<colorCode.count {
				let image = UIImage.imageWithColor(MyColor.code(colorCode[i]).BTColors[0], rect: CGRectMake(0, 0, ScreenWidth, 50))
				images.append(image)
			}

			let loadingImage = UIImage.animatedImageWithImages(images, duration: 1.5)
			let imageView = UIImageView(image: loadingImage)
			imageView.frame.origin = CGPoint(x: 0, y: 20)
			imageView.tag = 30

			view.addSubview(imageView)
			view.sendSubviewToBack(imageView)
		} else {
			if let imageView = view.viewWithTag(30) as? UIImageView {
				imageView.stopAnimating()

				UIView.animateWithDuration(0.6, animations: {
					imageView.alpha = 0.0
					}, completion: { (_) in
						imageView.removeFromSuperview()
				})
			}

		}
	}

	func loadSelfStory() {
		getMyStorys { (storys) in
			self.xyScrollView.storys = storys
			self.xyScrollView.X1_storyTableView.reloadData()
		}
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

		}


	}

	func changeBarStyleBaseOnTime() {
		let hour = Int(dateFormatter_HH.stringFromDate(NSDate()))
		let night = (hour >= 18 && hour < 24) || (hour >= 0 && hour < 6)
		let blurEffect = night ? UIBlurEffect(style: .Dark) : UIBlurEffect(style: .ExtraLight)
		let tintColor = night ? UIColor.whiteColor() : UIColor.blackColor()
		let barStyle = night ? UIBarStyle.Black : UIBarStyle.Default

		statusBarStyle = night ? UIStatusBarStyle.LightContent : UIStatusBarStyle.Default
		setNeedsStatusBarAppearanceUpdate()

		statusView.effect = blurEffect

		navigationController?.toolbar.barStyle = barStyle
		navigationController?.toolbar.tintColor = tintColor
	}

	func setupBars() {
		let effect = UIBlurEffect(style: .Dark)
		statusView = UIVisualEffectView(effect: effect)
		statusView.frame = CGRectMake(0, 0, ScreenWidth, 20)

		statusView.layer.masksToBounds = false
		statusView.layer.shadowRadius = 0
		statusView.layer.shadowOpacity = 1.0
		statusView.layer.shadowColor = UIColor.grayColor().CGColor
		statusView.layer.shadowOffset = CGSizeMake(0, 0.3)

		view.addSubview(statusView)

		segmentedControl = UISegmentedControl(items: ["每日100", "我的故事"])
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 160, height: 29))
		segmentedControl.addTarget(self, action: #selector(segmentedControlSelected(_:)), forControlEvents: .ValueChanged)

		let barButton = UIBarButtonItem(customView: segmentedControl)

		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(goToAddPage))

		let infoButton = UIButton(type: .InfoLight)
		infoButton.addTarget(self, action: #selector(goToInfoPage), forControlEvents: .TouchUpInside)
		let infoBarButton = UIBarButtonItem(customView: infoButton)

		let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
		let toolBarItems = [addButton, space, barButton, space, infoBarButton]

		navigationController?.navigationBarHidden = true
		navigationController?.toolbarHidden = false
//		navigationController?.toolbar.clipsToBounds = true

		setToolbarItems(toolBarItems, animated: true)

		changeBarStyleBaseOnTime()
	}

	func segmentedControlSelected(segmentedControl: UISegmentedControl) {
		segmentedControl.selectedSegmentIndex == 0 ? reloadDailyStory() : loadSelfStory()
	}

	func goToAddPage() {
		xyScrollView.moveContentViewToTop(.Left)
		hideOrShowStatusViewAndToolbar()

		if xyScrollView.writeView.firstColor == false {
			xyScrollView.writeView.labelsGetRandomColors()
		}
	}

	func goToInfoPage() {
		xyScrollView.moveContentViewToTop(.Right)
		hideOrShowStatusViewAndToolbar()
	}

	func hideOrShowStatusViewAndToolbar() {
		let hidden = xyScrollView.topViewIndex != 1
		navigationController?.setToolbarHidden(hidden, animated: true)
		hideStatusView(hidden)
	}

}

extension MainViewController: XYScrollViewDelegate {

	func didSelectedStory(storyIndex: Int, touchPoint: CGPoint) {

		let detailVC = DetailViewController()
		detailVC.storys = xyScrollView.X1_storyTableView.storys
		detailVC.topStoryIndex = storyIndex
		detailVC.touchPoint = touchPoint
		detailVC.delegate = self
		presentViewController(detailVC, animated: true, completion: nil)
	}

	func writeViewWillInputText(index: Int, oldText: String, colorCode: Int) {
		inputVC.index = index
		inputVC.oldText = oldText
		inputVC.colorCode = colorCode
		inputVC.delegate = self
		presentViewController(inputVC, animated: true, completion: nil)
	}

	func xyScrollViewWillScroll(scrollType: XYScrollType, topViewIndex: Int) {

	}

	func xyScrollViewDidScroll(scrollType: XYScrollType, topViewIndex: Int) {
		hideOrShowStatusViewAndToolbar()

		if scrollType == .Left && xyScrollView.topViewIndex != 1 {
			if xyScrollView.writeView.firstColor == false {
				xyScrollView.writeView.labelsGetRandomColors()
			}
		}

		if scrollType == .Down && topViewIndex == 0 {
			if xyScrollView.writeView.ready {
				let story = xyScrollView.writeView.newStory()
				if story != nil {

						self.xyScrollView.moveContentViewToTop(.Right)
						self.hideOrShowStatusViewAndToolbar()

						self.segmentedControl.selectedSegmentIndex = 1
						self.loadSelfStory()

						delay(seconds: 1.5, completion: {
							self.xyScrollView.X1_storyTableView.insertNewStory(story!)

						})

						delay(seconds: 2.0, completion: { 
							self.saveMyStory(story!, completion: { (success) in
								self.uploadStory(story!, completion: { (success, error) in
									if success == true {
										print(success)
										self.xyScrollView.writeView.clearContent()
									}
								})
								print(success, " to save my story")
							})
						})

				}



			}
		}
	}

	func setToolBarHiddenByStoryTableView(hidden: Bool) {
//		navigationController?.setToolbarHidden(hidden, animated: true)
	}
}

extension MainViewController: DetailViewControllerDelegate {


	func detailViewControllerWillDismiss(topStoryIndex: Int) {
		let indexPath = NSIndexPath(forRow: topStoryIndex, inSection: 0)
		xyScrollView.X1_storyTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
		self.hideStatusView(false)
	}
}

extension MainViewController: InputTextViewDelegate {

	func inputTextViewDidReturn(index: Int, text: String) {
		navigationController?.toolbarHidden = true
		xyScrollView.writeView.changeLabelText(index, text: text)
	}
}


