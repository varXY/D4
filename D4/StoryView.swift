//
//  StoryView.swift
//  D4
//
//  Created by 文川术 on 4/6/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

class StoryView: UIView {

	var bigBlockHeight = (ScreenHeight - 100) / 3
	var labels = [UILabel]()

	init(story: Story) {
		super.init(frame: ScreenBounds)
		backgroundColor = UIColor.clearColor()
		layer.cornerRadius = globalRadius
		clipsToBounds = true
		
		var index = 0
		repeat {
			let label = SLabel(frame: blockFrame(index))
			label.backgroundColor = MyColor.code(story.colors[index]).BTColors[0]
			label.textColor = MyColor.code(story.colors[index]).BTColors[1]
			label.text = story.sentences[index]
			label.textAlignment = .Center
			label.numberOfLines = 0
			label.adjustsFontSizeToFitWidth = true
			label.drawTextInRect(CGRectMake(10, 10, label.frame.width - 20, label.frame.height - 20))
			labels.append(label)
			addSubview(label)

			if index == 0 {
				label.font = UIFont.boldSystemFontOfSize(19)
			}

			if index == 4 {
				label.font = UIFont.italicSystemFontOfSize(19)
				bringSubviewToFront(label)
				bringSubviewToFront(labels[0])

//				addShadowForButton(labels[2])
//				bringSubviewToFront(labels[2])
			}

			index += 1
		} while index < 5

//		addShawdow()
	}

	func addShawdow() {
		addShadowForButton(labels[0])
		addShadowForButton(labels[4])
	}

	func addShadowForButton(label: UILabel) {
		label.layer.masksToBounds = false
		label.layer.shadowRadius = 10
		label.layer.shadowOpacity = 0.5
		label.layer.shadowColor = UIColor.blackColor().CGColor
		label.layer.shadowOffset = CGSizeMake(0, 0)
	}

	func reloadStory(story: Story) {
		var index = 0
		repeat {
			labels[index].backgroundColor = MyColor.code(story.colors[index]).BTColors[0]
			labels[index].textColor = MyColor.code(story.colors[index]).BTColors[1]
			labels[index].text = story.sentences[index]

			index += 1
		} while index < labels.count
	}

	func blockFrame(index: Int) -> CGRect {
		let addend = index == 0 ? 0 : smallBlockHeight
		let factor = index == 0 ? 0 : index - 1
		let y = addend + bigBlockHeight * CGFloat(factor)
		let height = (index == 0 || index == 4) ? smallBlockHeight : bigBlockHeight
		return CGRectMake(0, y, ScreenWidth, height)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}