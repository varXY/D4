//
//  PointerView.swift
//  D4
//
//  Created by 文川术 on 4/11/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

struct Pointer {
	let length: CGFloat = 30
	let imageName = "Pointer"

	let left_transform = CGAffineTransformMakeRotation(CGFloat(90 * M_PI / 180))
	let right_transform = CGAffineTransformMakeRotation(CGFloat(-90 * M_PI / 180))
	let up_transform = CGAffineTransformMakeRotation(CGFloat(180 * M_PI / 180))
	let down_transform = CGAffineTransformMakeRotation(CGFloat(0 * M_PI / 180))

	func imageView(type: XYScrollType) -> UIImageView {
		let imageView = UIImageView(image: UIImage(named: imageName))
		imageView.frame.size = CGSize(width: length, height: length)

		switch type {
		case .Up:
			imageView.center = CGPoint(x: ScreenWidth / 2, y: length / 2)
			imageView.transform = up_transform

		case .Down:
			imageView.center = CGPoint(x: ScreenWidth / 2, y: ScreenHeight - (length / 2))
			imageView.transform = down_transform

		case .Left:
			imageView.center = CGPoint(x: length / 2, y: ScreenHeight / 2)
			imageView.transform = left_transform

		case .Right:
			imageView.center = CGPoint(x: ScreenWidth - (length / 2), y: ScreenHeight / 2)
			imageView.transform = right_transform

		default:
			break
		}

		return imageView
	}
}

class PointerView: UIView {

	var upPointer: UIImageView!
	var downPointer: UIImageView!
	var leftPointer: UIImageView!
	var rightPointer: UIImageView!

	var UDLR_labels = [UILabel]()
	var blankViews: [UIView]!

	var lastUpDateTime: NSDate! {
		didSet {
			let today = lastUpDateTime.string(.MMddyy) == NSDate().string(.MMddyy)
			delay(seconds: 1.5) {
				self.lastUpdateText = today ? "" : "无法更新"
			}
		}
	}

	var lastUpdateText: String! {
		didSet {
			self.UDLR_labels[0].text = lastUpdateText
		}
	}

	struct Label {
		let UD_size = CGSize(width: ScreenWidth - 30 * 2, height: 30)
		let LR_size = CGSize(width: 30, height: ScreenHeight - 30 * 4)

		func label(type: XYScrollType) -> UILabel {
			let label = UILabel()
			label.backgroundColor = UIColor.clearColor()
			label.textAlignment = .Center
			label.textColor = UIColor.whiteColor()
			label.font = UIFont.systemFontOfSize(14)

			switch type {
			case .Up:
				label.frame.origin = CGPoint(x: 30, y: 30)
				label.frame.size = UD_size
			case .Down:
				label.frame.origin = CGPoint(x: 30, y: ScreenHeight - 60)
				label.frame.size = UD_size
			case .Left:
				label.frame.origin = CGPoint(x: 30, y: 60)
				label.frame.size = LR_size
				label.numberOfLines = 0
			case .Right:
				label.frame.origin = CGPoint(x: ScreenWidth - 60, y: 60)
				label.frame.size = LR_size
				label.numberOfLines = 0
			default:
				break
			}

			return label
		}
	}

	let pointer = Pointer()

	init(VC: UIViewController) {
		super.init(frame: ScreenBounds)
		backgroundColor = UIColor.blackColor()
		tintColor = UIColor.whiteColor()

		upPointer = pointer.imageView(.Up)
		downPointer = pointer.imageView(.Down)
		leftPointer = pointer.imageView(.Left)
		rightPointer = pointer.imageView(.Right)

		addSubview(leftPointer)
		addSubview(rightPointer)

		let types = [XYScrollType.Up, XYScrollType.Down, XYScrollType.Left, XYScrollType.Right]
		UDLR_labels = types.map({ Label().label($0) })

		switch VC {
		case is MainViewController:
			blankViews = [UIView]()
			let frames = [CGRectMake(0, 0, ScreenWidth, 20), CGRectMake(0, ScreenHeight - 44, ScreenWidth, 44)]
			blankViews = frames.map({ UIView(frame: $0) })
			blankViews.forEach({ $0.backgroundColor = MyColor.code(24).BTColors[0]; addSubview($0) })

			// 去创造新故事吧?
			let texts = ["", "", "写\n故\n事", "关\n于"]
			UDLR_labels.forEach({
				let index = UDLR_labels.indexOf($0)!
				$0.text = texts[index]
				addSubview($0)
				if index == 1 { $0.frame.origin.y -= 24 }
				if index == 2 || index == 3 { $0.alpha = 0.0 }
			})

		case is DetailViewController:
			addSubview(upPointer)
			addSubview(downPointer)

			guard let detailVC = VC as? DetailViewController else { return }
			let rightText = detailVC.netOrLocalStory != 1 ? "顶\n踩" : "复\n制\n文\n字"
			let texts = ["前一天", "后一天", "主\n页", rightText]
			UDLR_labels.forEach({ $0.text = texts[UDLR_labels.indexOf($0)!]; addSubview($0) })

		default:
			break
		}

		leftPointer.alpha = 0.0
		rightPointer.alpha = 0.0

	}

	func changePointerDirection(type: XYScrollType) {		
		switch type {
		case .Up: rotation({ self.upPointer.transform = self.pointer.down_transform })
		case .Down: rotation({ self.downPointer.transform = self.pointer.up_transform })
		case .Left: rotation({ self.leftPointer.transform = self.pointer.right_transform })
		case .Right: rotation({ self.rightPointer.transform = self.pointer.left_transform })
		default:
			let pointers = [upPointer, downPointer, leftPointer, rightPointer]
			let transforms = [pointer.up_transform, pointer.down_transform, pointer.left_transform, pointer.right_transform]

			pointers.forEach({ (pointer) in
				pointer.alpha = 0.0
				let i = pointers.indexOf({ (imageView) -> Bool in
					return imageView == pointer
				})!
				if i < UDLR_labels.count { UDLR_labels[i].alpha = 0.0 }
			})

			delay(seconds: 0.4, completion: {
				pointers.forEach({ (pointer) in
					pointer.alpha = 1.0
					let i = pointers.indexOf({ (imageView) -> Bool in
						return imageView == pointer
					})!
					pointers[i].transform = transforms[i]
					if i < self.UDLR_labels.count { self.UDLR_labels[i].alpha = 1.0 }
				})
			})

		}
	}

	func rotation(animate: () -> ()) {
		UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: { 
			animate()
			}, completion: nil)
	}

	func showAllSubviews(show: Bool, VC: UIViewController) {
		let pointers = [leftPointer, rightPointer]
		pointers.forEach({ $0.alpha = show ? 1.0 : 0.0 })
		if VC.isKindOfClass(MainViewController) {
			UDLR_labels.forEach({
				let index = UDLR_labels.indexOf($0)!
				if index == 2 || index == 3 { $0.alpha = show ? 1.0 : 0.0 }
			})
		}

	}


	// MARK: - MainViewController

	func addOrRemoveUpAndDownPointerAndLabel(topIndex: Int) {
		switch topIndex {
		case 0, 2:
			blankViews.forEach({ $0.removeFromSuperview() })

			addSubview(upPointer)
			addSubview(downPointer)
			sendSubviewToBack(upPointer)
			sendSubviewToBack(downPointer)

			if UDLR_labels[1].frame.origin.y != ScreenHeight - 60 { UDLR_labels[1].frame.origin.y += 24 }
			let texts = topIndex == 0 ? [randomTip(.Up), "写完上划发布"] : ["联系开发者", "￥12 请独立开发者吃顿好的"]
			UDLR_labels[0].text = texts[0]
			UDLR_labels[1].text = texts[1]

		default:
			blankViews.forEach({ addSubview($0); sendSubviewToBack($0) })

			upPointer.removeFromSuperview()
			downPointer.removeFromSuperview()

			UDLR_labels[0].text = lastUpdateText
			UDLR_labels[1].text = "" // 去创造新故事吧
			if UDLR_labels[1].frame.origin.y == ScreenHeight - 60 { UDLR_labels[1].frame.origin.y -= 24 }
		}

	}

	func showTextBaseOnTopIndex(index: Int) {
		switch index {
		case 0:
			UDLR_labels[2].text = "随\n机\n颜\n色"
			UDLR_labels[3].text = "主\n页"
		case 1:
			UDLR_labels[2].text = "写\n故\n事"
			UDLR_labels[3].text = "关\n于"
		case 2:
			UDLR_labels[2].text = "主\n页"
			UDLR_labels[3].text = "博\n客"
		default:
			break
		}
	}

	func changeTopLabelTextWhenSegmentedControlSelected(index: Int) {
		UDLR_labels[0].text = index == 0 ? lastUpdateText : ""
	}

	func changeLabelTextForCanSaveStory(can: Bool, ready: Bool) {
		if !can && !ready {	UDLR_labels[1].text = "写完上划发布" }
		if can && !ready { UDLR_labels[1].text = randomTip(.Down) }
		if can && ready { UDLR_labels[1].text = "发布" }
	}

	func changeTextForUpInWriteView() {
		UDLR_labels[0].text = randomTip(.Up)
	}

	func randomTip(scrollType: XYScrollType) -> String {
		var tips = [String]()

		switch scrollType {
		case .Up:
			tips = [
				"时间、地点、行动",
				"开端、发展、高潮",
				"需求、观点、态度、转变",
				"人物即是动作",
				"建置、对抗、结局",
				"观点没有对错",
				"戏剧就是冲突",
				"悲剧是“正确与正确的对抗”",
				"职业生活、个人生活、私生活",
				"动作即是人物",
				"结尾来自开端",
				"开端、中段、结尾",
				"明确主题",
			]
		case .Down:
			tips = [
				"今天发过一次",
				"一天一个故事",
				"留着明天发",
			]

		default:
			break

		}
		let index = random() % tips.count
		return tips[index]
	}


	// MARK: - DetailViewController

	func showNoMore(top: Bool?) {
		if top == true {
			UDLR_labels[0].text = "没有了"
		} else if top == false {
			UDLR_labels[1].text = "没有了"
		} else {
			UDLR_labels[0].text = "前一天"
			UDLR_labels[1].text = "后一天"
		}
	}



	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}