//
//  WriteView+Rects.swift
//  D4
//
//  Created by 文川术 on 4/4/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

extension WriteView {

	var bigBlockHeight: CGFloat! {
		return (ScreenHeight - 100) / 3
	}

	var dotLength: CGFloat! {
		return 50
	}

	var bottomSignFrame: CGRect {
		return CGRectMake(0, ScreenHeight - 20, ScreenWidth, 20)
	}

	func blockFrame(index: CGFloat) -> CGRect {
		let addend = index == 0 ? 0 : smallBlockHeight
		let factor = index == 0 ? 0 : index - 1
		let y = addend + bigBlockHeight * factor
		let height = (index == 0 || index == 4) ? smallBlockHeight : bigBlockHeight
		return CGRectMake(0, y, ScreenWidth, height)
	}

	func activateBlockFrame(index: CGFloat) -> CGRect {
		var rect = blockFrame(index)
		rect.size.width -= 100
		return rect
	}

	func dotFrame(index: CGFloat) -> CGRect {
		let x = ScreenWidth - 50
		let y = bigBlockHeight * index
		return CGRectMake(x, y, dotLength, dotLength)
	}
}