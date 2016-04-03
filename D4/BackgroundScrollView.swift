//
//  BackgroundScrollView.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

enum ScrollType {
	case Left, Right
}

protocol BackgroundScrollViewDelegate: class {
	func didScrollLeftOrRight(scrollType: ScrollType)
}

class BackgroundScrollView: UIScrollView {

	var triggeredLeft = false
	var triggeredRight = false

	weak var movementDelegate: BackgroundScrollViewDelegate?

	init() {
		super.init(frame: ScreenBounds)
		backgroundColor = UIColor.clearColor()
		contentSize = CGSize(width: ScreenWidth, height: 0)
		alwaysBounceHorizontal = true
		directionalLockEnabled = true
		delegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension BackgroundScrollView: UIScrollViewDelegate {

	func scrollViewDidScroll(scrollView: UIScrollView) {
		if self.contentOffset.x < -TriggerDistance {
			triggeredLeft = true
			triggeredRight = false
		} else if self.contentOffset.x > TriggerDistance {
			triggeredLeft = false
			triggeredRight = true
		}
	}

	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		if triggeredLeft { movementDelegate?.didScrollLeftOrRight(.Left) }
		if triggeredRight { movementDelegate?.didScrollLeftOrRight(.Right) }
	}

}