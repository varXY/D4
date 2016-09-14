//
//  UIColor+.swift
//  30ZF
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 myname. All rights reserved.
//

import UIKit

extension UIColor {

	class func colorWithValues(_ values: [CGFloat]) -> UIColor {
		return UIColor(red: values[0]/255, green: values[1]/255, blue: values[2]/255, alpha: values[3])
	}

	class func backgroundColor() -> UIColor {
		return UIColor(red: 236/255, green: 235/255, blue: 243/255, alpha: 1.0)
	}
}
