//
//  MyColor.swift
//  D4
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

let colorCode = [0, 10, 20, 30, 40,
                 1, 11, 21, 31, 41,
                 2, 12, 22, 32, 42,
                 3, 13, 23, 33, 43,
                 4, 14, 24, 34, 44,
                 5, 15, 25, 35, 45]

func fiveRandomColorCodes() -> [Int] {
	let indexes = getRandomNumbers(4, lessThan: colorCode.count)
	var colorCodes = indexes.map({ colorCode[$0] })
	colorCodes.append(colorCodes[0])
	return colorCodes
}

func randomColorCode() -> Int {
	let index = random() % colorCode.count
	return colorCode[index]
}

func randomColorCodeForPrimaticButton() -> Int {
	let codes = [10, 20, 30, 40,
	             1, 11, 21, 31, 41,
	             2, 12, 22, 32, 42,
	             3, 13, 23, 33, 43,
	             4, 14, 24, 34, 44,
	             15, 25, 35, 45]
	return codes[random() % codes.count]
}

func randomBTColors() -> [UIColor] {
	let index = getRandomNumbers(1, lessThan: colorCode.count)[0]
	return MyColor.code(colorCode[index]).BTColors
}

enum MyColor {
	case code(Int)

	var BTColors: [UIColor] {
		var colorValue = [CGFloat]()
		var black = false

		switch  self {
		case .code(colorCode[0]): colorValue = [255, 255, 255, 1.0]; black = true  // 0: 白
		case .code(colorCode[1]): colorValue = [66, 120, 245, 1.0]     // 10： 深蓝1
		case .code(colorCode[2]): colorValue = [0, 150, 255, 1.0]    // 20： 2
		case .code(colorCode[3]): colorValue = [0, 170, 220, 1.0]   //30： 3
		case .code(colorCode[4]): colorValue = [0, 253, 255, 1.0]; black = true   //40： 浅蓝4

		case .code(colorCode[5]): colorValue = [242, 234, 211, 1.0]; black = true  //1： 浅灰
		case .code(colorCode[6]): colorValue = [0, 122, 170, 1.0]     //11： 深青1
		case .code(colorCode[7]): colorValue = [58, 160, 174, 1.0]     //21： 2
		case .code(colorCode[8]): colorValue = [127, 199, 213, 1.0]   //31： 3
		case .code(colorCode[9]): colorValue = [181, 226, 219, 1.0]; black = true  //41： 浅青4

		case .code(colorCode[10]): colorValue = [214, 214, 214, 1.0]; black = true //2： 灰
		case .code(colorCode[11]): colorValue = [33, 108, 12, 1.0]    //12： 深绿1
		case .code(colorCode[12]): colorValue = [0, 209, 14, 1.0]    //22： 2
		case .code(colorCode[13]): colorValue = [103, 227, 56, 1.0]; black = true   //32： 3
		case .code(colorCode[14]): colorValue = [100, 250, 128, 1.0]; black = true  //42： 浅绿4

		case .code(colorCode[15]): colorValue = [169, 169, 169, 1.0]  //3： 深灰
		case .code(colorCode[16]): colorValue = [254, 94, 4, 1.0]    //13： 深黄1
		case .code(colorCode[17]): colorValue = [255, 147, 0, 1.0]    //23： 2
		case .code(colorCode[18]): colorValue = [254, 204, 43, 1.0]; black = true  //33： 3
		case .code(colorCode[19]): colorValue = [255, 251, 0, 1.0]; black = true  //43： 浅黄4

		case .code(colorCode[20]): colorValue = [121, 121, 121, 1.0]       //4： 浅黑
		case .code(colorCode[21]): colorValue = [248, 73, 54, 1.0]      //14： 深红1
		case .code(colorCode[22]): colorValue = [252, 101, 103, 1.0]     //24： 2
		case .code(colorCode[23]): colorValue = [245, 134, 167, 1.0]   //34： 3
		case .code(colorCode[24]): colorValue = [255, 172, 169, 1.0]; black = true   //44： 浅红4

		case .code(colorCode[25]): colorValue = [66, 66, 66, 1.0] //5： 黑
		case .code(colorCode[26]): colorValue = [83, 27, 147, 1.0]	 //15： 深紫1
		case .code(colorCode[27]): colorValue = [158, 93, 215, 1.0]   //25： 2
		case .code(colorCode[28]): colorValue = [136, 129, 240, 1.0]   //35： 3
		case .code(colorCode[29]): colorValue = [132, 167, 233, 1.0]; black = true //45： 浅紫4

		default: colorValue = [66, 66, 66, 1.0]
		}

		let backgroundColor = UIColor.colorWithValues(colorValue)
		let textColor = black ? UIColor.blackColor() : UIColor.whiteColor()

		return [backgroundColor, textColor]
	}
}

// 0519 第四版
// case .code(colorCode[5]): colorValue = [235, 235, 235, 1.0]; black = true  //1： 浅灰

// case .code(colorCode[8]): colorValue = [17, 219, 227, 1.0]; black = true   //31： 3
// case .code(colorCode[9]): colorValue = [115, 252, 214, 1.0]; black = true  //41： 浅青4

// case .code(colorCode[21]): colorValue = [255, 38, 0, 1.0]      //14： 深红1

// 0412 第三版
//case .code(colorCode[11]): colorValue = [128, 180, 46, 1.0]    //12： 深绿1

//case .code(colorCode[13]): colorValue = [166, 218, 84, 1.0]   //32： 3

// 0408 第二版颜色
//case .code(colorCode[0]): colorValue = [255, 255, 255, 1.0]  // 0: 白
//case .code(colorCode[1]): colorValue = [66, 120, 245, 1.0]     // 10： 深蓝1
//case .code(colorCode[2]): colorValue = [0, 150, 255, 1.0]    // 20： 2
//case .code(colorCode[3]): colorValue = [118, 214, 255, 1.0]   //30： 3
//case .code(colorCode[4]): colorValue = [0, 253, 255, 1.0]   //40： 浅蓝4
//
//case .code(colorCode[5]): colorValue = [235, 235, 235, 1.0]  //1： 浅灰
//case .code(colorCode[6]): colorValue = [0, 122, 170, 1.0]     //11： 深青1
//case .code(colorCode[7]): colorValue = [0, 213, 255, 1.0]     //21： 2
//case .code(colorCode[8]): colorValue = [17, 219, 227, 1.0]   //31： 3
//case .code(colorCode[9]): colorValue = [115, 252, 214, 1.0]  //41： 浅青4
//
//case .code(colorCode[10]): colorValue = [214, 214, 214, 1.0] //2： 灰
//case .code(colorCode[11]): colorValue = [0, 141, 81, 1.0]    //12： 深绿1
//case .code(colorCode[12]): colorValue = [0, 249, 0, 1.0]    //22： 2
//case .code(colorCode[13]): colorValue = [0, 250, 146, 1.0]   //32： 3
//case .code(colorCode[14]): colorValue = [115, 250, 121, 1.0]  //42： 浅绿4
//
//case .code(colorCode[15]): colorValue = [169, 169, 169, 1.0]    //3： 深灰
//case .code(colorCode[16]): colorValue = [255, 147, 0, 1.0]    //13： 深黄1
//case .code(colorCode[17]): colorValue = [255, 212, 121, 1.0]   //23： 2
//case .code(colorCode[18]): colorValue = [255, 251, 0, 1.0]  //33： 3
//case .code(colorCode[19]): colorValue = [255, 252, 121, 1.0]  //43： 浅黄4
//
//case .code(colorCode[20]): colorValue = [121, 121, 121, 1.0]       //4： 黑
//case .code(colorCode[21]): colorValue = [255, 38, 0, 1.0]      //14： 深红1
//case .code(colorCode[22]): colorValue = [255, 47, 146, 1.0]     //24： 2
//case .code(colorCode[23]): colorValue = [255, 172, 169, 1.0]   //34： 3
//case .code(colorCode[24]): colorValue = [254, 193, 208, 1.0]   //44： 浅红4
//
//case .code(colorCode[25]): colorValue = [66, 66, 66, 1.0] //5： 自定义
//case .code(colorCode[26]): colorValue = [83, 27, 147, 1.0]	 //15： 深紫1
//case .code(colorCode[27]): colorValue = [158, 93, 215, 1.0]   //25： 2
//case .code(colorCode[28]): colorValue = [136, 129, 240, 1.0]   //35： 3
//case .code(colorCode[29]): colorValue = [132, 167, 233, 1.0] //45： 浅紫4




// 第一版颜色：完全依照keyNote的选色版。

//		case .code(colorCode[0]): colorValue = [255, 255, 255, 1.0]  // 白
//		case .code(colorCode[1]): colorValue = [21, 41, 81, 1.0]     // 深蓝1
//		case .code(colorCode[2]): colorValue = [34, 60, 120, 1.0]    // 2
//		case .code(colorCode[3]): colorValue = [57, 101, 189, 1.0]   // 3
//		case .code(colorCode[4]): colorValue = [87, 150, 249, 1.0]   // 浅蓝4
//
//		case .code(colorCode[5]): colorValue = [220, 221, 223, 1.0]  // 浅灰
//		case .code(colorCode[6]): colorValue = [30, 52, 54, 1.0]     // 深青1
//		case .code(colorCode[7]): colorValue = [52, 92, 96, 1.0]     // 2
//		case .code(colorCode[8]): colorValue = [93, 165, 171, 1.0]   // 3
//		case .code(colorCode[9]): colorValue = [124, 217, 226, 1.0]  // 浅青4
//
//		case .code(colorCode[10]): colorValue = [166, 169, 167, 1.0] // 灰
//		case .code(colorCode[11]): colorValue = [29, 50, 12, 1.0]    // 深绿1
//		case .code(colorCode[12]): colorValue = [54, 93, 32, 1.0]    // 2
//		case .code(colorCode[13]): colorValue = [87, 138, 41, 1.0]   // 3
//		case .code(colorCode[14]): colorValue = [157, 218, 84, 1.0]  // 浅绿4
//
//		case .code(colorCode[15]): colorValue = [85, 88, 95, 1.0]    // 深灰
//		case .code(colorCode[16]): colorValue = [88, 58, 12, 1.0]    // 深黄1
//		case .code(colorCode[17]): colorValue = [123, 85, 26, 1.0]   // 2
//		case .code(colorCode[18]): colorValue = [172, 127, 51, 1.0]  // 3
//		case .code(colorCode[19]): colorValue = [214, 163, 63, 1.0]  // 浅黄4
//
//		case .code(colorCode[20]): colorValue = [0, 0, 0, 1.0]       // 黑
//		case .code(colorCode[21]): colorValue = [48, 3, 2, 1.0]      // 深红1
//		case .code(colorCode[22]): colorValue = [98, 16, 6, 1.0]     // 2
//		case .code(colorCode[23]): colorValue = [129, 30, 30, 1.0]   // 3
//		case .code(colorCode[24]): colorValue = [186, 89, 85, 1.0]   // 浅红4
//
//		case .code(colorCode[25]): colorValue = [255, 255, 255, 1.0] // 自定义
//		case .code(colorCode[26]): colorValue = [33, 28, 62, 1.0]	 // 深紫1
//		case .code(colorCode[27]): colorValue = [50, 47, 111, 1.0]   // 2
//		case .code(colorCode[28]): colorValue = [83, 72, 189, 1.0]   // 3
//		case .code(colorCode[29]): colorValue = [133, 128, 236, 1.0] // 浅紫4











