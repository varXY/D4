//
//  RateView.swift
//  D4
//
//  Created by 文川术 on 4/13/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit


let RateViewWidth = ScreenWidth / 4


struct RateViews {

	let ratingView: UIVisualEffectView!
	let buttonsView: UIVisualEffectView!

	let ratingLabel: UILabel!
	var buttons = [UIButton]()

	var likedIndexes: [Int]!

	
    
	init(VC: DetailViewController) {
		let effect = VC.nightStyle ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .extraLight)
		let textColor = VC.nightStyle ? UIColor.white : UIColor.black

		ratingView = UIVisualEffectView(effect: effect)
		ratingView.frame = CGRect(x: ScreenWidth, y: 50, width: RateViewWidth + 20, height: 50)
		ratingView.layer.cornerRadius = globalRadius
		ratingView.clipsToBounds = true

		ratingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: RateViewWidth, height: 50))
		ratingLabel.textAlignment = .center
		ratingLabel.textColor = textColor
		ratingView.addSubview(ratingLabel)

		buttonsView = UIVisualEffectView(effect: effect)
		buttonsView.frame = CGRect(x: ScreenWidth, y: ScreenHeight - 150, width: RateViewWidth + 20, height: 100)
		buttonsView.layer.cornerRadius = globalRadius
		buttonsView.clipsToBounds = true

		let titles = ["顶", "踩"]
		let frames = [CGRect(x: 0, y: 0, width: RateViewWidth, height: 50), CGRect(x: 0, y: 50, width: RateViewWidth, height: 50)]
		buttons = [UIButton(type: .system), UIButton(type: .system)]
		buttons.forEach({
			let i = buttons.index(of: $0)!
			$0.frame = frames[i]
			$0.backgroundColor = UIColor.clear
			$0.setTitle(titles[i], for: UIControlState())
			$0.tintColor = textColor
			$0.tag = 100 + i
			$0.isExclusiveTouch = true
			$0.addTarget(VC, action: #selector(VC.rateButtonTapped(_:)), for: .touchUpInside)
			buttonsView.addSubview($0)
		})

		if VC.netOrLocalStory != 1 {
			VC.view.addSubview(ratingView)
			VC.view.addSubview(buttonsView)
		}

	}

    
	func show(_ show: Bool, rating: Int, storyIndex: Int) {
		ratingLabel.text = "\(rating)"

		if show {
			UIView.perform(.delete, on: [], options: [], animations: { 
				self.ratingView.frame.origin.x -= RateViewWidth
				}, completion: nil)

			let liked = likedIndexes.contains(storyIndex)
			if !liked {
				UIView.perform(.delete, on: [], options: [], animations: {
					self.buttonsView.frame.origin.x -= RateViewWidth
					}, completion: nil)
			}

		} else {
			UIView.perform(.delete, on: [], options: [], animations: {
				self.ratingView.frame.origin.x += RateViewWidth
				}, completion: nil)

			if buttonsView.frame.origin.x == ScreenWidth - RateViewWidth {
				UIView.perform(.delete, on: [], options: [], animations: {
					self.buttonsView.frame.origin.x += RateViewWidth
					}, completion: nil)
			}

		}

	}

    
	func hideAfterTapped(_ done: @escaping () -> ()) {
		UIView.perform(.delete, on: [], options: [], animations: {
			self.buttonsView.frame.origin.x += RateViewWidth
			}) { (_) in
		}

		delay(seconds: 0.2) {
			UIView.perform(.delete, on: [], options: [], animations: {
				self.ratingView.frame.origin.x += RateViewWidth
				}, completion: { (_) in
					done()
			})
		}

	}

    
}
