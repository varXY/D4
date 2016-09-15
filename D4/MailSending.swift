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
		let parts = UIDevice.current.identifierForVendor?.uuidString.components(separatedBy: "-")
		let index = Int(arc4random_uniform(UInt32(parts!.count)))
		let code = "\n\n\n" + "用户_" + "\(index)" + parts![index] + "\n"

		let firstStory = getAuthor() != "" ? "第一个故事_" + getAuthor().components(separatedBy: "&")[0] + "\n\n" : ""

		let appInfoDict = Bundle.main.infoDictionary
		let appName = appInfoDict!["CFBundleName"] as! String
		let appVersion = appInfoDict!["CFBundleShortVersionString"] as! String
		let deviceName = UIDevice.current.model
		let iOSVersion = UIDevice.current.systemVersion
		let deviceInfo = appName + "_" + appVersion + "\n" + deviceName + "_" + iOSVersion

		let messageBody = code + firstStory + deviceInfo

		if MFMailComposeViewController.canSendMail() {
			let controller = MFMailComposeViewController()
			controller.mailComposeDelegate = self
			controller.setSubject("反馈的一天")
			controller.setMessageBody(messageBody, isHTML: false)
			controller.setToRecipients(["pmlcfwcs@foxmail.com"])
			present(controller, animated: true, completion: nil)
		} else {
			let alertController = UIAlertController(title: "无法发送邮件", message: "你的设备无法发送邮件，请检测你的设置。", preferredStyle: .alert)
			let action = UIAlertAction(title: "确定", style: .default, handler: nil)
			alertController.addAction(action)
			present(alertController, animated: true, completion: nil)
		}
	}

}

extension UIViewController: MFMailComposeViewControllerDelegate {

	public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
}



