//
//  StoryView.swift
//  D4
//
//  Created by 文川术 on 4/6/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

class StoryView: UIView {

	var labels: [UILabel]!

	init(story: Story) {
		super.init(frame: ScreenBounds)
		backgroundColor = UIColor.clearColor()
		layer.cornerRadius = globalRadius
		clipsToBounds = true

		labels = blockFrames().map({ SLabel(frame: $0) })
		labels.forEach({
			let index = labels.indexOf($0)!
			$0.backgroundColor = MyColor.code(story.colors[index]).BTColors[0]
			$0.textColor = MyColor.code(story.colors[index]).BTColors[1]
			$0.textAlignment = .Center
			$0.numberOfLines = 0
			$0.adjustsFontSizeToFitWidth = true
			$0.text = story.sentences[index]
			addSubview($0)

			if index == 0 {
				$0.font = UIFont.boldSystemFontOfSize(17)
			}

			if index == 4 {
				$0.font = UIFont.italicSystemFontOfSize(17)
				$0.numberOfLines = 1
			}
		})

	}

	func reloadStory(story: Story) {
		labels.forEach({
			let index = labels.indexOf($0)!
			$0.backgroundColor = MyColor.code(story.colors[index]).BTColors[0]
			$0.textColor = MyColor.code(story.colors[index]).BTColors[1]
			$0.text = story.sentences[index]
		})
	}

	func blockFrames() -> [CGRect] {
		func blockFrame(index: Int) -> CGRect {
			let bigBlockHeight = (ScreenHeight - 100) / 3
			let addend = index == 0 ? 0 : smallBlockHeight
			let factor = index == 0 ? 0 : index - 1
			let y = addend + bigBlockHeight * CGFloat(factor)
			let height = (index == 0 || index == 4) ? smallBlockHeight : bigBlockHeight
			return CGRectMake(0, y, ScreenWidth, height)
		}

		let indexes = [0, 1, 2, 3, 4]
		return indexes.map({ blockFrame($0) })
	}


	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}