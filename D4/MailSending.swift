//
//  EMail.swift
//  D4
//
//  Created by 文川术 on 4/17/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit
import MessageUI

protocol MailSending: UserDefaults {
	func sendSupportEmail()
}

extension MailSending where Self: UIViewController {

	func sendSupportEmail() {
		let parts = UIDevice.currentDevice().identifierForVendor?.UUIDString.componentsSeparatedByString("-")
		let index = random() % parts!.count
		let code = "\n\n\n" + "用户_" + "\(index)" + parts![index] + "\n"

		let firstStory = getAuthor() != "" ? "第一个故事_" + getAuthor().componentsSeparatedByString("&")[0] + "\n\n" : ""

		let appInfoDict = NSBundle.mainBundle().infoDictionary
		let appName = appInfoDict!["CFBundleName"] as! String
		let appVersion = appInfoDict!["CFBundleShortVersionString"] as! String
		let deviceName = UIDevice.currentDevice().model
		let iOSVersion = UIDevice.currentDevice().systemVersion
		let deviceInfo = appName + "_" + appVersion + "\n" + deviceName + "_" + iOSVersion

		let messageBody = code + firstStory + deviceInfo

		if MFMailComposeViewController.canSendMail() {
			let controller = MFMailComposeViewController()
			controller.mailComposeDelegate = self
			controller.setSubject("天的故事")
			controller.setMessageBody(messageBody, isHTML: false)
			controller.setToRecipients(["pmlcfwcs@foxmail.com"])
			presentViewController(controller, animated: true, completion: nil)
		} else {
			let alertController = UIAlertController(title: "无法发送邮件", message: "你的设备无法发送邮件，请检测你的设置。", preferredStyle: .Alert)
			let action = UIAlertAction(title: "确定", style: .Default, handler: nil)
			alertController.addAction(action)
			presentViewController(alertController, animated: true, completion: nil)
		}
	}

}

extension UIViewController: MFMailComposeViewControllerDelegate {

	public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
}



