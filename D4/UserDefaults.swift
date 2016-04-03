//
//  UserDefaults.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation

struct UDKey {
	static let Author = "Author"
	static let LastWriteDate = "LastWriteDate"
	static let LastLoadDate = "LastLoadDate"
}

protocol UserDefaults {
	var userDefaults: NSUserDefaults { get }

	func author() -> String?
	func lastWriteDate() -> NSDate
	func lastLoadDate() -> NSDate
//	func lastStory() -> Story

	func saveAuthor(author: String)
	func updateLastWriteDate(date: NSDate)
	func updateLastLoadDate(date: NSDate)
//	func saveLastStory(story: Story)
}

extension UserDefaults {

	var userDefaults: NSUserDefaults {
		return NSUserDefaults.standardUserDefaults()
	}

	func author() -> String? {
		guard let author = userDefaults.stringForKey(UDKey.Author) else { return nil }
		return author
	}

	func lastWriteDate() -> NSDate {
		guard let date = userDefaults.objectForKey(UDKey.LastWriteDate) as? NSDate else { return NSDate() }
		return date
	}

	func lastLoadDate() -> NSDate {
		guard let date = userDefaults.objectForKey(UDKey.LastLoadDate) as? NSDate else { return NSDate() }
		return date
	}

//	func lastStory() -> Story {
//
//	}

	func saveAuthor(author: String) {

	}

	func updateLastWriteDate(date: NSDate) {

	}

	func updateLastLoadDate(date: NSDate) {

	}

//	func saveLastStory(story: Story) {
//
//	}
}



