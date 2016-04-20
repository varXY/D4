//
//  InputView.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

class SettingView: UIView {

	var labels: [UILabel]!
	var pointerImageViews: [UIImageView]!

	var nightStyle = false {
		didSet {
			changeColorBaseOnNightStyle(nightStyle)
		}
	}

	init() {
		super.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
		backgroundColor = UIColor.whiteColor()
		layer.cornerRadius = globalRadius
		clipsToBounds = true
		exclusiveTouch = true

		let frames = [CGRectMake(0, 30, ScreenWidth, (ScreenHeight - 60) / 2 - 30), CGRectMake(0, ((ScreenHeight - 60) / 2) + 60, ScreenWidth, (ScreenHeight - 60) / 2 - 30)]

		labels = frames.map({ UILabel(frame: $0) })
		labels.forEach({
			$0.textColor = UIColor.blackColor()
			$0.textAlignment = .Center
			$0.numberOfLines = 0
			let index = labels.indexOf($0)!
			$0.attributedText = attributedStrings(false)[index]
			$0.adjustsFontSizeToFitWidth = true
			addSubview($0)
		})

		let iconView = UIImageView(image: UIImage(named: "Icon"))
		iconView.center = center
		iconView.layer.cornerRadius = iconView.frame.width / 2
		iconView.clipsToBounds = true
		addSubview(iconView)

		let pointer = Pointer()
		pointerImageViews = [pointer.imageView(.Up), pointer.imageView(.Down), pointer.imageView(.Left), pointer.imageView(.Right)]
		pointerImageViews.forEach({
			$0.transform = CGAffineTransformRotate($0.transform, CGFloat(180 * M_PI / 180))
			$0.transform = CGAffineTransformScale($0.transform, 0.7, 0.7)
			$0.tintColor = MyColor.code(randomColorCode()).BTColors[0]
			addSubview($0)
		})

	}

	func changeColorBaseOnNightStyle(nightStyle: Bool) {
		backgroundColor = nightStyle ? MyColor.code(5).BTColors[0] : UIColor.whiteColor()
		randomColorForPointerView()
		labels.forEach({
			$0.attributedText = attributedStrings(nightStyle)[labels.indexOf($0)!]
		})
	}

	func randomColorForPointerView() {
		pointerImageViews.forEach({ $0.tintColor = MyColor.code(randomColorCode()).BTColors[0] })
	}

	func attributedStrings(nightStyle: Bool) -> [NSMutableAttributedString] {
		let texts = ["天的故事\n=\n标题\n+\n上午 + 下午 + 晚上\n+\n睡前哲思\n=\n10 + 100 + 100 + 100 + 20", "今日100\n=\n50个今日最新\n+\n49个昨日最热\n+\n1个你的故事\n=\n(50 + 49 + 1) × 330"]
		let titleAttributes = [
			NSForegroundColorAttributeName: MyColor.code(14).BTColors[0],
			NSFontAttributeName: UIFont.boldSystemFontOfSize(20)
		]

		let bodyColor = nightStyle ? UIColor.whiteColor() : MyColor.code(5).BTColors[0]
		let bodyAttributes = [
			NSForegroundColorAttributeName: bodyColor,
			NSFontAttributeName: UIFont.systemFontOfSize(14)
		]

		let string_0 = NSMutableAttributedString(string: texts[0], attributes: bodyAttributes)
		let range_0 = string_0.mutableString.rangeOfString("天的故事")
		string_0.addAttributes(titleAttributes, range: range_0)

		let string_1 = NSMutableAttributedString(string: texts[1], attributes: bodyAttributes)
		let range_1 = string_1.mutableString.rangeOfString("今日100")
		string_1.addAttributes(titleAttributes, range: range_1)

		return [string_0, string_1]
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

