//
//  InputView.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

protocol SettingViewDelegate: class {
	func presentViewControllerForSettringView(_ VC: UIViewController)
	func saveNotificationIndexToUserDefaults(_ index: Int)
	func saveAskedAllowNotificationToUserDefaults(_ asked: Bool)
}

class SettingView: UIView {

	var iconButton: UIButton!
	var primaticButtons: [UIButton]!
	var promptlabel: UILabel!
	
	fileprivate let notificationTitles = ["关", "晚八点", "晚九点", "晚十点", "早七点", "早八点", "早九点"]

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

	weak var delegate: SettingViewDelegate?

	init() {
		super.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
		backgroundColor = UIColor.white
		layer.cornerRadius = globalRadius
		clipsToBounds = true
		isExclusiveTouch = true

		iconButton = UIButton(type: .custom)
		iconButton.frame.size = CGSize(width: 60, height: 60)
		iconButton.center = CGPoint(x: center.x, y: 80)
		iconButton.setImage(UIImage(named: "Icon"), for: UIControlState())
		iconButton.addTarget(self, action: #selector(gotoAppStore), for: .touchUpInside)
		addSubview(iconButton)

		generatePrimaticButtons()

		promptlabel = UILabel()
		promptlabel.frame.size = CGSize(width: ScreenWidth, height: 60)
		promptlabel.center = CGPoint(x: center.x, y: ScreenHeight - 80)
		promptlabel.numberOfLines = 0
		promptlabel.textAlignment = .center
		promptlabel.attributedText = attributedString(false)
		addSubview(promptlabel)

	}

	func generatePrimaticButtons() {
		let gap: CGFloat = 0.0  // CGFloat(sqrt(100.0))
		let diagonalLength = (ScreenWidth - (ScreenWidth / 3) - (gap * 3)) / 2
		let center = CGPoint(x: ScreenWidth / 2, y: ScreenHeight / 2)
		let centerDistance = diagonalLength / 2 + gap
		let buttonCenters = [
			CGPoint(x: center.x, y: center.y - centerDistance),
			CGPoint(x: center.x - centerDistance, y: center.y),
			CGPoint(x: center.x + centerDistance, y: center.y),
			CGPoint(x: center.x, y: center.y + centerDistance)
		]

		let buttonSize = CGSize(width: diagonalLength / sqrt(2), height: diagonalLength / sqrt(2))
		let titles = ["\n写作提醒\n" + notificationTitles[0], "分享", "评分", "简介"]

		primaticButtons = buttonCenters.map({
			let i = buttonCenters.index(of: $0)!
			let button = prismaticButton(titles[i], center: buttonCenters[i], size: buttonSize)
			button.addTarget(self, action: #selector(prismaticButtonTouchDown(_:)), for: .touchDown)
			button.addTarget(self, action: #selector(prismaticButtonTouchInside(_:)), for: .touchUpInside)
			addSubview(button)
			return button
		})

	}

	func prismaticButton(_ title: String, center: CGPoint, size: CGSize) -> UIButton {
		let colorCode = randomColorCode()
		let button = UIButton(type: .system)
		button.backgroundColor = MyColor.code(colorCode).BTColors[0]
		button.frame.size = size
		button.center = center
		button.isExclusiveTouch = true
		button.transform = CGAffineTransform(rotationAngle: CGFloat(45 * M_PI / 180))

		let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
		titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat(-45 * M_PI / 180))
		button.addSubview(titleLabel)

		titleLabel.font = ScreenWidth == 320 ? UIFont.systemFont(ofSize: 14) : UIFont.systemFont(ofSize: 15)
		titleLabel.text = title
		titleLabel.numberOfLines = 0
		titleLabel.textColor = MyColor.code(colorCode).BTColors[1]
		titleLabel.textAlignment = .center
		return button
	}



	func changeColorBaseOnNightStyle(_ nightStyle: Bool) {
		backgroundColor = nightStyle ? MyColor.code(5).BTColors[0] : UIColor.white
		iconButton.setImage(UIImage(named: nightStyle ? "IconBlack" : "Icon"), for: UIControlState())
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

	func attributedString(_ nightStyle: Bool) -> NSMutableAttributedString {
		let texts = ["操作提示\n上下左右划"]
		let bodyColor = nightStyle ? UIColor.white : MyColor.code(5).BTColors[0]

		let titleAttributes = [
			NSForegroundColorAttributeName: bodyColor,
			NSFontAttributeName: UIFont.systemFont(ofSize: 12)
		]

		let bodyAttributes = [
			NSForegroundColorAttributeName: MyColor.code(14).BTColors[0],
			NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)
		]

		let string = NSMutableAttributedString(string: texts[0], attributes: bodyAttributes)
		let range = string.mutableString.range(of: "操作提示")
		string.addAttributes(titleAttributes, range: range)

		return string
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}


// MARK: - Button Tapped

extension SettingView {

	func prismaticButtonTouchDown(_ sender: UIButton) {
		let colorCode = randomColorCodeForPrimaticButton()
		sender.backgroundColor = MyColor.code(colorCode).BTColors[0]
		guard let titleLabel = sender.subviews[0] as? UILabel else { return }
		titleLabel.textColor = MyColor.code(colorCode).BTColors[1]
	}

	func prismaticButtonTouchInside(_ sender: UIButton) {
		primaticButtons.forEach({ $0.isUserInteractionEnabled = false })
		iconButton.isUserInteractionEnabled = false

		switch primaticButtons.index(of: sender)! {
		case 0: changeNotification()
		case 1: shareContent()
		case 2: gotoAppStore()
		case 3: showInfo()
		default: break
		}

		primaticButtons.forEach({ $0.isUserInteractionEnabled = true })
		iconButton.isUserInteractionEnabled = true
	}

	func changeNotification() {
		let alertController = UIAlertController(title: "设置每日写作提醒", message: "每天写一个故事，提醒一次", preferredStyle: .actionSheet)
		let actions: [UIAlertAction] = notificationTitles.map({
			let index = notificationTitles.index(of: $0)!
			let action = UIAlertAction(title: $0, style: .default, handler: { (_) in
				self.notificationSelected(index)
			})
			return action
		})

		actions.forEach({ alertController.addAction($0) })
		alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
		delegate?.presentViewControllerForSettringView(alertController)
	}

	func notificationSelected(_ index: Int) {
		delegate?.saveNotificationIndexToUserDefaults(index)
		scheduleNotification(index)
	}

	func shareContent() {
		let text: String = "App Store: 天的故事"
		let arr: [AnyObject] = [text as AnyObject, appStoreURL! as AnyObject]
		let shareVC = UIActivityViewController(activityItems: arr, applicationActivities: [])
		delegate?.presentViewControllerForSettringView(shareVC)
	}

	func gotoAppStore() {
		UIApplication.shared.openURL(appStoreURL! as URL)
	}

	func showInfo() {
		let title = "开放匿名分享故事社区"
		let message = "\n一天的故事\n=\n标题\n+\n上午 + 下午 + 晚上\n+\n睡前哲思\n=\n10 + 100 + 100 + 100 + 20\n\n今日100\n=\n50个今日最新\n+\n49个昨日最热\n+\n1个你的故事\n=\n(50 + 49 + 1) × 330\n\nPS：今日100每天刷新一次 <= 100"
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		let cancelAction = UIAlertAction(title: "知道了", style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		delegate?.presentViewControllerForSettringView(alertController)
	}
}

// MARK: - Notification

extension SettingView {

	func scheduleNotification(_ index: Int) {
		let notificationSettings = UIUserNotificationSettings(types: .alert, categories: nil)
		let notificationSetting_Sound = UIUserNotificationSettings(types: .sound, categories: nil)
		UIApplication.shared.registerUserNotificationSettings(notificationSettings)
		UIApplication.shared.registerUserNotificationSettings(notificationSetting_Sound)

		let setting = UIApplication.shared.currentUserNotificationSettings!
		let notificationEnable = setting.types != UIUserNotificationType()

		if notificationEnable || !askedForAllowNotification {
			if let notification = oldNotification() {
				UIApplication.shared.cancelLocalNotification(notification)
			}

			if index != 0 {
				let localNotification = UILocalNotification()
				localNotification.fireDate = dateFromIndex(index)
				localNotification.timeZone = TimeZone.current
				localNotification.repeatInterval = .day
				localNotification.alertBody = "写故事时间到"
				localNotification.soundName = UILocalNotificationDefaultSoundName

				UIApplication.shared.scheduleLocalNotification(localNotification)
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
			let alertController = UIAlertController(title: "无法提醒", message: "请在设置里打开通知", preferredStyle: .alert)
			let setAction = UIAlertAction(title: "去设置", style: .default, handler: { (_) in
				UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
			})
			let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)

			alertController.addAction(cancelAction)
			alertController.addAction(setAction)

			delegate?.presentViewControllerForSettringView(alertController)
		}

	}

	func oldNotification() -> UILocalNotification? {
		let allNotifications = UIApplication.shared.scheduledLocalNotifications
		if allNotifications?.count == 1 { return allNotifications![0] }
		return nil
	}

	func dateFromIndex(_ index: Int) -> Date {
		var HH = "20"
		switch index {
		case 1, 2, 3: HH = "\(index + 19)"
		case 4, 5, 6: HH = "0" + "\(index + 3)"
		default: break
		}

		let scheduledToday = Date.specificDate(tomorrow: false, HH: HH)
		return scheduledToday.timeIntervalSince(Date()) <= 0 ? Date.specificDate(tomorrow: true, HH: HH) : scheduledToday
	}
}

