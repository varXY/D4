//
//  PointerView.swift
//  D4
//
//  Created by 文川术 on 4/11/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

class PointerView: UIView {

	var upPointer: UIImageView!
	var downPointer: UIImageView!
	var leftPointer: UIImageView!
	var rightPointer: UIImageView!

	var UDLR_labels: [UILabel]!
	var blankViews: [UIView]!

	var lastUpDateTime: NSDate! {
		didSet {
			let today = lastUpDateTime.string(.MMddyy) == NSDate().string(.MMddyy)
			lastUpdateText = today ? "\(NSDate().string(.HHmm))" : lastUpDateTime.string(.MMdd)
			delay(seconds: 1.5) {
				self.UDLR_labels[0].text = self.lastUpdateText + "更新"
			}

		}
	}

	var lastUpdateText = ""

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

	struct Label {
		let UD_size = CGSize(width: ScreenWidth - 30 * 2, height: 30)
		let LR_size = CGSize(width: 30, height: ScreenHeight - 30 * 4)

		func label(type: XYScrollType) -> UILabel {
			let label = UILabel()
			label.backgroundColor = UIColor.clearColor()
			label.textAlignment = .Center
			label.textColor = UIColor.whiteColor()

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

		UDLR_labels = [UILabel]()
		let types = [XYScrollType.Up, XYScrollType.Down, XYScrollType.Left, XYScrollType.Right]
		let structLabel = Label()
		var i = 0
		repeat {
			let label = structLabel.label(types[i])
			label.font = UIFont.systemFontOfSize(14)
			UDLR_labels.append(label)
			i += 1
		} while i < types.count

		switch VC {
		case is MainViewController:

			blankViews = [UIView]()
			let topBlankView = UIView(frame: CGRectMake(0, 0, ScreenWidth, 20))
			let bottomBlankView = UIView(frame: CGRectMake(0, ScreenHeight - 44, ScreenWidth, 44))
			blankViews.append(topBlankView)
			blankViews.append(bottomBlankView)
			blankViews.forEach({
				$0.backgroundColor = UIColor.lightGrayColor()
				addSubview($0)
			})

			// 去创造新故事吧?
			let texts = ["", "", "写\n故\n事", "关\n于"]
			UDLR_labels.forEach({ (label) in
				let index = UDLR_labels.indexOf(label)!
				label.text = texts[index]
				addSubview(label)

				if index == 1 {
					label.frame.origin.y -= 24
				}
			})

		case is DetailViewController:
			addSubview(upPointer)
			addSubview(downPointer)

			guard let detailVC = VC as? DetailViewController else { return }
			let rightText = detailVC.netOrLocalStory == 0 ? "顶\n踩" : "复\n制\n文\n字"
			let texts = ["上一个", "下一个", "主\n页", rightText]
			UDLR_labels.forEach({ (label) in
				let index = UDLR_labels.indexOf(label)!
				label.text = texts[index]
				addSubview(label)
			})

		default:
			break
		}
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
				if UDLR_labels != nil && i < UDLR_labels.count { UDLR_labels[i].alpha = 0.0 }
			})

			delay(seconds: 0.4, completion: {
				pointers.forEach({ (pointer) in
					pointer.alpha = 1.0
					let i = pointers.indexOf({ (imageView) -> Bool in
						return imageView == pointer
					})!
					pointers[i].transform = transforms[i]
					if self.UDLR_labels != nil && i < self.UDLR_labels.count { self.UDLR_labels[i].alpha = 1.0 }
				})
			})

		}
	}

	func rotation(animate: () -> ()) {
		UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: { 
			animate()
			}, completion: nil)
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
			let texts = topIndex == 0 ? ["还没想好什么功能", "写完上划发布"] : ["联系开发者", "￥12 请独立开发者吃顿好的"]
			UDLR_labels[0].text = texts[0]
			UDLR_labels[1].text = texts[1]

		default:
			blankViews.forEach({ addSubview($0); sendSubviewToBack($0) })

			upPointer.removeFromSuperview()
			downPointer.removeFromSuperview()

			UDLR_labels[0].text = lastUpdateText + "更新"
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

	func changeLabelTextForCanSaveStory(can: Bool) {
		UDLR_labels[1].text = can ? "发布" : "写完上划发布"
	}

	// MARK: - DetailViewController
	func showNoMore(top: Bool?) {
		if top == true {
			UDLR_labels[0].text = "没有了"
		} else if top == false {
			UDLR_labels[1].text = "没有了"
		} else {
			UDLR_labels[0].text = "上一个"
			UDLR_labels[1].text = "下一个"
		}
	}



	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}