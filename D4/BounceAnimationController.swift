//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by 文川术 on 15/8/15.
//  Copyright (c) 2015年 xiaoyao. All rights reserved.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 0.4
	}

	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

		if let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
			if let toView = transitionContext.viewForKey(UITransitionContextToViewKey) {

				toView.frame = transitionContext.finalFrameForViewController(toViewController)

				transitionContext.containerView()!.addSubview(toView)
				toView.alpha = 0.0
				toView.transform = CGAffineTransformMakeScale(0.7, 0.7)

				UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {

					toView.center = CGPoint(x: ScreenWidth / 2, y: ScreenHeight / 2)
					toView.alpha = 1.0
					toView.transform = CGAffineTransformMakeScale(1.0, 1.0)

					}, completion: { (finished) in

						transitionContext.completeTransition(finished)

				})

			}
		}
	}
}
