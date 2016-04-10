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

	func blockFrame(index: Int) -> CGRect {
		let addend = index == 0 ? 0 : smallBlockHeight
		let factor = index == 0 ? 0 : CGFloat(index - 1)
		let y = addend + bigBlockHeight * factor
		let height = (index == 0 || index == 4) ? smallBlockHeight : bigBlockHeight
		return CGRectMake(0, y, ScreenWidth, height)
	}

	func activateBlockFrame(index: Int) -> CGRect {

		let smallBlockheight_1: CGFloat = 70
		let bigBlockHeight_1 = (ScreenHeight - smallBlockheight_1 * 2) / 3

		let addend = index == 0 ? 0 : smallBlockheight_1
		let factor = index == 0 ? 0 : CGFloat(index - 1)
		let y = addend + bigBlockHeight_1 * factor
		let height = (index == 0 || index == 4) ? smallBlockheight_1 : bigBlockHeight_1
		return CGRectMake(0, y, ScreenWidth - 100, height)

	}

	func dotFrame(index: Int) -> CGRect {
		let x = ScreenWidth - 50
		let y = bigBlockHeight * CGFloat(index)
		return CGRectMake(x, y, dotLength, dotLength)
	}
}