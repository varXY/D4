//
//  ViewController.swift
//  D4
//
//  Created by 文川术 on 3/30/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, LeanCloud, CoreDataAndStory, UserDefaults, MailSending, Purchase {

	var xyScrollView: XYScrollView!
	var pointerView: PointerView!
	var statusView: UIVisualEffectView!
	var segmentedControl: UISegmentedControl!
	var addButton = UIBarButtonItem()

	var statusBarStyle = UIStatusBarStyle.Default
	var statusBarHidden = false
	var dailyStoryLoaded = false
	var forceTouchWay = false
	var nightStyle = false
	var oldTopIndex = 0
	var topViewIndex = 1

	var dailyStorys: [Story]!

	var backgroundSound = BackgroundSound()
	var internetReachability: Reachability!

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return statusBarStyle
	}

	override func prefersStatusBarHidden() -> Bool {
		return statusBarHidden
	}

	// MARK: - LoadAndAppear

	override func viewDidLoad() {
		super.viewDidLoad()
		automaticallyAdjustsScrollViewInsets = false

		pointerView = PointerView(VC: self)
		view = pointerView

		xyScrollView = XYScrollView(VC: self, storys: nil, topStoryIndex: nil)
		xyScrollView.XYDelegate = self
		view.addSubview(xyScrollView)

		xyScrollView.writeView.backgroundSound = backgroundSound
		xyScrollView.writeView.addtipLabels(true, removeIndex: nil)

		xyScrollView.storyTableView.scrollsToTop = true

		xyScrollView.settingView.delegate = self
		xyScrollView.settingView.askedForAllowNotification = getAskedAllowNotification()
		xyScrollView.settingView.savedNotificationIndex = getNotificationIndex()

		dailyStorys = xyScrollView.storyTableView.storys
		setupBars()

		if traitCollection.forceTouchCapability == .Available {
			registerForPreviewingWithDelegate(self, sourceView: xyScrollView.storyTableView)
		}

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
		internetReachability = Reachability.reachabilityForInternetConnection()
		internetReachability.startNotifier()
	}

 	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		reloadDailyStory()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	func reachabilityChanged(note: NSNotification) {
		if internetReachability.currentReachabilityStatus().rawValue != 0 {
			reloadDailyStory()
		}
	}

	// MARK: Load story & UI

	func reloadDailyStory() {
		dailyStoryLoaded = lastLoadDate().string(.dd) == NSDate().string(.dd)

		if !dailyStoryLoaded {

			if self.presentedViewController != nil {
				self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
			}

			if self.segmentedControl.selectedSegmentIndex != 0 {
				self.segmentedControl.selectedSegmentIndex = 0
				self.segmentedControlSelected(self.segmentedControl)
			}

			xyScrollView.storyTableView.loading(true)
			loadingStory(true)

			scrollToRow(0)
			pointerView.lastUpdateText = ""

			getDailyStory { (storys) in
				self.xyScrollView.storyTableView.loading(false)
				self.loadingStory(false)

				if storys.count != 0 {
					self.dailyStorys = storys
					self.xyScrollView.storys = storys
					self.xyScrollView.storyTableView.reloadData()

					self.dailyStoryLoaded = true
					self.updateLastLoadDate(NSDate())
					self.pointerView.lastUpDateTime = NSDate()

					self.save100DailyStorys(storys, completion: { (success) in
						if success {
							self.removeAllLikedStoryIndexes()
							self.backgroundSound.playSound(true, sound: self.backgroundSound.done_sound)
						}
					})

				} else {
					self.pointerView.lastUpdateText = "无法更新"
					print("Get zero story online")
				}

			}

		} else {
			if xyScrollView.topViewIndex == 1 {
				pointerView.lastUpdateText = ""
			}
		}
	}

	func loadingStory(loading: Bool) {
		if loading {
			if let oldView = view.viewWithTag(301) as? UIImageView {
				oldView.removeFromSuperview()
			}

			let images = colorCode.map({ UIImage.imageWithColor(MyColor.code($0).BTColors[0], rect: CGRectMake(0, 0, ScreenWidth, 50)) })
			let loadingImage = UIImage.animatedImageWithImages(images, duration: 1.5)
			let imageView = UIImageView(image: loadingImage)
			imageView.frame.origin = CGPoint(x: 0, y: 20)
			imageView.tag = 301

			view.addSubview(imageView)
			view.sendSubviewToBack(imageView)
		} else {
			if let imageView = view.viewWithTag(301) as? UIImageView {
				imageView.stopAnimating()
				imageView.removeFromSuperview()
			}
		}
	}

	func loadSavedDailyStory() {
		xyScrollView.storys = dailyStorys
		xyScrollView.storyTableView.netOrLocalStory = 0
		xyScrollView.storyTableView.reloadData()
	}

	func loadSelfStory() {
		getMyStorys { (storys) in
			self.xyScrollView.storys = storys
			self.xyScrollView.storyTableView.netOrLocalStory = 1
			self.xyScrollView.storyTableView.reloadData()
		}
	}

	func setupBars() {
		let effect = UIBlurEffect(style: .Dark)
		statusView = UIVisualEffectView(effect: effect)
		statusView.frame = CGRectMake(0, 0, ScreenWidth, 20)
		view.addSubview(statusView)

		segmentedControl = UISegmentedControl(items: ["今日100", "我的故事"])
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.frame.size = CGSize(width: 160, height: 29)
		segmentedControl.addTarget(self, action: #selector(segmentedControlSelected(_:)), forControlEvents: .ValueChanged)
		let barButton = UIBarButtonItem(customView: segmentedControl)

		addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(gotoPage(_:)))

		let infoButton = UIButton(type: .InfoLight)
		infoButton.addTarget(self, action: #selector(gotoPage(_:)), forControlEvents: .TouchUpInside)
		infoButton.exclusiveTouch = true
		let infoBarButton = UIBarButtonItem(customView: infoButton)

		let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
		let toolBarItems = [addButton, space, barButton, space, infoBarButton]

		navigationController?.navigationBarHidden = true
		navigationController?.toolbarHidden = false
		navigationController?.toolbar.clipsToBounds = true
		setToolbarItems(toolBarItems, animated: true)

		changeBarStyleBaseOnTime()
	}

	func changeBarStyleBaseOnTime() {
//		let hour = Int(NSDate().string(.HH))
//		nightStyle = (hour >= 18 && hour < 24) || (hour >= 0 && hour < 6)
		if nightStyle != false { return }
		nightStyle = true
		pointerView.nightStyle = nightStyle
		xyScrollView.writeView.nightStyle = nightStyle
		xyScrollView.settingView.nightStyle = nightStyle
		
		let blurEffect = nightStyle ? UIBlurEffect(style: .Dark) : UIBlurEffect(style: .ExtraLight)
		let tintColor = nightStyle ? UIColor.whiteColor() : UIColor.blackColor()
		let barStyle = nightStyle ? UIBarStyle.Black : UIBarStyle.Default

		statusBarStyle = nightStyle ? UIStatusBarStyle.LightContent : UIStatusBarStyle.Default
		setNeedsStatusBarAppearanceUpdate()

		statusView.effect = blurEffect
		addButton.tintColor = tintColor
		navigationController?.toolbar.barStyle = barStyle
		navigationController?.toolbar.tintColor = tintColor
	}

	func segmentedControlSelected(segmentedControl: UISegmentedControl) {
		backgroundSound.playSound(true, sound: backgroundSound.selected_sound)
		pointerView.changeTopLabelTextWhenSegmentedControlSelected(segmentedControl.selectedSegmentIndex)
		segmentedControl.selectedSegmentIndex == 0 ? loadSavedDailyStory() : loadSelfStory()
	}

	func gotoPage(sender: AnyObject) {
		var pageIndex = 0
		if let _ = sender as? UIButton { pageIndex = 2 }

		backgroundSound.playSound(true, sound: backgroundSound.selected_sound)
		xyScrollView.scrolledType = .NotScrollYet

		if topViewIndex == 2 {
			oldTopIndex = 2
			xyScrollView.moveContentViewToTop(pageIndex == 0 ? .Left : .Right)
			xyScrollViewDidScroll(.Left, topViewIndex: 1)

			delay(seconds: 1.0, completion: { 
				self.oldTopIndex = 1
				self.xyScrollView.moveContentViewToTop(pageIndex == 0 ? .Left : .Right)
				self.xyScrollViewDidScroll((pageIndex == 0 ? .Left : .Right), topViewIndex: pageIndex)
			})
		} else {
			oldTopIndex = 1
			xyScrollView.moveContentViewToTop(pageIndex == 0 ? .Left : .Right)
			xyScrollViewDidScroll((pageIndex == 0 ? .Left : .Right), topViewIndex: pageIndex)
		}
	}

	func hideOrShowStatusViewAndToolbar(presentedVC: Bool?) {
		if presentedVC != nil {
			navigationController?.setToolbarHidden(presentedVC!, animated: true)
			hideStatusView(presentedVC!)
		} else {
			let hidden = xyScrollView.topViewIndex != 1
			navigationController?.setToolbarHidden(hidden, animated: true)
			hideStatusView(hidden)
		}
	}

	func hideStatusView(hide: Bool) {
		statusBarHidden = hide
		if hide { setNeedsStatusBarAppearanceUpdate() }

		if (hide && statusView.frame.origin.y == 0) || (!hide && statusView.frame.origin.y == -20) {
			let distance: CGFloat = hide ? -20 : 20

			UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: { 
				self.statusView.frame.origin.y += distance
				}, completion: { (_) in
					if !hide { self.statusBarHidden = hide; self.setNeedsStatusBarAppearanceUpdate() }
			})

		}
	}

	func setUpDetailVC(detailVC: DetailViewController) {
		detailVC.modalPresentationStyle = .Custom
		detailVC.transitioningDelegate = detailVC
		detailVC.storys = xyScrollView.storyTableView.storys
		detailVC.nightStyle = nightStyle
		detailVC.netOrLocalStory = xyScrollView.storyTableView.netOrLocalStory
		detailVC.delegate = self
	}

}


// MARK: - XYScrollViewDelegate

extension MainViewController: XYScrollViewDelegate {

	func scrollTypeDidChange(type: XYScrollType) {
		pointerView.showPointer(type)
	}

	func didSelectedStory(storyIndex: Int) {
		forceTouchWay = false
		hideOrShowStatusViewAndToolbar(true)

		let detailVC = DetailViewController()
		detailVC.topStoryIndex = storyIndex
		setUpDetailVC(detailVC)
		presentViewController(detailVC, animated: true, completion: nil)

		UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: {
			self.view.alpha = 0.0
			}, completion: nil)
	}

	func xyScrollViewWillScroll(scrollType: XYScrollType, topViewIndex: Int) {
		pointerView.hidePointersAndLabels()
		oldTopIndex = topViewIndex
	}

	func xyScrollViewDidScroll(scrollType: XYScrollType, topViewIndex: Int) {
		self.topViewIndex = topViewIndex
		hideOrShowStatusViewAndToolbar(nil)

		if oldTopIndex == topViewIndex {
			switch topViewIndex {
			case 0:
				switch scrollType {
				case .Up:
					pointerView.changeTextForUpInWriteView()

				case .Down:
					pointerView.changeLabelTextForCanSaveStory(self.xyScrollView.writeView.doneWriting, ready: self.xyScrollView.writeView.ready)

					delay(seconds: 0.7) { self.goBackSaveUploadStory() }

				case .Left:
					xyScrollView.writeView.labelsGetRandomColors()

				case .Right:
					break

				default:
					break
				}

			case 2:
				switch scrollType {
				case .Up:
					sendSupportEmail()

				case .Left:
					break

				case .Right:
					UIApplication.sharedApplication().openURL(jianShuURL!)

				case .Down:
					connectToStore()

				default:
					break
				}
				
			default:
				break
			}

		} else {
			pointerView.showTextBaseOnTopIndex(topViewIndex)
			pointerView.addOrRemoveUpAndDownPointerAndLabel(topViewIndex)

			if topViewIndex == 0 && oldTopIndex == 1 {
				xyScrollView.writeView.addDots(true)
				xyScrollView.writeView.checkText()
				pointerView.changeLabelTextForCanSaveStory(xyScrollView.writeView.doneWriting, ready: xyScrollView.writeView.ready)
			}

			if topViewIndex == 1 && oldTopIndex == 0 {
				xyScrollView.writeView.addDots(false)
				if pointerView.lastUpdateText == nil { reloadDailyStory() }
			}

			if topViewIndex == 2 && oldTopIndex == 1 {
				xyScrollView.settingView.randomColorForPrimaticButtons()
			}
		}

	}

	func goBackSaveUploadStory() {
		if xyScrollView.writeView.ready {
			let story = xyScrollView.writeView.newStory()

			if story != nil {
				xyScrollView.moveContentViewToTop(.Right)
				pointerView.showTextBaseOnTopIndex(1)
				pointerView.addOrRemoveUpAndDownPointerAndLabel(1)
				pointerView.changeTopLabelTextWhenSegmentedControlSelected(1)
				hideOrShowStatusViewAndToolbar(nil)

				segmentedControl.selectedSegmentIndex = 1
				loadSelfStory()

				delay(seconds: 0.0, completion: {
					self.uploadStory(story!, completion: { (success, error) in
						if success != nil && success == true {
							self.backgroundSound.playSound(true, sound: self.backgroundSound.done_sound)
							self.saveMyStory(story!, completion: { (success) in
								if success {
									self.updateLastWriteDate(NSDate())
									self.xyScrollView.writeView.clearContent()
									self.xyScrollView.storyTableView.insertNewStory(story!)
								}
							})
						} else {
							let hudView = HudView.hudInView(self.view, animated: true)
							hudView.text = "联网失败"
							hudView.nightStyle = self.nightStyle
						}
					})
				})

			}
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

}


// MARK: - DetailViewControllerDelegate

extension MainViewController: DetailViewControllerDelegate {

	func ratingChanged(index: Int, rating: Int) {
		xyScrollView.storyTableView.storys[index].rating = rating
		dailyStorys[index].rating = rating
		updateRatingOfDailyStoryInCoreData(xyScrollView.storyTableView.storys[index])
	}

	func detailViewControllerWillDismiss(topStoryIndex: Int) {
		view.alpha = 1.0

		if !forceTouchWay {
			view.transform = CGAffineTransformMakeScale(0.95, 0.95)
			UIView.animateWithDuration(0.3, animations: {
				self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
			}) { (_) in
				self.hideOrShowStatusViewAndToolbar(false)
			}

			scrollToRow(topStoryIndex)
		}

		reloadDailyStory()
	}

	func scrollToRow(row: Int) {
		if xyScrollView.storyTableView.numberOfRowsInSection(0) != 0 {
			let indexPath = NSIndexPath(forRow: row, inSection: 0)
			xyScrollView.storyTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
		}
	}
}


// MARK: - 3D Touch To DetailViewController

extension MainViewController: UIViewControllerPreviewingDelegate {

	func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = xyScrollView.storyTableView.indexPathForRowAtPoint(location), cell = xyScrollView.storyTableView.cellForRowAtIndexPath(indexPath) else { return nil }

		let detailVC = DetailViewController()
		detailVC.topStoryIndex = indexPath.row
		setUpDetailVC(detailVC)
		detailVC.preferredContentSize = CGSize(width: 0.0, height: 0.0)
		previewingContext.sourceRect = cell.frame
		forceTouchWay = true
		return detailVC
	}

	func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
		statusView.frame.origin.y -= 20
		statusBarHidden = true
		navigationController?.setToolbarHidden(true, animated: true)
		presentViewController(viewControllerToCommit, animated: false, completion: nil)
		forceTouchWay = false
	}
}


// MARK: - InputViewControllerDelegate

extension MainViewController: InputViewControllerDelegate {

	func inputTextViewDidReturn(index: Int, text: String) {
		navigationController?.toolbarHidden = true
		xyScrollView.writeView.changeLabelText(index, text: text)
		pointerView.changeLabelTextForCanSaveStory(xyScrollView.writeView.doneWriting, ready: xyScrollView.writeView.ready)
	}
}


// MARK: - SettingViewDelegate

extension MainViewController: SettingViewDelegate {

	func presentViewControllerForSettringView(VC: UIViewController) {
		presentViewController(VC, animated: true, completion: nil)
	}

	func saveNotificationIndexToUserDefaults(index: Int) {
		saveNotificationIndex(index)
	}

	func saveAskedAllowNotificationToUserDefaults(asked: Bool) {
		saveAskedAllowNotification(asked)
	}
}



