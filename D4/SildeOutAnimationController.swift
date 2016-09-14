//
//  SildeOutAnimationController.swift
//  StoreSearch
//
//  Created by 文川术 on 15/8/15.
//  Copyright (c) 2015年 xiaoyao. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.4
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

		if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
			fromView.backgroundColor = UIColor.clear

			UIView.perform(.delete, on: [], options: [], animations: {
				fromView.alpha = 0.0
				fromView.frame.origin.x += ScreenWidth
				}, completion: { (finished) in
					transitionContext.completeTransition(finished)
			})

		}
	}
}
