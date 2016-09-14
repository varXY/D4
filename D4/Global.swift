//
//  SizeClass.swift
//  Q2
//
//  Created by 文川术 on 15/9/13.
//  Copyright (c) 2015年 xiaoyao. All rights reserved.
//

import UIKit

// 屏幕尺寸信息
let ScreenBounds = UIScreen.mainScreen().bounds
let ScreenWidth = ScreenBounds.width
let ScreenHeight = ScreenBounds.height
let StatusBarHeight = UIApplication.sharedApplication().statusBarFrame.height

let smallBlockHeight: CGFloat = 50
let TriggerDistance: CGFloat = 50

let globalRadius: CGFloat = ScreenHeight * 0.007


// URL
let jianShuURL = NSURL(string: "http://www.jianshu.com/users/83ddcf71e52c")
let appStoreURL = NSURL(string: "https://itunes.apple.com/us/app/tian-gu-shi-yi-ge-gu-shi-yu/id1104752673?mt=8")
// https://appsto.re/us/Hat2bb.i


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
func delay(seconds seconds: Double, completion: () -> ()) {
	let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))

	dispatch_after(popTime, dispatch_get_main_queue()) {
		completion()
	}
}

// 自定义文字样式
func textWithStyle(text: String, color: UIColor, font: UIFont) -> NSMutableAttributedString {
    let attributedText = NSMutableAttributedString(string: text)
    attributedText.addAttributes(textAttributes(color, font: font), range: NSMakeRange(0, attributedText.length))
    return attributedText
}

func textAttributes(color: UIColor, font: UIFont) -> [String: AnyObject] {
    let textAttributes = [
        NSParagraphStyleAttributeName: textStyle(),
        NSForegroundColorAttributeName: color,
        NSFontAttributeName: font
    ]
    
    return textAttributes
}

func textStyle() -> NSMutableParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.lineSpacing = 3
    style.alignment = NSTextAlignment.Center
    return style
}


