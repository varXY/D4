//
//  ViewController.swift
//  D4
//
//  Created by 文川术 on 3/30/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit
import StoreKit

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

	var dailyStorys: [Story]!

	var nightStyle = false

	var oldTopIndex = 0

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

		dailyStorys = xyScrollView.X1_storyTableView.storys

		setupBars()

		if traitCollection.forceTouchCapability == .Available {
			registerForPreviewingWithDelegate(self, sourceView: xyScrollView.X1_storyTableView)
		}

	}

 	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		testLoadStory()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

	}

	// MARK: -

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
//		statusView.addBorder(borderColor: UIColor.whiteColor(), width: 0.2)
//		navigationController?.toolbar.addBorder(borderColor: UIColor.whiteColor(), width: 0.2)

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
		nightStyle = (hour >= 18 && hour < 24) || (hour >= 0 && hour < 6)
//		nightStyle = true
		xyScrollView.writeView.nightStyle = nightStyle
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
		segmentedControl.selectedSegmentIndex == 0 ? loadSavedDailyStory() : loadSelfStory()
	}

	func goToAddPage() {
		xyScrollView.scrolledType = .NotScrollYet
		xyScrollView.moveContentViewToTop(.Left)
		pointerView.showTextBaseOnTopIndex(0)
		pointerView.addOrRemoveUpAndDownPointerAndLabel(0)
		pointerView.changeLabelTextForCanSaveStory(xyScrollView.writeView.ready)
		hideOrShowStatusViewAndToolbar(nil)

		if xyScrollView.writeView.firstColor == false {
			xyScrollView.writeView.labelsGetRandomColors()
		}
	}

	func goToInfoPage() {
		xyScrollView.scrolledType = .NotScrollYet
		xyScrollView.moveContentViewToTop(.Right)
		pointerView.showTextBaseOnTopIndex(2)
		pointerView.addOrRemoveUpAndDownPointerAndLabel(2)
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

//			UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
//				self.statusView.frame.origin.y += distance
//				}, completion: { (_) in
//					if !hide { self.setNeedsStatusBarAppearanceUpdate() }
//			})

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
//			self.view.transform = CGAffineTransformMakeScale(0.95, 0.95)
			}) { (_) in
//				self.view.alpha = 0.0
//				self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
//				self.statusView.frame.origin.y -= 20
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
		oldTopIndex = topViewIndex
	}

	func xyScrollViewDidScroll(scrollType: XYScrollType, topViewIndex: Int) {
		hideOrShowStatusViewAndToolbar(nil)
		pointerView.showTextBaseOnTopIndex(topViewIndex)
		pointerView.addOrRemoveUpAndDownPointerAndLabel(topViewIndex)

		if oldTopIndex == topViewIndex {
			switch topViewIndex {
			case 0:
				pointerView.changeLabelTextForCanSaveStory(xyScrollView.writeView.ready)

				switch scrollType {
				case .Down:
					delay(seconds: 0.7) { self.goBackSaveUploadStory() }

				case .Left:
					xyScrollView.writeView.labelsGetRandomColors()

				default:
					break
				}

			case 2:
				switch scrollType {
				case .Up:
					sendSupportEmail()

				case .Left:
					if !xyScrollView.writeView.firstColor {
						xyScrollView.writeView.labelsGetRandomColors()
					}

				case .Right:
					UIApplication.sharedApplication().openURL(NSURL(string: "http://www.jianshu.com/users/83ddcf71e52c")!)

				case .Down:
					connectToStore()

				default:
					break
				}
				
			default:
				break
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
				hideOrShowStatusViewAndToolbar(nil)

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

			let indexPath = NSIndexPath(forRow: topStoryIndex, inSection: 0)
			xyScrollView.X1_storyTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
		}
	}
}

// MARK: - InputViewControllerDelegate

extension MainViewController: InputViewControllerDelegate {

	func inputTextViewDidReturn(index: Int, text: String) {
		navigationController?.toolbarHidden = true
		xyScrollView.writeView.changeLabelText(index, text: text)
		pointerView.changeLabelTextForCanSaveStory(xyScrollView.writeView.ready)
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
		indicator.frame.size.height += 64
		indicator.frame.origin.y -= 64
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
		hudView.textColor = nightStyle ? UIColor.whiteColor() : UIColor.blackColor()
		hudView.hudBackgroundColor = nightStyle ? UIColor(white: 0.3, alpha: 0.7) : UIColor(white: 1.0, alpha: 0.7)
	}

	func productPurchased(notification: NSNotification) {
		_ = notification.object as! String
	}
}

