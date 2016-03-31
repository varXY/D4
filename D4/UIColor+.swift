//
//  UIColor+.swift
//  30ZF
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 myname. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

	// 简化RGB颜色生成
	class func colorWithValues(values: [CGFloat]) -> UIColor {
		return UIColor(red: values[0]/255, green: values[1]/255, blue: values[2]/255, alpha: values[3])
	}
}