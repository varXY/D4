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

	var statusBarStyle = UIStatusBarStyle.default
	var statusBarHidden = false
	var dailyStoryLoaded = false
	var forceTouchWay = false
	var nightStyle = false
	var oldTopIndex = 0
	var topViewIndex = 1

	var dailyStorys: [Story]!

	var backgroundSound = BackgroundSound()
	var internetReachability: Reachability!

	override var preferredStatusBarStyle : UIStatusBarStyle {
		return statusBarStyle
	}

	override var prefersStatusBarHidden : Bool {
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

		if traitCollection.forceTouchCapability == .available {
			registerForPreviewing(with: self, sourceView: xyScrollView.storyTableView)
		}

		NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
		internetReachability = Reachability.forInternetConnection()
		internetReachability.startNotifier()
	}

 	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reloadDailyStory()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}

	func reachabilityChanged(_ note: Notification) {
		if internetReachability.currentReachabilityStatus().rawValue != 0 {
			reloadDailyStory()
		}
	}

	// MARK: Load story & UI

	func reloadDailyStory() {
		dailyStoryLoaded = lastLoadDate().string(.dd) == Date().string(.dd)

		if !dailyStoryLoaded {

			if self.presentedViewController != nil {
				self.presentedViewController?.dismiss(animated: true, completion: nil)
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
					self.updateLastLoadDate(Date())
					self.pointerView.lastUpDateTime = Date()

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

	func loadingStory(_ loading: Bool) {
		if loading {
			if let oldView = view.viewWithTag(301) as? UIImageView {
				oldView.removeFromSuperview()
			}

			let images = colorCode.map({ UIImage.imageWithColor(MyColor.code($0).BTColors[0], rect: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50)) })
			let loadingImage = UIImage.animatedImage(with: images, duration: 1.5)
			let imageView = UIImageView(image: loadingImage)
			imageView.frame.origin = CGPoint(x: 0, y: 20)
			imageView.tag = 301

			view.addSubview(imageView)
			view.sendSubview(toBack: imageView)
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
		let effect = UIBlurEffect(style: .dark)
		statusView = UIVisualEffectView(effect: effect)
		statusView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 20)
		view.addSubview(statusView)

		segmentedControl = UISegmentedControl(items: ["今日100", "我的故事"])
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.frame.size = CGSize(width: 160, height: 29)
		segmentedControl.addTarget(self, action: #selector(segmentedControlSelected(_:)), for: .valueChanged)
		let barButton = UIBarButtonItem(customView: segmentedControl)

		addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(gotoPage(_:)))

		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(gotoPage(_:)), for: .touchUpInside)
		infoButton.isExclusiveTouch = true
		let infoBarButton = UIBarButtonItem(customView: infoButton)

		let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		let toolBarItems = [addButton, space, barButton, space, infoBarButton]

		navigationController?.isNavigationBarHidden = true
		navigationController?.isToolbarHidden = false
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
		
		let blurEffect = nightStyle ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .extraLight)
		let tintColor = nightStyle ? UIColor.white : UIColor.black
		let barStyle = nightStyle ? UIBarStyle.black : UIBarStyle.default

		statusBarStyle = nightStyle ? UIStatusBarStyle.lightContent : UIStatusBarStyle.default
		setNeedsStatusBarAppearanceUpdate()

		statusView.effect = blurEffect
		addButton.tintColor = tintColor
		navigationController?.toolbar.barStyle = barStyle
		navigationController?.toolbar.tintColor = tintColor
	}

	func segmentedControlSelected(_ segmentedControl: UISegmentedControl) {
		backgroundSound.playSound(true, sound: backgroundSound.selected_sound)
		pointerView.changeTopLabelTextWhenSegmentedControlSelected(segmentedControl.selectedSegmentIndex)
		segmentedControl.selectedSegmentIndex == 0 ? loadSavedDailyStory() : loadSelfStory()
	}

	func gotoPage(_ sender: AnyObject) {
		var pageIndex = 0
		if let _ = sender as? UIButton { pageIndex = 2 }

		backgroundSound.playSound(true, sound: backgroundSound.selected_sound)
		xyScrollView.scrolledType = .notScrollYet

		if topViewIndex == 2 {
			oldTopIndex = 2
			xyScrollView.moveContentViewToTop(pageIndex == 0 ? .left : .right)
			xyScrollViewDidScroll(.left, topViewIndex: 1)

			delay(seconds: 1.0, completion: { 
				self.oldTopIndex = 1
				self.xyScrollView.moveContentViewToTop(pageIndex == 0 ? .left : .right)
				self.xyScrollViewDidScroll((pageIndex == 0 ? .left : .right), topViewIndex: pageIndex)
			})
		} else {
			oldTopIndex = 1
			xyScrollView.moveContentViewToTop(pageIndex == 0 ? .left : .right)
			xyScrollViewDidScroll((pageIndex == 0 ? .left : .right), topViewIndex: pageIndex)
		}
	}

	func hideOrShowStatusViewAndToolbar(_ presentedVC: Bool?) {
		if presentedVC != nil {
			navigationController?.setToolbarHidden(presentedVC!, animated: true)
			hideStatusView(presentedVC!)
		} else {
			let hidden = xyScrollView.topViewIndex != 1
			navigationController?.setToolbarHidden(hidden, animated: true)
			hideStatusView(hidden)
		}
	}

	func hideStatusView(_ hide: Bool) {
		statusBarHidden = hide
		if hide { setNeedsStatusBarAppearanceUpdate() }

		if (hide && statusView.frame.origin.y == 0) || (!hide && statusView.frame.origin.y == -20) {
			let distance: CGFloat = hide ? -20 : 20

			UIView.perform(.delete, on: [], options: [], animations: { 
				self.statusView.frame.origin.y += distance
				}, completion: { (_) in
					if !hide { self.statusBarHidden = hide; self.setNeedsStatusBarAppearanceUpdate() }
			})

		}
	}

	func setUpDetailVC(_ detailVC: DetailViewController) {
		detailVC.modalPresentationStyle = .custom
		detailVC.transitioningDelegate = detailVC
		detailVC.storys = xyScrollView.storyTableView.storys
		detailVC.nightStyle = nightStyle
		detailVC.netOrLocalStory = xyScrollView.storyTableView.netOrLocalStory
		detailVC.delegate = self
	}

}


// MARK: - XYScrollViewDelegate

extension MainViewController: XYScrollViewDelegate {

	func scrollTypeDidChange(_ type: XYScrollType) {
		pointerView.showPointer(type)
	}

	func didSelectedStory(_ storyIndex: Int) {
		forceTouchWay = false
		hideOrShowStatusViewAndToolbar(true)

		let detailVC = DetailViewController()
		detailVC.topStoryIndex = storyIndex
		setUpDetailVC(detailVC)
		present(detailVC, animated: true, completion: nil)

		UIView.perform(.delete, on: [], options: [], animations: {
			self.view.alpha = 0.0
			}, completion: nil)
	}

	func xyScrollViewWillScroll(_ scrollType: XYScrollType, topViewIndex: Int) {
		pointerView.hidePointersAndLabels()
		oldTopIndex = topViewIndex
	}

	func xyScrollViewDidScroll(_ scrollType: XYScrollType, topViewIndex: Int) {
		self.topViewIndex = topViewIndex
		hideOrShowStatusViewAndToolbar(nil)

		if oldTopIndex == topViewIndex {
			switch topViewIndex {
			case 0:
				switch scrollType {
				case .up:
					pointerView.changeTextForUpInWriteView()

				case .down:
					pointerView.changeLabelTextForCanSaveStory(self.xyScrollView.writeView.doneWriting, ready: self.xyScrollView.writeView.ready)

					delay(seconds: 0.7) { self.goBackSaveUploadStory() }

				case .left:
					xyScrollView.writeView.labelsGetRandomColors()

				case .right:
					break

				default:
					break
				}

			case 2:
				switch scrollType {
				case .up:
					sendSupportEmail()

				case .left:
					break

				case .right:
					UIApplication.shared.openURL(jianShuURL! as URL)

				case .down:
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
				xyScrollView.moveContentViewToTop(.right)
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
									self.updateLastWriteDate(Date())
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

	func writeViewWillInputText(_ index: Int, oldText: String, colorCode: Int) {
		let inputVC = InputViewController()
		inputVC.modalPresentationStyle = .custom
		inputVC.transitioningDelegate = inputVC
		inputVC.index = index
		inputVC.oldText = oldText
		inputVC.colorCode = colorCode
		inputVC.delegate = self
		present(inputVC, animated: true, completion: nil)
	}

}


// MARK: - DetailViewControllerDelegate

extension MainViewController: DetailViewControllerDelegate {

	func ratingChanged(_ index: Int, rating: Int) {
		xyScrollView.storyTableView.storys[index].rating = rating
		dailyStorys[index].rating = rating
		updateRatingOfDailyStoryInCoreData(xyScrollView.storyTableView.storys[index])
	}

	func detailViewControllerWillDismiss(_ topStoryIndex: Int) {
		view.alpha = 1.0

		if !forceTouchWay {
			view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
			UIView.animate(withDuration: 0.3, animations: {
				self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
			}, completion: { (_) in
				self.hideOrShowStatusViewAndToolbar(false)
			}) 

			scrollToRow(topStoryIndex)
		}

		reloadDailyStory()
	}

	func scrollToRow(_ row: Int) {
		if xyScrollView.storyTableView.numberOfRows(inSection: 0) != 0 {
			let indexPath = IndexPath(row: row, section: 0)
			xyScrollView.storyTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
		}
	}
}


// MARK: - 3D Touch To DetailViewController

extension MainViewController: UIViewControllerPreviewingDelegate {

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = xyScrollView.storyTableView.indexPathForRow(at: location), let cell = xyScrollView.storyTableView.cellForRow(at: indexPath) else { return nil }

		let detailVC = DetailViewController()
		detailVC.topStoryIndex = (indexPath as NSIndexPath).row
		setUpDetailVC(detailVC)
		detailVC.preferredContentSize = CGSize(width: 0.0, height: 0.0)
		previewingContext.sourceRect = cell.frame
		forceTouchWay = true
		return detailVC
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		statusView.frame.origin.y -= 20
		statusBarHidden = true
		navigationController?.setToolbarHidden(true, animated: true)
		present(viewControllerToCommit, animated: false, completion: nil)
		forceTouchWay = false
	}
}


// MARK: - InputViewControllerDelegate

extension MainViewController: InputViewControllerDelegate {

	func inputTextViewDidReturn(_ index: Int, text: String) {
		navigationController?.isToolbarHidden = true
		xyScrollView.writeView.changeLabelText(index, text: text)
		pointerView.changeLabelTextForCanSaveStory(xyScrollView.writeView.doneWriting, ready: xyScrollView.writeView.ready)
	}
}


// MARK: - SettingViewDelegate

extension MainViewController: SettingViewDelegate {

	func presentViewControllerForSettringView(_ VC: UIViewController) {
		present(VC, animated: true, completion: nil)
	}

	func saveNotificationIndexToUserDefaults(_ index: Int) {
		saveNotificationIndex(index)
	}

	func saveAskedAllowNotificationToUserDefaults(_ asked: Bool) {
		saveAskedAllowNotification(asked)
	}
}



