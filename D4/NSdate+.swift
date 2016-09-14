//
//  NSdate+.swift
//  D4
//
//  Created by 文川术 on 4/13/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation

extension Date {

	enum Fomatter: String {
		case MMddyy = "MM/dd/yy"
		case HH = "HH"
		case dd = "dd"
		case MMddyyHHmm = "MM/dd/yy, HH:mm"
		case HHmm = "HH:mm"
		case MMdd = "MM/dd"
	}

	func string(_ fomatter: Fomatter) -> String {
		let dateFomatter = DateFormatter()
		dateFomatter.dateFormat = fomatter.rawValue
		let stringDate = dateFomatter.string(from: self)
		return stringDate
	}

	static func getDateWithString(_ string: String) -> Date {
		let dateFomatter = DateFormatter()
		dateFomatter.dateFormat = Fomatter.MMddyyHHmm.rawValue
		let date = dateFomatter.date(from: string + ", 00:00")!
		return date
	}

	static func specificDate(tomorrow: Bool, HH: String) -> Date {
		let dateFomatter = DateFormatter()
		dateFomatter.dateFormat = Fomatter.MMddyyHHmm.rawValue
		let day = tomorrow ? Date(timeIntervalSinceNow: 86400) : Date()
		let specificDate = dateFomatter.date(from: day.string(.MMddyy) + ", " + HH + ":00")!
		return specificDate
	}
}
