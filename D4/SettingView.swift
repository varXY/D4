//
//  InputView.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

class SettingView: UIView {

	init() {
		super.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
		backgroundColor = MyColor.code(1).BTColors[0]
		layer.cornerRadius = globalRadius
		clipsToBounds = true
		exclusiveTouch = true

		let width = ScreenWidth / 1.5
		let height = width * 1.775
		let label = UILabel(frame: CGRectMake((ScreenWidth - width) / 2, (ScreenHeight - height) / 2, width, height))
		label.textAlignment = .Center
		label.font = UIFont.systemFontOfSize(19)
		label.numberOfLines = 0
		label.backgroundColor = MyColor.code(5).BTColors[0]
		label.textColor = UIColor.whiteColor()
		label.layer.cornerRadius = globalRadius
		label.clipsToBounds = true

		label.layer.masksToBounds = false
		label.shadowColor = UIColor.blackColor()
		label.layer.shadowRadius = 3
		label.layer.shadowOpacity = 0.7
		label.shadowOffset = CGSize(width: 0, height: 0)
		label.text = "天的故事\n=\n7 + 100 + 100 + 20\n\n\n\n\n\n\n\n今日100\n=\n50个今日最新\n+\n49个昨日最热\n+\n1个你的故事"
		addSubview(label)

		let iconView = UIImageView(image: UIImage(named: "Icon"))
		iconView.center = center
		iconView.frame.origin.y -= 50
		iconView.layer.cornerRadius = iconView.frame.width / 2
		iconView.clipsToBounds = true
		addSubview(iconView)

		let pointer = Pointer()
		let pointerImageViews = [pointer.imageView(.Up), pointer.imageView(.Down), pointer.imageView(.Left), pointer.imageView(.Right)]
		pointerImageViews.forEach({
			$0.transform = CGAffineTransformRotate($0.transform, CGFloat(180 * M_PI / 180))
			$0.tintColor = MyColor.code(5).BTColors[0]
			addSubview($0)
		})

	}



	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

