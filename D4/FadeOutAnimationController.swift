//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by 文川术 on 15/8/16.
//  Copyright (c) 2015年 xiaoyao. All rights reserved.
//

import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.4
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
			let duration = transitionDuration(using: transitionContext)

			UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {
				fromView.alpha = 0
			}, completion: { (finished) -> Void in
				transitionContext.completeTransition(finished)
			})
		}
	}
}
