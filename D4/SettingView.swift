//
//  InputView.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit
import iAd

class SettingView: UIView {

	init() {
		super.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
		backgroundColor = UIColor.lightGrayColor()
		layer.cornerRadius = globalRadius
		clipsToBounds = true
		exclusiveTouch = true

		let adView = ADBannerView(adType: .Banner)
		adView.frame = CGRect(x: 0, y: ScreenHeight - 50, width: ScreenWidth, height: 50)
		adView.delegate = self
		addSubview(adView)
	}



	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension SettingView: ADBannerViewDelegate {

	func bannerViewWillLoadAd(banner: ADBannerView!) {
		banner.alpha = 1.0
	}

	func bannerViewDidLoadAd(banner: ADBannerView!) {
		banner.alpha = 1.0
	}

	func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
		banner.alpha = 0.0
	}
}