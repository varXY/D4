//
//  RateView.swift
//  D4
//
//  Created by 文川术 on 4/13/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit


struct RateViews {

	let ratingView: UIVisualEffectView!
	let buttonsView: UIVisualEffectView!

	let ratingLabel: UILabel!
	var buttons = [UIButton]()

	var likedIndexes: [Int]!
	let width = ScreenWidth / 4

	
	init(VC: DetailViewController, effect: UIBlurEffect) {
		ratingView = UIVisualEffectView(effect: effect)
		ratingView.frame = CGRectMake(ScreenWidth, 50, width + 20, 50)
		ratingView.layer.cornerRadius = 5
		ratingView.clipsToBounds = true
		VC.view.addSubview(ratingView)

		let textColor = effect == UIBlurEffect(style: .Dark) ? UIColor.whiteColor() : UIColor.blackColor()

		ratingLabel = UILabel(frame: CGRectMake(0, 0, width, 50))
		ratingLabel.textAlignment = .Center
		ratingLabel.textColor = textColor
		ratingView.addSubview(ratingLabel)


		buttonsView = UIVisualEffectView(effect: effect)
		buttonsView.frame = CGRectMake(ScreenWidth, ScreenHeight - 150, width + 20, 100)
		buttonsView.layer.cornerRadius = 5
		buttonsView.clipsToBounds = true
		VC.view.addSubview(buttonsView)

		let titles = ["顶", "踩"]
		var i = 0
		repeat	{
			let button = UIButton(type: .System)
			button.frame = CGRectMake(0, 50 * CGFloat(i), width, 50)
			button.backgroundColor = UIColor.clearColor()
			button.setTitle(titles[i], forState: .Normal)
			button.tintColor = textColor
			button.tag = 100 + i
			button.addTarget(VC, action: #selector(DetailViewController.rateButtonTapped(_:)), forControlEvents: .TouchUpInside)
			buttonsView.addSubview(button)
			buttons.append(button)
			i += 1
		} while i < titles.count

	}

	mutating func show(show: Bool, rating: Int, storyIndex: Int) {
		ratingLabel.text = "\(rating)"

		if show {
			UIView.animateWithDuration(0.3, animations: {
				self.ratingView.frame.origin.x -= self.width
			})

			let liked = likedIndexes.contains(storyIndex)
			if !liked {
				UIView.animateWithDuration(0.3, animations: {
					self.buttonsView.frame.origin.x -= self.width
				})
			}

		} else {
			UIView.animateWithDuration(0.3, animations: {
				self.ratingView.frame.origin.x += self.width
			})

			if buttonsView.frame.origin.x == ScreenWidth - width {
				UIView.animateWithDuration(0.3, animations: {
					self.buttonsView.frame.origin.x += self.width
				})
			}

		}

	}

	func hideAfterTapped() {
		UIView.animateWithDuration(0.3, animations: { 
			self.buttonsView.frame.origin.x += self.width
			}) { (_) in
				UIView.animateWithDuration(0.3, animations: {
					self.ratingView.frame.origin.x += self.width
				})
		}
	}

}
