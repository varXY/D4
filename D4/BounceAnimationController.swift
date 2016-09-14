//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by 文川术 on 15/8/15.
//  Copyright (c) 2015年 xiaoyao. All rights reserved.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.45
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
			if let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
				let duration = transitionDuration(using: transitionContext)

				toView.frame = transitionContext.finalFrame(for: toViewController)
				transitionContext.containerView.addSubview(toView)

				toView.alpha = 0.0
				toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

				UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {
					toView.alpha = 1.0
					toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
					}, completion: { (finished) in
						transitionContext.completeTransition(finished)
				})

			}
		}
	}
}
