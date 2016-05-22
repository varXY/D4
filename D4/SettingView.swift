//
//  InputView.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

protocol SettingViewProtocol: class {
	func presentViewControllerForSettringView(VC: UIViewController)
	func saveNotificationIndexToUserDefaults(index: Int)
	func saveAskedAllowNotificationToUserDefaults(asked: Bool)
}

class SettingView: UIView {

	var iconButton: UIButton!
	var primaticButtons: [UIButton]!
	var promptlabel: UILabel!
	
	private let notificationTitles = ["关", "晚8点", "晚9点", "晚10点", "早7点", "早8点", "早9点"]

	var nightStyle = false {
		didSet {
			changeColorBaseOnNightStyle(nightStyle)
		}
	}

	var savedNotificationIndex = 0 {
		didSet {
			guard let titleLabel = primaticButtons[0].subviews[0] as? UILabel else { return }
			titleLabel.text = "\n写作提醒\n" + notificationTitles[savedNotificationIndex]
		}
	}

	var askedForAllowNotification: Bool!

	weak var delegate: SettingViewProtocol?

	init() {
		super.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
		backgroundColor = UIColor.whiteColor()
		layer.cornerRadius = globalRadius
		clipsToBounds = true
		exclusiveTouch = true

		iconButton = UIButton(type: .Custom)
		iconButton.frame.size = CGSize(width: 60, height: 60)
		iconButton.center = CGPointMake(center.x, 80)
		iconButton.setImage(UIImage(named: "Icon"), forState: .Normal)
		iconButton.addTarget(self, action: #selector(gotoAppStore), forControlEvents: .TouchUpInside)
		addSubview(iconButton)

		generatePrimaticButtons()

		promptlabel = UILabel()
		promptlabel.frame.size = CGSizeMake(ScreenWidth, 60)
		promptlabel.center = CGPointMake(center.x, ScreenHeight - 80)
		promptlabel.numberOfLines = 0
		promptlabel.textAlignment = .Center
		promptlabel.attributedText = attributedString(false)
		addSubview(promptlabel)

	}

	func generatePrimaticButtons() {
		let gap: CGFloat = 0.0  // CGFloat(sqrt(100.0))
		let diagonalLength = (ScreenWidth - (ScreenWidth / 3) - (gap * 3)) / 2
		let center = CGPoint(x: ScreenWidth / 2, y: ScreenHeight / 2)
		let centerDistance = diagonalLength / 2 + gap
		let buttonCenters = [
			CGPointMake(center.x, center.y - centerDistance),
			CGPointMake(center.x - centerDistance, center.y),
			CGPointMake(center.x + centerDistance, center.y),
			CGPointMake(center.x, center.y + centerDistance)
		]

		let buttonSize = CGSizeMake(diagonalLength / sqrt(2), diagonalLength / sqrt(2))
		let titles = ["\n写作提醒\n" + notificationTitles[0], "分享", "评分", "简介"]

		primaticButtons = buttonCenters.map({
			let i = buttonCenters.indexOf($0)!
			let button = prismaticButton(titles[i], center: buttonCenters[i], size: buttonSize)
			button.addTarget(self, action: #selector(prismaticButtonTouchDown(_:)), forControlEvents: .TouchDown)
			button.addTarget(self, action: #selector(prismaticButtonTouchInside(_:)), forControlEvents: .TouchUpInside)
			addSubview(button)
			return button
		})

	}

	func prismaticButton(title: String, center: CGPoint, size: CGSize) -> UIButton {
		let colorCode = randomColorCode()
		let button = UIButton(type: .System)
		button.backgroundColor = MyColor.code(colorCode).BTColors[0]
		button.frame.size = size
		button.center = center
		button.exclusiveTouch = true
		button.transform = CGAffineTransformMakeRotation(CGFloat(45 * M_PI / 180))

		let titleLabel = UILabel(frame: CGRectMake(0, 0, size.width, size.height))
		titleLabel.transform = CGAffineTransformMakeRotation(CGFloat(-45 * M_PI / 180))
		button.addSubview(titleLabel)

		titleLabel.font = ScreenWidth == 320 ? UIFont.systemFontOfSize(14) : UIFont.systemFontOfSize(15)
		titleLabel.text = title
		titleLabel.numberOfLines = 0
		titleLabel.textColor = MyColor.code(colorCode).BTColors[1]
		titleLabel.textAlignment = .Center
		return button
	}



	func changeColorBaseOnNightStyle(nightStyle: Bool) {
		backgroundColor = nightStyle ? MyColor.code(5).BTColors[0] : UIColor.whiteColor()
		iconButton.setImage(UIImage(named: nightStyle ? "IconBlack" : "Icon"), forState: .Normal)
		randomColorForPrimaticButtons()
		promptlabel.attributedText = attributedString(nightStyle)
	}

	func randomColorForPrimaticButtons() {
		primaticButtons.forEach({
			let colorCode = randomColorCodeForPrimaticButton()
			$0.backgroundColor = MyColor.code(colorCode).BTColors[0]
			guard let titleLabel = $0.subviews[0] as? UILabel else { return }
			titleLabel.textColor = MyColor.code(colorCode).BTColors[1]
		})
	}

	func attributedString(nightStyle: Bool) -> NSMutableAttributedString {
		let texts = ["操作提示\n上下左右划"]
		let bodyColor = nightStyle ? UIColor.whiteColor() : MyColor.code(5).BTColors[0]

		let titleAttributes = [
			NSForegroundColorAttributeName: bodyColor,
			NSFontAttributeName: UIFont.systemFontOfSize(12)
		]

		let bodyAttributes = [
			NSForegroundColorAttributeName: MyColor.code(14).BTColors[0],
			NSFontAttributeName: UIFont.boldSystemFontOfSize(15)
		]

		let string = NSMutableAttributedString(string: texts[0], attributes: bodyAttributes)
		let range = string.mutableString.rangeOfString("操作提示")
		string.addAttributes(titleAttributes, range: range)

		return string
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Button Tapped

extension SettingView {

	func prismaticButtonTouchDown(sender: UIButton) {
		let colorCode = randomColorCodeForPrimaticButton()
		sender.backgroundColor = MyColor.code(colorCode).BTColors[0]
		guard let titleLabel = sender.subviews[0] as? UILabel else { return }
		titleLabel.textColor = MyColor.code(colorCode).BTColors[1]
	}

	func prismaticButtonTouchInside(sender: UIButton) {
		primaticButtons.forEach({ $0.userInteractionEnabled = false })
		iconButton.userInteractionEnabled = false

		switch primaticButtons.indexOf(sender)! {
		case 0: changeNotification()
		case 1: shareContent()
		case 2: gotoAppStore()
		case 3: showInfo()
		default: break
		}

		primaticButtons.forEach({ $0.userInteractionEnabled = true })
		iconButton.userInteractionEnabled = true
	}

	func changeNotification() {
		let alertController = UIAlertController(title: "设置每日写作提醒", message: "每天写一个故事，提醒一次", preferredStyle: .ActionSheet)
		let actions: [UIAlertAction] = notificationTitles.map({
			let index = notificationTitles.indexOf($0)!
			let action = UIAlertAction(title: $0, style: .Default, handler: { (_) in
				self.notificationSelected(index)
			})
			return action
		})

		actions.forEach({ alertController.addAction($0) })
		alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
		delegate?.presentViewControllerForSettringView(alertController)
	}

	func notificationSelected(index: Int) {
		delegate?.saveNotificationIndexToUserDefaults(index)
		scheduleNotification(index)
	}

	func shareContent() {
		let text: String = "我在我的一天里写我一天的故事 —— 我的一天：写故事应用"
		let arr: [AnyObject] = [text, appStoreURL!]
		let shareVC = UIActivityViewController(activityItems: arr, applicationActivities: [])
		delegate?.presentViewControllerForSettringView(shareVC)
	}

	func gotoAppStore() {
		UIApplication.sharedApplication().openURL(appStoreURL!)
	}

	func showInfo() {
		let title = "开放匿名分享故事社区"
		let message = "\n一天的故事\n=\n标题\n+\n上午 + 下午 + 晚上\n+\n睡前哲思\n=\n10 + 100 + 100 + 100 + 20\n\n今日100\n=\n50个今日最新\n+\n49个昨日最热\n+\n1个你的故事\n=\n(50 + 49 + 1) × 330\n\nPS：今日100每天刷新一次 <= 100"
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
		let cancelAction = UIAlertAction(title: "了解了", style: .Cancel, handler: nil)
		alertController.addAction(cancelAction)
		delegate?.presentViewControllerForSettringView(alertController)
	}
}

// MARK: - Notification

extension SettingView {

	func scheduleNotification(index: Int) {
		let notificationSettings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
		let notificationSetting_Sound = UIUserNotificationSettings(forTypes: .Sound, categories: nil)
		UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
		UIApplication.sharedApplication().registerUserNotificationSettings(notificationSetting_Sound)

		let setting = UIApplication.sharedApplication().currentUserNotificationSettings()!
		let notificationEnable = setting.types != UIUserNotificationType.None

		if notificationEnable || !askedForAllowNotification {
			if let notification = oldNotification() {
				UIApplication.sharedApplication().cancelLocalNotification(notification)
			}

			if index != 0 {
				let localNotification = UILocalNotification()
				localNotification.fireDate = dateFromIndex(index)
				localNotification.timeZone = NSTimeZone.defaultTimeZone()
				localNotification.repeatInterval = .Day
				localNotification.alertBody = "写故事时间到"
				localNotification.soundName = UILocalNotificationDefaultSoundName

				UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
			}

			if notificationEnable {
				guard let titleLabel = primaticButtons[0].subviews[0] as? UILabel else { return }
				titleLabel.text = "\n写作提醒\n" + notificationTitles[index]
			}

			if !askedForAllowNotification {
				askedForAllowNotification = true
				delegate?.saveAskedAllowNotificationToUserDefaults(askedForAllowNotification)
			}

		} else {
			let alertController = UIAlertController(title: "无法提醒", message: "请在设置里打开通知", preferredStyle: .Alert)
			let setAction = UIAlertAction(title: "去设置", style: .Default, handler: { (_) in
				UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
			})
			let cancelAction = UIAlertAction(title: "取消", style: .Default, handler: nil)

			alertController.addAction(cancelAction)
			alertController.addAction(setAction)

			delegate?.presentViewControllerForSettringView(alertController)
		}

	}

	func oldNotification() -> UILocalNotification? {
		let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
		if allNotifications?.count == 1 { return allNotifications![0] }
		return nil
	}

	func dateFromIndex(index: Int) -> NSDate {
		var HH = "20"
		switch index {
		case 1, 2, 3: HH = "\(index + 19)"
		case 4, 5, 6: HH = "0" + "\(index + 3)"
		default: break
		}

		let scheduledToday = NSDate.specificDate(tomorrow: false, HH: HH)
		return scheduledToday.timeIntervalSinceDate(NSDate()) <= 0 ? NSDate.specificDate(tomorrow: true, HH: HH) : scheduledToday
	}
}

