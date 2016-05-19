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
}

class SettingView: UIView {

	var labels: [UILabel]!
	var iconButton: UIButton!
	var pointerImageViews: [UIImageView]!
	var primaicButtons: [UIButton]!

	let notificationTitles = ["关", "晚8点", "晚9点", "晚10点", "早7点", "早8点", "早9点"]

	var nightStyle = false {
		didSet {
			changeColorBaseOnNightStyle(nightStyle)
		}
	}

	weak var delegate: SettingViewProtocol?

	init() {
		super.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
		backgroundColor = UIColor.whiteColor()
		layer.cornerRadius = globalRadius
		clipsToBounds = true
		exclusiveTouch = true

//		let frames = [CGRectMake(0, 30, ScreenWidth, (ScreenHeight - 60) / 2 - 30), CGRectMake(0, ((ScreenHeight - 60) / 2) + 60, ScreenWidth, (ScreenHeight - 60) / 2 - 30)]
//
//		labels = frames.map({ UILabel(frame: $0) })
//		labels.forEach({
//			$0.textColor = UIColor.blackColor()
//			$0.textAlignment = .Center
//			$0.numberOfLines = 0
//			let index = labels.indexOf($0)!
//			$0.attributedText = attributedStrings(false)[index]
//			$0.adjustsFontSizeToFitWidth = true
//			addSubview($0)
//		})

		let label = UILabel()
		label.frame.size = CGSizeMake(ScreenWidth, 60)
		label.center = CGPointMake(center.x, ScreenHeight - 80)
		label.numberOfLines = 2
		label.textAlignment = .Center
		label.attributedText = attributedString(false)
		addSubview(label)

		iconButton = UIButton(type: .Custom)
		iconButton.frame.size = CGSize(width: 60, height: 60)
		iconButton.center = CGPointMake(center.x, 80)
		iconButton.setImage(UIImage(named: "Icon"), forState: .Normal)
		iconButton.addTarget(self, action: #selector(gotoAppStore), forControlEvents: .TouchUpInside)
		addSubview(iconButton)

		generatePrimaticButtons()

//		let pointer = Pointer()
//		pointerImageViews = [pointer.imageView(.Up), pointer.imageView(.Down), pointer.imageView(.Left), pointer.imageView(.Right)]
//		pointerImageViews.forEach({
//			$0.center = pointer.toCenters[pointerImageViews.indexOf($0)!]
//			$0.transform = CGAffineTransformScale($0.transform, 0.7, 0.7)
//			$0.tintColor = MyColor.code(randomColorCode()).BTColors[0]
//			addSubview($0)
//		})

	}

	func generatePrimaticButtons() {
		let gap = CGFloat(sqrt(0.5))
		let diagonalLength = (ScreenWidth - 60 - (gap * 3)) / 2
		let center = CGPoint(x: ScreenWidth / 2, y: ScreenHeight / 2)
		let centerDistance = diagonalLength / 2 + gap
		let buttonCenters = [
			CGPointMake(center.x, center.y - centerDistance),
			CGPointMake(center.x - centerDistance, center.y),
			CGPointMake(center.x + centerDistance, center.y),
			CGPointMake(center.x, center.y + centerDistance)
		]

		let buttonSize = CGSizeMake(diagonalLength / sqrt(2), diagonalLength / sqrt(2))
		let titles = ["写作提醒\n\n" + notificationTitles[0], "分享", "评分", "简介"]

		primaicButtons = buttonCenters.map({
			let i = buttonCenters.indexOf($0)!
			let button = prismaticButton(titles[i], center: buttonCenters[i], size: buttonSize)
			button.addTarget(self, action: #selector(prismaticButtonTouchDown(_:)), forControlEvents: .TouchDown)
			button.addTarget(self, action: #selector(prismaticButtonTouchUpOutside(_:)), forControlEvents: .TouchUpOutside)
			button.addTarget(self, action: #selector(prismaticButtonTouchInside(_:)), forControlEvents: .TouchUpInside)
			addSubview(button)
			return button
		})
	}

	func prismaticButton(title: String, center: CGPoint, size: CGSize) -> UIButton {
		let button = UIButton(type: .System)
		button.backgroundColor = MyColor.code(5).BTColors[0]
		button.frame.size = size
		button.center = center
		button.exclusiveTouch = true
		button.transform = CGAffineTransformMakeRotation(CGFloat(45 * M_PI / 180))

		let titleLabel = UILabel(frame: CGRectMake(0, 0, size.width, size.height))
		titleLabel.transform = CGAffineTransformMakeRotation(CGFloat(-45 * M_PI / 180))
		button.addSubview(titleLabel)

		titleLabel.font = ScreenHeight == 480 ? UIFont.systemFontOfSize(13) : UIFont.systemFontOfSize(18)
		titleLabel.text = title
		titleLabel.numberOfLines = 0
		titleLabel.textColor = MyColor.code(5).BTColors[1]
		titleLabel.textAlignment = .Center
		return button
	}



	func changeColorBaseOnNightStyle(nightStyle: Bool) {
		backgroundColor = nightStyle ? MyColor.code(5).BTColors[0] : UIColor.whiteColor()
		
//		let imageName = nightStyle ? "IconBlack" : "Icon"
//		iconButton.setImage(UIImage(named: imageName), forState: .Normal)

//		randomColorForPointerView()
//		labels.forEach({
//			$0.attributedText = attributedStrings(nightStyle)[labels.indexOf($0)!]
//		})
	}

	func randomColorForPointerView() {
//		pointerImageViews.forEach({ $0.tintColor = MyColor.code(randomColorCode()).BTColors[0] })
	}

	func attributedStrings(nightStyle: Bool) -> [NSMutableAttributedString] {
		let texts = ["一天的故事\n=\n标题\n+\n上午 + 下午 + 晚上\n+\n睡前哲思\n=\n10 + 100 + 100 + 100 + 20", "今日100\n=\n50个今日最新\n+\n49个昨日最热\n+\n1个你的故事\n=\n(50 + 49 + 1) × 330"]
		let titleAttributes = [
			NSForegroundColorAttributeName: MyColor.code(14).BTColors[0],
			NSFontAttributeName: UIFont.boldSystemFontOfSize(17)
		]

		let bodyColor = nightStyle ? UIColor.whiteColor() : MyColor.code(5).BTColors[0]
		let bodyAttributes = [
			NSForegroundColorAttributeName: bodyColor,
			NSFontAttributeName: UIFont.systemFontOfSize(14)
		]

		let string_0 = NSMutableAttributedString(string: texts[0], attributes: bodyAttributes)
		let range_0 = string_0.mutableString.rangeOfString("一天的故事")
		string_0.addAttributes(titleAttributes, range: range_0)

		let string_1 = NSMutableAttributedString(string: texts[1], attributes: bodyAttributes)
		let range_1 = string_1.mutableString.rangeOfString("今日100")
		string_1.addAttributes(titleAttributes, range: range_1)

		return [string_0, string_1]
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

		let string_0 = NSMutableAttributedString(string: texts[0], attributes: bodyAttributes)
		let range_0 = string_0.mutableString.rangeOfString("操作提示")
		string_0.addAttributes(titleAttributes, range: range_0)

		return string_0
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Button Tapped

extension SettingView {

	func prismaticButtonTouchDown(sender: UIButton) {
		UIView.animateWithDuration(0.1) {
			sender.transform = CGAffineTransformScale(sender.transform, 0.8, 0.8)
		}
//		UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: {
//			}, completion:  nil)
	}

	func prismaticButtonTouchUpOutside(sender: UIButton) {
		UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: {
			sender.transform = CGAffineTransformScale(sender.transform, (1.0 / 0.8), (1.0 / 0.8))
			}, completion:  nil)
	}

	func prismaticButtonTouchInside(sender: UIButton) {
		primaicButtons.forEach({ $0.userInteractionEnabled = false })
		iconButton.userInteractionEnabled = false

		UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: {
			sender.transform = CGAffineTransformScale(sender.transform, (1.0 / 0.8), (1.0 / 0.8))
			}, completion:  { (_) in

				switch self.primaicButtons.indexOf(sender)! {
				case 0:
					self.changeNotification()
				case 1:
					self.shareContent()
				case 2:
					self.gotoAppStore()
				default:
					break
				}

				self.primaicButtons.forEach({ $0.userInteractionEnabled = true })
				self.iconButton.userInteractionEnabled = true
		})
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
		guard let titleLabel = primaicButtons[0].subviews[0] as? UILabel else { return }
		titleLabel.text = "写作提醒\n\n" + notificationTitles[index]

		scheduleNotification(index)
	}

	func shareContent() {
		let text: String = "我在我的一天里写我一天的故事 —— 我的一天：写故事应用"
		let arr: [AnyObject] = [text, appStoreURL!]

		let shareVC = UIActivityViewController(activityItems: arr, applicationActivities: [])
		shareVC.completionWithItemsHandler = { (type:String?, complete:Bool, arr:[AnyObject]?, error:NSError?) -> Void in
		}

		delegate?.presentViewControllerForSettringView(shareVC)
	}

	func gotoAppStore() {
		UIApplication.sharedApplication().openURL(appStoreURL!)
	}
}

// MARK: - Notification

extension SettingView {

	func scheduleNotification(index: Int) {

		if index != 0 {

			let notificationSettings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
			let notificationSetting_Sound = UIUserNotificationSettings(forTypes: .Sound, categories: nil)
			UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
			UIApplication.sharedApplication().registerUserNotificationSettings(notificationSetting_Sound)

			var dueDate = NSDate()
			dueDate = NSDate(timeIntervalSinceNow: 20)

			let existingNOtification = oldNotificationForThisItem()
			if let notification = existingNOtification {
				UIApplication.sharedApplication().cancelLocalNotification(notification)
			}

			let localNotification = UILocalNotification()
			localNotification.fireDate = dueDate
			localNotification.timeZone = NSTimeZone.defaultTimeZone()
			localNotification.repeatInterval = .Minute
			localNotification.alertBody = "写故事时间到"
			localNotification.soundName = UILocalNotificationDefaultSoundName
			localNotification.userInfo = ["Index": index]

			UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
		}
	}

	func oldNotificationForThisItem() -> UILocalNotification? {
		let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
		if allNotifications?.count == 1 { return allNotifications![0] }
		return nil
	}
}

