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

	let transforms = [
		CGAffineTransform(rotationAngle: CGFloat(0 * Double.pi / 180)),
		CGAffineTransform(rotationAngle: CGFloat(180 * Double.pi / 180)),
		CGAffineTransform(rotationAngle: CGFloat(-90 * Double.pi / 180)),
		CGAffineTransform(rotationAngle: CGFloat(90 * Double.pi / 180)),
	]

//	let originCenters = [
//		CGPointMake(ScreenWidth / 2, 30 / 2 - 30),
//		CGPointMake(ScreenWidth / 2, ScreenHeight - (30 / 2) + 30),
//		CGPointMake(30 / 2 - 30, ScreenHeight / 2),
//		CGPointMake(ScreenWidth - (30 / 2) + 30, ScreenHeight / 2),
//	]

	let toCenters = [
		CGPoint(x: ScreenWidth / 2, y: 30 / 2 + 3),
		CGPoint(x: ScreenWidth / 2, y: ScreenHeight - (30 / 2) - 3),
		CGPoint(x: 30 / 2 + 3, y: ScreenHeight / 2),
		CGPoint(x: ScreenWidth - (30 / 2) - 3, y: ScreenHeight / 2),
	]

	func imageView(_ type: XYScrollType) -> UIImageView {
		let imageView = UIImageView(image: UIImage(named: imageName))
		imageView.frame.size = CGSize(width: length, height: length)
		imageView.center = toCenters[type.rawValue]
		imageView.transform = transforms[type.rawValue]
//		imageView.tintColor = UIColor(white: 0.3, alpha: 0.75)
		imageView.alpha = 0.3
		return imageView
	}
}

class PointerView: UIView {

	var pointers = [UIImageView]()
	var UDLR_labels = [UILabel]()
	var blankViews: [UIView]!

	let pointerAlpha: CGFloat = 0.3
    let labelAlpha: CGFloat = 1.0

	var nightStyle = false {
		didSet {
			backgroundColor = nightStyle ? UIColor.black : UIColor.backgroundColor()
			pointers.forEach({ $0.tintColor = nightStyle ? UIColor.white : UIColor.lightGray })
			UDLR_labels.forEach({ $0.textColor = nightStyle ? UIColor.white : UIColor.black })
		}
	}

	var lastUpDateTime: Date! {
		didSet {
			let today = lastUpDateTime.string(.MMddyy) == Date().string(.MMddyy)
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

		func label(_ type: XYScrollType) -> UILabel {
			let label = UILabel()
			label.backgroundColor = UIColor.clear
			label.textAlignment = .center
			label.textColor = UIColor.white
			label.font = UIFont.systemFont(ofSize: 14)

			switch type {
			case .up:
				label.frame.origin = CGPoint(x: 30, y: 30)
				label.frame.size = UD_size
			case .down:
				label.frame.origin = CGPoint(x: 30, y: ScreenHeight - 60)
				label.frame.size = UD_size
			case .left:
				label.frame.origin = CGPoint(x: 30, y: 60)
				label.frame.size = LR_size
				label.numberOfLines = 0
			case .right:
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
		backgroundColor = UIColor.black
		tintColor = UIColor.white

		pointers = [pointer.imageView(.up), pointer.imageView(.down), pointer.imageView(.left), pointer.imageView(.right)]
		addSubview(pointers[2])
		addSubview(pointers[3])

		let types = [XYScrollType.up, XYScrollType.down, XYScrollType.left, XYScrollType.right]
		UDLR_labels = types.map({ Label().label($0) })

		pointers.forEach({
			$0.transform = $0.transform.scaledBy(x: 0.85, y: 0.85)
			$0.alpha = 0.0
		})
		UDLR_labels.forEach({ $0.alpha = 0.0 })

		switch VC {
		case is MainViewController:
			blankViews = [UIView]()
			let frames = [CGRect(x: 0, y: 0, width: ScreenWidth, height: 20), CGRect(x: 0, y: ScreenHeight - 44, width: ScreenWidth, height: 44)]
			blankViews = frames.map({ UIView(frame: $0) })
			blankViews.forEach({ $0.backgroundColor = MyColor.code(5).BTColors[0]; addSubview($0) })

			// 去创造新故事吧?
			let texts = ["", "", "写\n故\n事", "关\n于"]
			UDLR_labels.forEach({
				let index = UDLR_labels.index(of: $0)!
				$0.text = texts[index]
				addSubview($0)
				if index == 1 { $0.frame.origin.y -= 24 }
			})

		case is DetailViewController:
			addSubview(pointers[0])
			addSubview(pointers[1])

			guard let detailVC = VC as? DetailViewController else { return }
			let rightText = detailVC.netOrLocalStory != 1 ? "顶\n踩" : "复\n制\n文\n字"
			let texts = ["前一天", "后一天", "主\n页", rightText]
			UDLR_labels.forEach({ $0.text = texts[UDLR_labels.index(of: $0)!]; addSubview($0) })

		default:
			break
		}

	}

	func showPointer(_ type: XYScrollType) {
		switch type {
		case .up, .down, .left, .right:
			move({
				self.pointers[type.rawValue].alpha = self.pointerAlpha
				self.UDLR_labels[type.rawValue].alpha = self.labelAlpha
				}, done: {
			})

		default:
			hidePointersAndLabels()
		}
	}

	func move(_ animate: @escaping () -> (), done: @escaping () -> ()) {
		UIView.perform(.delete, on: [], options: [], animations: { 
			animate()
			}) { (_) in
				done()
		}
	}

	func hidePointersAndLabels() {
		pointers.forEach({ if $0.alpha != 0.0 { $0.alpha = 0.0 } })
		UDLR_labels.forEach({ if $0.alpha != 0.0 { $0.alpha = 0.0 } })
	}


	// MARK: - MainViewController

	func addOrRemoveUpAndDownPointerAndLabel(_ topIndex: Int) {
		switch topIndex {
		case 0, 2:
			blankViews.forEach({ $0.removeFromSuperview() })

			addSubview(pointers[0]); sendSubview(toBack: pointers[0])
			addSubview(pointers[1]); sendSubview(toBack: pointers[1])

			if UDLR_labels[1].frame.origin.y != ScreenHeight - 60 { UDLR_labels[1].frame.origin.y += 24 }
			let texts = topIndex == 0 ? [randomTip(.up), "写完上划发布"] : ["联系开发者", "￥12 请独立开发者吃顿好的"]
			UDLR_labels[0].text = texts[0]
			UDLR_labels[1].text = texts[1]

		default:
			blankViews.forEach({ addSubview($0); sendSubview(toBack: $0) })

			pointers[0].removeFromSuperview()
			pointers[1].removeFromSuperview()

			UDLR_labels[0].text = lastUpdateText
			UDLR_labels[1].text = "" // 去创造新故事吧
			if UDLR_labels[1].frame.origin.y == ScreenHeight - 60 { UDLR_labels[1].frame.origin.y -= 24 }
		}

	}

	func showTextBaseOnTopIndex(_ index: Int) {
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

	func changeTopLabelTextWhenSegmentedControlSelected(_ index: Int) {
		UDLR_labels[0].text = index == 0 ? lastUpdateText : ""
	}

	func changeLabelTextForCanSaveStory(_ can: Bool, ready: Bool) {
		UDLR_labels[1].alpha = 0.0
		if !can && !ready {	UDLR_labels[1].text = "写完上划发布" }
		if can && !ready { UDLR_labels[1].text = randomTip(.down) }
		if can && ready { UDLR_labels[1].text = "发布" }
	}

	func changeTextForUpInWriteView() {
		UDLR_labels[0].alpha = 0.0
		UDLR_labels[0].text = randomTip(.up)
	}

	func randomTip(_ scrollType: XYScrollType) -> String {
		var tips = [String]()

		switch scrollType {
		case .up:
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
		case .down:
			tips = [
				"今天发过一次",
				"一天一个故事",
				"留着明天发",
			]

		default:
			break

		}
		let index = Int(arc4random_uniform(UInt32(tips.count)))
		return tips[index]
	}


	// MARK: - DetailViewController

	func showNoMore(_ top: Bool?) {
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
