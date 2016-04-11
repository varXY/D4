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

		switch VC {
		case is MainViewController:
			addSubview(leftPointer)
			addSubview(rightPointer)

		case is DetailViewController:
			addSubview(leftPointer)
			addSubview(rightPointer)
			addSubview(upPointer)
			addSubview(downPointer)


			UDLR_labels = [UILabel]()
			let types = [XYScrollType.Up, XYScrollType.Down, XYScrollType.Left, XYScrollType.Right]
			let texts = ["上一个", "下一个", "主\n页", "评\n分"]
			let structLabel = Label()
			var i = 0
			repeat {
				let label = structLabel.label(types[i])
				label.text = texts[i]
				UDLR_labels.append(label)
				addSubview(label)
				i += 1
			} while i < types.count

		default:
			break
		}
	}

	func changePointerDirection(type: XYScrollType) {
		switch type {
		case .Up:
			rotation({ 
				self.upPointer.transform = self.pointer.down_transform
			})

		case .Down:
//			rotation({
				self.downPointer.transform = self.pointer.up_transform
//			})

		case .Left:
			rotation({ 
				self.leftPointer.transform = self.pointer.right_transform
			})

		case .Right:
//			rotation({ 
				self.rightPointer.transform = self.pointer.left_transform
//			})

		default:
			let pointers = [upPointer, downPointer, leftPointer, rightPointer]
			let transforms = [pointer.up_transform, pointer.down_transform, pointer.left_transform, pointer.right_transform]

			var i = 0
			repeat {
				pointers[i].alpha = 0.0
				if UDLR_labels != nil { UDLR_labels[i].alpha = 0.0 }
				i += 1
			} while i < pointers.count

			delay(seconds: 0.5, completion: { 
				i = 0
				repeat {
					pointers[i].alpha = 1.0
					if self.UDLR_labels != nil { self.UDLR_labels[i].alpha = 1.0 }
					pointers[i].transform = transforms[i]
					i += 1
				} while i < pointers.count
			})

		}
	}

	func rotation(animate: () -> ()) {
		UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {
			animate()
			}, completion: nil)
	}

	func addOrRemoveUpAndDownPointer(add: Bool) {
		if add {
			addSubview(upPointer)
			addSubview(downPointer)
			sendSubviewToBack(upPointer)
			sendSubviewToBack(downPointer)
		} else {
			upPointer.removeFromSuperview()
			downPointer.removeFromSuperview()
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}