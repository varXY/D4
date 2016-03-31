//
//  MyColor.swift
//  D4
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

enum Background {
	case point(Int, Int)

	var color: UIColor {
		switch self {
		case point(0, 0): return UIColor.colorWithValues(MyColor.D_0_0)
		case point(0, 1): return UIColor.colorWithValues(MyColor.D_0_1)
		case point(0, 2): return UIColor.colorWithValues(MyColor.D_0_2)
		case point(0, 3): return UIColor.colorWithValues(MyColor.D_0_3)
		case point(0, 4): return UIColor.colorWithValues(MyColor.D_0_4)

		case point(1, 0): return UIColor.colorWithValues(MyColor.D_1_0)
		case point(1, 1): return UIColor.colorWithValues(MyColor.D_1_1)
		case point(1, 2): return UIColor.colorWithValues(MyColor.D_1_2)
		case point(1, 3): return UIColor.colorWithValues(MyColor.D_1_3)
		case point(1, 4): return UIColor.colorWithValues(MyColor.D_1_4)

		case point(2, 0): return UIColor.colorWithValues(MyColor.D_2_0)
		case point(2, 1): return UIColor.colorWithValues(MyColor.D_2_1)
		case point(2, 2): return UIColor.colorWithValues(MyColor.D_2_2)
		case point(2, 3): return UIColor.colorWithValues(MyColor.D_2_3)
		case point(2, 4): return UIColor.colorWithValues(MyColor.D_2_4)

		case point(3, 0): return UIColor.colorWithValues(MyColor.D_3_0)
		case point(3, 1): return UIColor.colorWithValues(MyColor.D_3_1)
		case point(3, 2): return UIColor.colorWithValues(MyColor.D_3_2)
		case point(3, 3): return UIColor.colorWithValues(MyColor.D_3_3)
		case point(3, 4): return UIColor.colorWithValues(MyColor.D_3_4)

		case point(4, 0): return UIColor.colorWithValues(MyColor.D_4_0)
		case point(4, 1): return UIColor.colorWithValues(MyColor.D_4_1)
		case point(4, 2): return UIColor.colorWithValues(MyColor.D_4_2)
		case point(4, 3): return UIColor.colorWithValues(MyColor.D_4_3)
		case point(4, 4): return UIColor.colorWithValues(MyColor.D_4_4)

		case point(5, 0): return UIColor.colorWithValues(MyColor.D_5_0)
		case point(5, 1): return UIColor.colorWithValues(MyColor.D_5_1)
		case point(5, 2): return UIColor.colorWithValues(MyColor.D_5_2)
		case point(5, 3): return UIColor.colorWithValues(MyColor.D_5_3)
		case point(5, 4): return UIColor.colorWithValues(MyColor.D_5_4)

		default: return UIColor.whiteColor()
		}
	}

}

struct MyColor {

	static let D_0_0: [CGFloat] = [255, 255, 255, 1.0]
	static let D_0_1: [CGFloat] = [21, 41, 81, 1.0]
	static let D_0_2: [CGFloat] = [34, 60, 120, 1.0]
	static let D_0_3: [CGFloat] = [57, 101, 189, 1.0]
	static let D_0_4: [CGFloat] = [87, 150, 249, 1.0]


	static let D_1_0: [CGFloat] = [220, 221, 223, 1.0]
	static let D_1_1: [CGFloat] = [30, 52, 54, 1.0]
	static let D_1_2: [CGFloat] = [52, 92, 96, 1.0]
	static let D_1_3: [CGFloat] = [93, 165, 171, 1.0]
	static let D_1_4: [CGFloat] = [124, 217, 226, 1.0]

	static let D_2_0: [CGFloat] = [166, 169, 167, 1.0]
	static let D_2_1: [CGFloat] = [29, 50, 12, 1.0]
	static let D_2_2: [CGFloat] = [54, 93, 32, 1.0]
	static let D_2_3: [CGFloat] = [87, 138, 41, 1.0]
	static let D_2_4: [CGFloat] = [157, 218, 84, 1.0]

	static let D_3_0: [CGFloat] = [85, 88, 95, 1.0]
	static let D_3_1: [CGFloat] = [88, 58, 12, 1.0]
	static let D_3_2: [CGFloat] = [123, 85, 26, 1.0]
	static let D_3_3: [CGFloat] = [172, 127, 51, 1.0]
	static let D_3_4: [CGFloat] = [214, 163, 63, 1.0]

	static let D_4_0: [CGFloat] = [0, 0, 0, 1.0]
	static let D_4_1: [CGFloat] = [48, 3, 2, 1.0]
	static let D_4_2: [CGFloat] = [98, 16, 6, 1.0]
	static let D_4_3: [CGFloat] = [129, 30, 30, 1.0]
	static let D_4_4: [CGFloat] = [186, 89, 85, 1.0]

	static let D_5_0: [CGFloat] = [255, 255, 255, 1.0]
	static let D_5_1: [CGFloat] = [33, 28, 62, 1.0]
	static let D_5_2: [CGFloat] = [50, 47, 111, 1.0]
	static let D_5_3: [CGFloat] = [83, 72, 189, 1.0]
	static let D_5_4: [CGFloat] = [133, 128, 236, 1.0]

}
