//
//  UIViewController+.swift
//  D4
//
//  Created by 文川术 on 4/17/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

extension UIViewController {

	func captureScreen() -> UIImage {

		let screen = UIApplication.sharedApplication().windows[0]

		UIGraphicsBeginImageContextWithOptions(screen.frame.size, false, 0)
		view.drawViewHierarchyInRect(screen.bounds, afterScreenUpdates: true)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		var rect = CGRect()

		if ScreenHeight == 736 {
			rect = CGRect(x: 0, y: 20, width: ScreenWidth * 3, height: ScreenHeight * 3 - 20)
		} else {
			rect = CGRect(x: 0, y: 20, width: ScreenWidth * 2, height: ScreenHeight * 2 - 20)
		}

		let cuttedmage = CGImageCreateWithImageInRect(image.CGImage, rect)
		let resultImage = UIImage(CGImage: cuttedmage!)
		
		return resultImage
	}

}