//
//  NSdate+.swift
//  D4
//
//  Created by 文川术 on 4/13/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation


extension NSDate {

	enum Fomatter: String {
		case MMddyy = "MM/dd/yy"
		case HH = "HH"
		case dd = "dd"
		case MMddyyHHmm = "MM/dd/yy, HH:mm"
		case HHmm = "HH:mm"
		case MMdd = "MM/dd"
	}

	func string(fomatter: Fomatter) -> String {
		let dateFomatter = NSDateFormatter()
		dateFomatter.dateFormat = fomatter.rawValue
		let stringDate = dateFomatter.stringFromDate(self)
		return stringDate
	}
}