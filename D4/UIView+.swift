//
//  UIView+.swift
//  P3
//
//  Created by 文川术 on 2/17/16.
//  Copyright © 2016 myname. All rights reserved.
//

import UIKit

enum AnimationType {
	case appear, disappear, touched, isRightAnswer, bigger, becomeVisble, other
}

extension UIView {

	// 加动画
	func animateWithType(_ animationType: AnimationType, delay: Double, distance: CGFloat) {

		switch animationType {
		case .becomeVisble:
			self.alpha = 0.0

			UIView.animate(withDuration: 0.5, delay: delay, options: [], animations: { () -> Void in
				self.alpha = 0.6
				}, completion: nil)

		case .appear:
			self.alpha = 0.0
			self.frame.origin.y += distance

			UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: [], animations: { () -> Void in
				self.alpha = 1.0
				self.frame.origin.y -= distance
				}, completion: nil)

		case .disappear:
			UIView.animate(withDuration: 0.5, delay: delay, options: [], animations: { () -> Void in
				self.alpha = 0.0
				}, completion: nil)

			
		default:
			break
		}
	}

	func inOutAnimate(_ distance: CGFloat, toAlpha: CGFloat) {
	}

	// 加边框
	func addBorder(borderColor: UIColor, width: CGFloat) {
		self.layer.borderColor = borderColor.cgColor
		self.layer.borderWidth = width
	}

}
