//
//  MyColor.swift
//  D4
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

let colorCode = [0, 10, 20, 30, 40,
                 1, 11, 21, 31, 41,
                 2, 12, 22, 32, 42,
                 3, 13, 23, 33, 43,
                 4, 14, 24, 34, 44,
                 5, 15, 25, 35, 45]

func fourRandomColorCode() -> [Int] {
	let indexes = getRandomNumbers(4, lessThan: colorCode.count)
	var colorCodes = [Int]()
	for i in indexes {
		colorCodes.append(colorCode[i])
	}
	return colorCodes

}

func randomColorCode() -> Int {
	let index = getRandomNumbers(1, lessThan: colorCode.count)[0]
	return colorCode[index]
}

func randomBTColors() -> [UIColor] {
	let index = getRandomNumbers(1, lessThan: colorCode.count)[0]
	return MyColor.code(colorCode[index]).BTColors
}

enum MyColor {
	case code(Int)

	var BTColors: [UIColor] {
		var colorValue = [CGFloat]()
		switch  self {
		case .code(colorCode[0]): colorValue = [255, 255, 255, 1.0]  // 白
		case .code(colorCode[1]): colorValue = [21, 41, 81, 1.0]     // 深蓝1
		case .code(colorCode[2]): colorValue = [34, 60, 120, 1.0]    // 2
		case .code(colorCode[3]): colorValue = [57, 101, 189, 1.0]   // 3
		case .code(colorCode[4]): colorValue = [87, 150, 249, 1.0]   // 浅蓝4

		case .code(colorCode[5]): colorValue = [220, 221, 223, 1.0]  // 浅灰
		case .code(colorCode[6]): colorValue = [30, 52, 54, 1.0]     // 深青1
		case .code(colorCode[7]): colorValue = [52, 92, 96, 1.0]     // 2
		case .code(colorCode[8]): colorValue = [93, 165, 171, 1.0]   // 3
		case .code(colorCode[9]): colorValue = [124, 217, 226, 1.0]  // 浅青4

		case .code(colorCode[10]): colorValue = [166, 169, 167, 1.0] // 灰
		case .code(colorCode[11]): colorValue = [29, 50, 12, 1.0]    // 深绿1
		case .code(colorCode[12]): colorValue = [54, 93, 32, 1.0]    // 2
		case .code(colorCode[13]): colorValue = [87, 138, 41, 1.0]   // 3
		case .code(colorCode[14]): colorValue = [157, 218, 84, 1.0]  // 浅绿4

		case .code(colorCode[15]): colorValue = [85, 88, 95, 1.0]    // 深灰
		case .code(colorCode[16]): colorValue = [88, 58, 12, 1.0]    // 深黄1
		case .code(colorCode[17]): colorValue = [123, 85, 26, 1.0]   // 2
		case .code(colorCode[18]): colorValue = [172, 127, 51, 1.0]  // 3
		case .code(colorCode[19]): colorValue = [214, 163, 63, 1.0]  // 浅黄4

		case .code(colorCode[20]): colorValue = [0, 0, 0, 1.0]       // 黑
		case .code(colorCode[21]): colorValue = [48, 3, 2, 1.0]      // 深红1
		case .code(colorCode[22]): colorValue = [98, 16, 6, 1.0]     // 2
		case .code(colorCode[23]): colorValue = [129, 30, 30, 1.0]   // 3
		case .code(colorCode[24]): colorValue = [186, 89, 85, 1.0]   // 浅红4

		case .code(colorCode[25]): colorValue = [255, 255, 255, 1.0] // 自定义
		case .code(colorCode[26]): colorValue = [33, 28, 62, 1.0]	 // 深紫1
		case .code(colorCode[27]): colorValue = [50, 47, 111, 1.0]   // 2
		case .code(colorCode[28]): colorValue = [83, 72, 189, 1.0]   // 3
		case .code(colorCode[29]): colorValue = [133, 128, 236, 1.0] // 浅紫4

		default: colorValue = [0, 0, 0, 0]
		}

		let backgroundColor = UIColor.colorWithValues(colorValue)

		let black = colorValue[0] + colorValue[1] + colorValue[2] > 360
		let textColor = black ? UIColor.blackColor() : UIColor.whiteColor()

		return [backgroundColor, textColor]
	}
}


