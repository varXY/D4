//
//  SizeClass.swift
//  Q2
//
//  Created by 文川术 on 15/9/13.
//  Copyright (c) 2015年 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

// 屏幕尺寸信息
let ScreenBounds = UIScreen.mainScreen().bounds
let ScreenWidth = ScreenBounds.width
let ScreenHeight = ScreenBounds.height
let StatusBarHeight = UIApplication.sharedApplication().statusBarFrame.height

let smallBlockHeight: CGFloat = 50
let TriggerDistance: CGFloat = 50

// 日期和数字格式转换
let dateFormatter: NSDateFormatter = {
	let formatter = NSDateFormatter()
	formatter.dateFormat = "dd/MM/yy, HH:mm"
	return formatter
	}()

var priceFormatter: NSNumberFormatter = {
	let pf = NSNumberFormatter()
	pf.formatterBehavior = .Behavior10_4
	pf.numberStyle = .CurrencyStyle
	return pf
}()

// 获取不重复随机数
func getRandomNumbers(amount: Int, lessThan: Int) -> [Int] {
	var result = [Int]()

	if lessThan <= 1 {
		result = [0]
	} else {
		repeat {
			let range = UInt32(lessThan)
			let number = Int(arc4random_uniform(range))
			if let sameAtIndex = result.indexOf(number) {
				result.removeAtIndex(sameAtIndex)
			}
			result.append(number)
		} while result.count < amount
	}

	return result
}


// 延迟执行
func delay(seconds seconds: Double, completion:()->()) {
	let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))

	dispatch_after(popTime, dispatch_get_main_queue()) {
		completion()
	}

}

// 百度坐标转换成高德坐标
func baiduToGaoDe(location: (Double, Double)) -> (Double, Double) {

	var returnLocation: (Double, Double) = (0.0, 0.0)
	let x_pi = 3.14159265358979324 * 3000.0 / 180.0

	let x = location.0 - 0.0065
	let y = location.1 - 0.006
	let z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi)
	let theta = atan2(y, x) - 0.000003 * cos(x * x_pi)

	returnLocation.0 = z * cos(theta)
	returnLocation.1 = z * sin(theta)

	return returnLocation
}

// 为AlertUser占位
func doNoThing() {

}

