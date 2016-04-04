//
//  Rect.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

struct Rect {
	let writeViewBlockHeight = (ScreenHeight - 20 - 20 - 100) / 3
	let colorDotWidth: CGFloat = 50

	func writeViewBlockFrame(index: Int) -> CGRect {
		let F_index = CGFloat(index)
		let addition = index == 0 ? 0 : smallBlockHeight
		let y = addition + writeViewBlockHeight * (F_index - 1)
		let height = (index != 0 && index != 4) ? writeViewBlockHeight : 50
		return CGRectMake(0, y, ScreenWidth, height)
	}

	func colorSelectingViewFrame(index: Int) -> CGRect {
		let x = ScreenWidth - 100
		let y_0 = smallBlockHeight + writeViewBlockHeight / 2 - colorDotWidth / 2
		let y = index != 3 ? y_0 + writeViewBlockHeight * CGFloat(index) : 0
		return CGRectMake(x, y, colorDotWidth, colorDotWidth)
	}
}