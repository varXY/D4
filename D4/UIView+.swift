//
//  UIView+.swift
//  P3
//
//  Created by 文川术 on 2/17/16.
//  Copyright © 2016 myname. All rights reserved.
//

import Foundation
import UIKit

enum AnimationType {
	case Appear, Disappear, Touched, IsRightAnswer, Bigger, BecomeVisble, Other
}

extension UIView {

	// 加动画
	func animateWithType(animationType: AnimationType, delay: Double, distance: CGFloat) {

		switch animationType {
		case .BecomeVisble:
			self.alpha = 0.0

			UIView.animateWithDuration(0.5, delay: delay, options: [], animations: { () -> Void in
				self.alpha = 1.0
				}, completion: nil)

		case .Appear:
			self.alpha = 0.0
			self.frame.origin.y += distance

			UIView.animateWithDuration(0.5, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: [], animations: { () -> Void in
				self.alpha = 1.0
				self.frame.origin.y -= distance
				}, completion: nil)

		case .Disappear:
			UIView.animateWithDuration(0.5, delay: delay, options: [], animations: { () -> Void in
				self.alpha = 0.0
				}, completion: nil)

			
		default:
			break
		}
	}

	// 加边框
	func addBorder(borderColor borderColor: UIColor, width: CGFloat) {
		self.layer.borderColor = borderColor.CGColor
		self.layer.borderWidth = width
	}

}