//
//  ViewController.swift
//  D4
//
//  Created by 文川术 on 3/30/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, LeanCloud, CoreDataAndStory, UserDefaults {

	var xyScrollView: XYScrollView!
	var pointerView: PointerView!
	var statusView: UIVisualEffectView!
	var segmentedControl: UISegmentedControl!
	var addButton = UIBarButtonItem()

	var statusBarStyle = UIStatusBarStyle.Default
	var statusBarHidden = false

	var dailyStoryLoaded = false

	var forceTouchWay = false

	var dailyStorys: [Story]!

	var blurEffect: UIBlurEffect!

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return statusBarStyle
	}

	override func prefersStatusBarHidden() -> Bool {
		return statusBarHidden
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		automaticallyAdjustsScrollViewInsets = false
		modalPresentationStyle = .OverFullScreen
		pointerView = PointerView(VC: self)
		view = pointerView

		xyScrollView = XYScrollView(VC: self)
		xyScrollView.XYDelegate = self
		view.addSubview(xyScrollView)
		xyScrollView.X1_storyTableView.scrollsToTop = true

		dailyStorys = xyScrollView.X1_storyTableView.storys

		setupBars()

		if traitCollection.forceTouchCapability == .Available {
			registerForPreviewingWithDelegate(self, sourceView: xyScrollView.X1_storyTableView)
		}

	}

 	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		testLoadStory()
		hideOrShowStatusViewAndToolbar()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

	}

	func testLoadStory() {
		if !dailyStoryLoaded {
			xyScrollView.X1_storyTableView.loading(true)
			loadingStory(true)
			getDailyStory { (storys) in
				self.xyScrollView.X1_storyTableView.loading(false)
				self.loadingStory(false)

				if storys.count != 0 {
					self.dailyStorys = storys

					self.xyScrollView.storys = storys
					self.xyScrollView.X1_storyTableView.reloadData()

					self.dailyStoryLoaded = true
					self.updateLastLoadDate(NSDate())
					self.pointerView.lastUpDateTime = NSDate()

					self.save100DailyStorys(storys, completion: { (success) in
						self.removeAllLikedStoryIndexes()
						print("save 100 story to coreData:", success)
					})

				} else {
					print("Get zero story online")
				}
			}

		}
	}


	func reloadDailyStory() {

		let lastDate = lastLoadDate()
		dailyStoryLoaded = lastDate.string(.dd) == NSDate().string(.dd)
		print(lastDate.string(.dd))
		print(NSDate().string(.dd))

		if !dailyStoryLoaded {
			xyScrollView.X1_storyTableView.loading(true)
			loadingStory(true)
			getDailyStory { (storys) in
				self.xyScrollView.X1_storyTableView.loading(false)
				self.loadingStory(false)

				if storys.count != 0 {
					self.dailyStorys = storys

					self.xyScrollView.storys = storys
					self.xyScrollView.X1_storyTableView.reloadData()

					self.dailyStoryLoaded = true
					self.updateLastLoadDate(NSDate())

					self.save100DailyStorys(storys, completion: { (success) in
						self.removeAllLikedStoryIndexes()
						print("save 100 story to coreData:", success)
					})

				} else {
					print("Get zero story online")
				}
			}
			
		} else {
			dailyStorys = xyScrollView.X1_storyTableView.storys
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

	func loadSavedDailyStory() {
		xyScrollView.storys = dailyStorys
		xyScrollView.X1_storyTableView.reloadData()
	}

	func loadSelfStory() {
		getMyStorys { (storys) in
			self.xyScrollView.storys = storys
			self.xyScrollView.X1_storyTableView.reloadData()
		}
	}

	func setupBars() {
		let effect = UIBlurEffect(style: .Dark)
		statusView = UIVisualEffectView(effect: effect)
		statusView.frame = CGRectMake(0, 0, ScreenWidth, 20)

		view.addSubview(statusView)

		segmentedControl = UISegmentedControl(items: ["每日100", "我的故事"])
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 160, height: 29))
		segmentedControl.addTarget(self, action: #selector(segmentedControlSelected(_:)), forControlEvents: .ValueChanged)

		let barButton = UIBarButtonItem(customView: segmentedControl)

		addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(goToAddPage))

		let infoButton = UIButton(type: .InfoLight)
		infoButton.addTarget(self, action: #selector(goToInfoPage), forControlEvents: .TouchUpInside)
		let infoBarButton = UIBarButtonItem(customView: infoButton)

		let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
		let toolBarItems = [addButton, space, barButton, space, infoBarButton]

		navigationController?.navigationBarHidden = true
		navigationController?.toolbarHidden = false
		navigationController?.toolbar.clipsToBounds = true

		setToolbarItems(toolBarItems, animated: true)

		addShandowForBar()
		changeBarStyleBaseOnTime()
	}

	func addShandowForBar() {

		func addShandow(view: UIView) {
			view.layer.masksToBounds = false
			view.layer.shadowRadius = 5.0
			view.layer.shadowOpacity = 0.7
			view.layer.shadowColor = UIColor.blackColor().CGColor
			view.layer.shadowOffset = CGSizeMake(0, 0)
		}
		// 加阴影
//		addShandow(statusView)
//		addShandow((navigationController?.toolbar)!)

		// 加边框
		statusView.addBorder(borderColor: UIColor.whiteColor(), width: 0.2)
		navigationController?.toolbar.addBorder(borderColor: UIColor.whiteColor(), width: 0.2)

		// 变不透明
//		let image = UIImage.imageWithColor(MyColor.code(1).BTColors[0], rect: statusView.bounds)
//		let imageView = UIImageView(image: image)
//		statusView.addSubview(imageView)
//
//		let image_1 = UIImage.imageWithColor(MyColor.code(1).BTColors[0], rect: (navigationController?.toolbar.bounds)!)
//		navigationController?.toolbar.setBackgroundImage(image_1, forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)

	}

	func changeBarStyleBaseOnTime() {
		let hour = Int(NSDate().string(.HH))
		let night = (hour >= 18 && hour < 24) || (hour >= 0 && hour < 6)
		blurEffect = night ? UIBlurEffect(style: .Dark) : UIBlurEffect(style: .ExtraLight)
		let tintColor = night ? UIColor.whiteColor() : UIColor.blackColor()
		let barStyle = night ? UIBarStyle.Black : UIBarStyle.Default

		statusBarStyle = night ? UIStatusBarStyle.LightContent : UIStatusBarStyle.Default
		setNeedsStatusBarAppearanceUpdate()

		statusView.effect = blurEffect
		addButton.tintColor = tintColor

		navigationController?.toolbar.barStyle = barStyle
		navigationController?.toolbar.tintColor = tintColor
	}

	func segmentedControlSelected(segmentedControl: UISegmentedControl) {
		segmentedControl.selectedSegmentIndex == 0 ? loadSavedDailyStory() : loadSelfStory()
	}

	func goToAddPage() {
		xyScrollView.scrolledType = .NotScrollYet
		xyScrollView.moveContentViewToTop(.Left)
		pointerView.showTextBaseOnTopIndex(0)
		pointerView.addOrRemoveUpAndDownPointerAndLabel(0)
		pointerView.changeLabelTextForCanSaveStory(xyScrollView.writeView.ready)
		hideOrShowStatusViewAndToolbar()

		if xyScrollView.writeView.firstColor == false {
			xyScrollView.writeView.labelsGetRandomColors()
		}
	}

	func goToInfoPage() {
		xyScrollView.scrolledType = .NotScrollYet
		xyScrollView.moveContentViewToTop(.Right)
		pointerView.showTextBaseOnTopIndex(2)
		pointerView.addOrRemoveUpAndDownPointerAndLabel(2)
		hideOrShowStatusViewAndToolbar()
	}

	func hideOrShowStatusViewAndToolbar() {
		let hidden = xyScrollView.topViewIndex != 1
		navigationController?.setToolbarHidden(hidden, animated: true)
		hideStatusView(hidden)
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

}

extension MainViewController: XYScrollViewDelegate {

	func scrollTypeDidChange(type: XYScrollType) {
		pointerView.changePointerDirection(type)
	}

	func didSelectedStory(storyIndex: Int) {

		let detailVC = DetailViewController()
		detailVC.modalPresentationStyle = .Custom
		detailVC.transitioningDelegate = detailVC
		detailVC.storys = xyScrollView.X1_storyTableView.storys
		detailVC.topStoryIndex = storyIndex
		detailVC.blurEffect = blurEffect
		detailVC.delegate = self
		presentViewController(detailVC, animated: true) { 
			self.navigationController?.setToolbarHidden(true, animated: true)
			self.hideStatusView(true)
			self.forceTouchWay = false
		}

		UIView.animateWithDuration(0.3, animations: { 
			self.view.alpha = 0.3
			self.view.transform = CGAffineTransformMakeScale(0.95, 0.95)
			}) { (_) in
				delay(seconds: 0.5, completion: {
					self.view.alpha = 1.0
					self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
				})
		}
	}

	func writeViewWillInputText(index: Int, oldText: String, colorCode: Int) {
		let inputVC = InputViewController()
		inputVC.modalPresentationStyle = .Custom
		inputVC.transitioningDelegate = inputVC
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
		pointerView.showTextBaseOnTopIndex(topViewIndex)
		
		pointerView.addOrRemoveUpAndDownPointerAndLabel(topViewIndex)
		if topViewIndex == 0 { pointerView.changeLabelTextForCanSaveStory(xyScrollView.writeView.ready) }

		if scrollType == .Left && xyScrollView.topViewIndex != 1 {
			if xyScrollView.writeView.firstColor == false {
				xyScrollView.writeView.labelsGetRandomColors()
			}
		}

		if scrollType == .Down && topViewIndex == 0 {
			delay(seconds: 0.7, completion: {
				self.goBackSaveUploadStory()
			})
		}
	}

	func goBackSaveUploadStory() {
		if xyScrollView.writeView.ready {
			let story = xyScrollView.writeView.newStory()
			if story != nil {

				xyScrollView.moveContentViewToTop(.Right)
				pointerView.showTextBaseOnTopIndex(1)
				pointerView.addOrRemoveUpAndDownPointerAndLabel(1)
				hideOrShowStatusViewAndToolbar()

				segmentedControl.selectedSegmentIndex = 1
				loadSelfStory()

				delay(seconds: 1.0, completion: {
					self.xyScrollView.X1_storyTableView.insertNewStory(story!)
				})

				delay(seconds: 1.5, completion: {
					self.saveMyStory(story!, completion: { (success) in
						self.uploadStory(story!, completion: { (success, error) in
							if success == true {
								self.saveLastStory(story!)
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

	func setToolBarHiddenByStoryTableView(hidden: Bool) {
//		navigationController?.setToolbarHidden(hidden, animated: true)
	}
}

extension MainViewController: DetailViewControllerDelegate {

	func ratingChanged(index: Int, rating: Int) {
		xyScrollView.X1_storyTableView.storys[index].rating = rating
	}

	func detailViewControllerWillDismiss(topStoryIndex: Int) {
		view.transform = CGAffineTransformMakeScale(0.95, 0.95)
		UIView.animateWithDuration(0.3, animations: {
			self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
			}) { (_) in
				self.hideOrShowStatusViewAndToolbar()
		}

		if !forceTouchWay {
			let indexPath = NSIndexPath(forRow: topStoryIndex, inSection: 0)
			xyScrollView.X1_storyTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
		}
	}
}

extension MainViewController: InputTextViewDelegate {

	func inputTextViewDidReturn(index: Int, text: String) {
		navigationController?.toolbarHidden = true
		xyScrollView.writeView.changeLabelText(index, text: text)
		pointerView.changeLabelTextForCanSaveStory(xyScrollView.writeView.ready)
	}
}

extension MainViewController: UIViewControllerPreviewingDelegate {

	func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = xyScrollView.X1_storyTableView.indexPathForRowAtPoint(location), cell = xyScrollView.X1_storyTableView.cellForRowAtIndexPath(indexPath) else { return nil }

		let detailVC = DetailViewController()
		detailVC.storys = xyScrollView.X1_storyTableView.storys
		detailVC.topStoryIndex = indexPath.row
		detailVC.delegate = self
		detailVC.preferredContentSize = CGSize(width: 0.0, height: 0.0)
		previewingContext.sourceRect = cell.frame
		forceTouchWay = true
		return detailVC
	}

	func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
		viewControllerToCommit.modalPresentationStyle = .Custom
		presentViewController(viewControllerToCommit, animated: false, completion: nil)
		forceTouchWay = false
		hideStatusView(true)
		navigationController?.setToolbarHidden(true, animated: true)
	}
}


