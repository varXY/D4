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

	
	init(VC: DetailViewController) {
		let effect = VC.nightStyle ? UIBlurEffect(style: .Dark) : UIBlurEffect(style: .ExtraLight)
		
		ratingView = UIVisualEffectView(effect: effect)
		ratingView.frame = CGRectMake(ScreenWidth, 50, width + 20, 50)
		ratingView.layer.cornerRadius = globalRadius
		ratingView.clipsToBounds = true

		let textColor = VC.nightStyle ? UIColor.whiteColor() : UIColor.blackColor()

		ratingLabel = UILabel(frame: CGRectMake(0, 0, width, 50))
		ratingLabel.textAlignment = .Center
		ratingLabel.textColor = textColor
		ratingView.addSubview(ratingLabel)

		buttonsView = UIVisualEffectView(effect: effect)
		buttonsView.frame = CGRectMake(ScreenWidth, ScreenHeight - 150, width + 20, 100)
		buttonsView.layer.cornerRadius = globalRadius
		buttonsView.clipsToBounds = true

		let titles = ["顶", "踩"]
		let frames = [CGRectMake(0, 0, width, 50), CGRectMake(0, 50, width, 50)]
		buttons = [UIButton(type: .System), UIButton(type: .System)]
		buttons.forEach({
			let i = buttons.indexOf($0)!
			$0.frame = frames[i]
			$0.backgroundColor = UIColor.clearColor()
			$0.setTitle(titles[i], forState: .Normal)
			$0.tintColor = textColor
			$0.tag = 100 + i
			$0.exclusiveTouch = true
			$0.addTarget(VC, action: #selector(VC.rateButtonTapped(_:)), forControlEvents: .TouchUpInside)
			buttonsView.addSubview($0)
		})

		if VC.netOrLocalStory != 1 {
			VC.view.addSubview(ratingView)
			VC.view.addSubview(buttonsView)
		}

	}

	mutating func show(show: Bool, rating: Int, storyIndex: Int) {
		ratingLabel.text = "\(rating)"

		if show {

			UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: { 
				self.ratingView.frame.origin.x -= self.width
				}, completion: nil)

			let liked = likedIndexes.contains(storyIndex)
			if !liked {
				UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: {
					self.buttonsView.frame.origin.x -= self.width
					}, completion: nil)
			}

		} else {
			UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: {
				self.ratingView.frame.origin.x += self.width
				}, completion: nil)

			if buttonsView.frame.origin.x == ScreenWidth - width {
				UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: {
					self.buttonsView.frame.origin.x += self.width
					}, completion: nil)
			}

		}

	}

	func hideAfterTapped(done: () -> ()) {
		UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: {
			self.buttonsView.frame.origin.x += self.width
			}) { (_) in
		}

		delay(seconds: 0.2) {
			UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: {
				self.ratingView.frame.origin.x += self.width
				}, completion: { (_) in
					done()
			})
		}

	}

}
