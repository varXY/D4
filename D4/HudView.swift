//
//  HudView.swift
//  D4
//
//  Created by 文川术 on 4/17/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

class HudView: UIView {
	var text = ""
	var nightStyle = false

	class func hudInView(_ view: UIView, animated: Bool) -> HudView {
		let hudView = HudView(frame: view.bounds)
		hudView.isOpaque = false

		view.addSubview(hudView)
		view.isUserInteractionEnabled = false
		hudView.showAnimated(animated)

		delay(seconds: 0.8) {
			hudView.disappear(animated, done: {
				view.isUserInteractionEnabled = true
			})
		}

		return hudView
	}

	override func draw(_ rect: CGRect) {
		let boxWidth: CGFloat = 130
		let boxHeight: CGFloat = 130

		let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2), width: boxWidth, height: boxHeight)
		let color = nightStyle ? UIColor(white: 0.2, alpha: 0.9) : UIColor(white: 1.0, alpha: 0.9)
		let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 20)
		color.setFill()
		roundedRect.fill()

		let textColor = nightStyle ? UIColor.white : UIColor.black
		let attribs = [NSFontAttributeName: UIFont.systemFont(ofSize: 22.0), NSForegroundColorAttributeName: textColor]
		let textSize = text.size(attributes: attribs)
		let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: bounds.size.height / 2 - round(textSize.height / 2))
		text.draw(at: textPoint, withAttributes: attribs)
	}

	func showAnimated(_ animated: Bool) {
		if animated {
			alpha = 0
			transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
			UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
				self.alpha = 1
				self.transform = CGAffineTransform.identity
				}, completion: nil)
		}
	}

	func disappear(_ animated: Bool, done: @escaping (() -> ())) {
		if animated {
			UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
				self.alpha = 0
				self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
				}, completion: { (_) -> Void in
					done()
			})
		}
	}
}

