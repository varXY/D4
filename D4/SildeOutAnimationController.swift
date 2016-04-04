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
		return 0.3
	}

	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

		if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) {
			let duration = transitionDuration(transitionContext)
			fromView.alpha = 1.0

//			let containerView = transitionContext.containerView()

			if let toView = transitionContext.viewForKey(UITransitionContextToViewKey) {
				UIApplication.sharedApplication().keyWindow?.addSubview(toView)
				toView.alpha = 0.5
				UIView.animateWithDuration(duration, animations: { () -> Void in
					//				fromView.center.y -= containerView!.bounds.size.height
					toView.alpha = 1.0
					fromView.alpha = 0.0
					if let subView = fromView.viewWithTag(999) {
						subView.alpha = 0.0
						subView.frame.origin.y += 200
						subView.transform = CGAffineTransformMakeScale(0.5, 0.5)
					}
					//				fromView.transform = CGAffineTransformMakeScale(0.5, 0.5)
					//				fromView.transform = CGAffineTransformMakeRotation(14.6)
					}, completion: { (finished) -> Void in
						transitionContext.completeTransition(finished)
						
				})

			}


		}
	}
}
