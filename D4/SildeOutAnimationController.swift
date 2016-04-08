//
//  SildeOutAnimationController.swift
//  StoreSearch
//
//  Created by 文川术 on 15/8/15.
//  Copyright (c) 2015年 xiaoyao. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 0.7
	}

	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

		if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) {
			let duration = transitionDuration(transitionContext)

			if let toView = transitionContext.viewForKey(UITransitionContextToViewKey) {
				UIApplication.sharedApplication().keyWindow?.addSubview(toView)
				toView.alpha = 0.5

				UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {
//					fromView.transform = CGAffineTransformMakeScale(0.7, 0.7)
					fromView.alpha = 0.0
					toView.alpha = 1.0
					}, completion: { (finished) in
						transitionContext.completeTransition(finished)
				})

			}


		}
	}
}
