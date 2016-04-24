//
//  ViewController.swift
//  D4
//
//  Created by 文川术 on 3/30/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit
import StoreKit
import AVFoundation


class MainViewController: UIViewController, LeanCloud, CoreDataAndStory, UserDefaults, MailSending {

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

		xyScrollView = XYScrollView(VC: self)
		xyScrollView.XYDelegate = self
		view.addSubview(xyScrollView)
		xyScrollView.X1_storyTableView.scrollsToTop = true
		xyScrollView.writeView.backgroundSound = backgroundSound
		xyScrollView.writeView.addtipLabels(true, removeIndex: nil)

		dailyStorys = xyScrollView.X1_storyTableView.storys

		setupBars()

		if traitCollection.forceTouchCapability == .Available {
			registerForPreviewingWithDelegate(self, sourceView: xyScrollView.X1_storyTableView)
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

	// MARK: -

	func reloadDailyStory() {
		let lastDate = lastLoadDate()
		dailyStoryLoaded = lastDate.string(.dd) == NSDate().string(.dd)

		if !dailyStoryLoaded {
			scrollToRow(0)
			pointerView.lastUpdateText = ""
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
				pointerView.lastUpdateText = "已更新"
			}
		}

	}

	func loadingStory(loading: Bool) {
		if loading {
			let images = colorCode.map({ UIImage.imageWithColor(MyColor.code($0).BTColors[0], rect: CGRectMake(0, 0, ScreenWidth, 50)) })
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
		xyScrollView.X1_storyTableView.netOrLocalStory = 0
		xyScrollView.X1_storyTableView.reloadData()
	}

	func loadSelfStory() {
		getMyStorys { (storys) in
			self.xyScrollView.storys = storys
			self.xyScrollView.X1_storyTableView.netOrLocalStory = 1
			self.xyScrollView.X1_storyTableView.reloadData()
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
		let hour = Int(NSDate().string(.HH))
		nightStyle = (hour >= 18 && hour < 24) || (hour >= 0 && hour < 6)
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
		xyScrollView.moveContentViewToTop(pageIndex == 0 ? .Left : .Right)
		oldTopIndex = 1
		xyScrollViewDidScroll((pageIndex == 0 ? .Left : .Right), topViewIndex: 0)
		pointerView.showTextBaseOnTopIndex(pageIndex)
		pointerView.addOrRemoveUpAndDownPointerAndLabel(pageIndex)
		hideOrShowStatusViewAndToolbar(nil)
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

}

// MARK: - XYScrollViewDelegate

extension MainViewController: XYScrollViewDelegate {

	func scrollTypeDidChange(type: XYScrollType) {
		pointerView.changePointerDirection(type)
	}

	func didSelectedStory(storyIndex: Int) {
		forceTouchWay = false

		let detailVC = DetailViewController()
		detailVC.topStoryIndex = storyIndex
		setUpDetailVC(detailVC)
		presentViewController(detailVC, animated: true) { 
			self.hideOrShowStatusViewAndToolbar(true)
		}

		UIView.animateWithDuration(0.3, animations: {
			self.view.alpha = 0.0
			}) { (_) in
		}
	}

	func setUpDetailVC(detailVC: DetailViewController) {
		detailVC.modalPresentationStyle = .Custom
		detailVC.transitioningDelegate = detailVC
		detailVC.storys = xyScrollView.X1_storyTableView.storys
		detailVC.nightStyle = nightStyle
		detailVC.netOrLocalStory = xyScrollView.X1_storyTableView.netOrLocalStory
		detailVC.delegate = self
	}


	func xyScrollViewWillScroll(scrollType: XYScrollType, topViewIndex: Int) {
		oldTopIndex = topViewIndex
	}

	func xyScrollViewDidScroll(scrollType: XYScrollType, topViewIndex: Int) {
		hideOrShowStatusViewAndToolbar(nil)
		pointerView.showTextBaseOnTopIndex(topViewIndex)

		if oldTopIndex == topViewIndex {
			switch topViewIndex {
			case 0:
				switch scrollType {
				case .Up:
					pointerView.changeTextForUpInWriteView()
					
				case .Down:
					pointerView.changeLabelTextForCanSaveStory(xyScrollView.writeView.doneWriting, ready: xyScrollView.writeView.ready)
					delay(seconds: 0.7) { self.goBackSaveUploadStory() }

				case .Left:
					xyScrollView.writeView.labelsGetRandomColors()

				case.Right:
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
			pointerView.addOrRemoveUpAndDownPointerAndLabel(topViewIndex)

			if topViewIndex == 0 && oldTopIndex == 1 {
				xyScrollView.writeView.addDots(true)
				xyScrollView.writeView.checkText()
				pointerView.changeLabelTextForCanSaveStory(xyScrollView.writeView.doneWriting, ready: xyScrollView.writeView.ready)
			}

			if topViewIndex == 1 && oldTopIndex == 0 {
				xyScrollView.writeView.addDots(false)
			}

			if topViewIndex == 2 && oldTopIndex == 1 {
				xyScrollView.settingView.randomColorForPointerView()
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
									self.xyScrollView.X1_storyTableView.insertNewStory(story!)
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
		xyScrollView.X1_storyTableView.storys[index].rating = rating
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
		if xyScrollView.X1_storyTableView.numberOfRowsInSection(0) != 0 {
			let indexPath = NSIndexPath(forRow: row, inSection: 0)
			xyScrollView.X1_storyTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
		}
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

// MARK: - 3D Touch

extension MainViewController: UIViewControllerPreviewingDelegate {

	func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = xyScrollView.X1_storyTableView.indexPathForRowAtPoint(location), cell = xyScrollView.X1_storyTableView.cellForRowAtIndexPath(indexPath) else { return nil }

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


// MARK: - Purchese

extension MainViewController {

	func connectToStore() {

		let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
		indicator.startAnimating()
		indicator.frame = self.view.bounds
		UIView.animateWithDuration(0.3, animations: { indicator.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 56/255, alpha: 0.45) })
		view.addSubview(indicator)
		view.userInteractionEnabled = false

		SupportProducts.store.requestProductsWithCompletionHandler({ (success, products) -> () in
			indicator.removeFromSuperview()
			self.view.userInteractionEnabled = true
			if success {
				self.purchaseProduct(products[0])

			} else {
				let title = NSLocalizedString("连接失败", comment: "SettingVC")
				let message = NSLocalizedString("请检查你的网络连接后重试", comment: "SettingVC")
				let ok = NSLocalizedString("确定", comment: "SettingVC")
				let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
				let action = UIAlertAction(title: ok, style: .Default, handler: nil)
				alertController.addAction(action)
				self.presentViewController(alertController, animated: true, completion: nil)
			}
		})
	}

	func purchaseProduct(product: SKProduct) {
		SupportProducts.store.purchaseProduct(product)
		let hudView = HudView.hudInView(self.view, animated: true)
		hudView.text = "谢谢!"
		hudView.nightStyle = nightStyle
	}

	func productPurchased(notification: NSNotification) {
		_ = notification.object as! String
	}
}

