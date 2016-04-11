//
//  UserDefaults.swift
//  D4
//
//  Created by 文川术 on 4/3/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation

struct UDKey {
	static let Author = "UDAuthor"
	static let LastWriteDate = "LastWriteDate"
	static let LastLoadDate = "LastLoadDate"
}

protocol UserDefaults {
	var userDefaults: NSUserDefaults { get }

	func saveAuthor(author: String)
	func getAuthor() -> String?

	func updateLastWriteDate(date: NSDate)
	func lastWriteDate() -> NSDate

	func updateLastLoadDate(date: NSDate)
	func lastLoadDate() -> NSDate

	func saveLastStory(story: Story)
	func getLastStory() -> Story
}

extension UserDefaults {

	var userDefaults: NSUserDefaults {
		return NSUserDefaults.standardUserDefaults()
	}

	func getAuthor() -> String? {
		guard let author = userDefaults.stringForKey(UDKey.Author) else { return nil }
		return author
	}

	func lastWriteDate() -> NSDate {
		guard let date = userDefaults.objectForKey(UDKey.LastWriteDate) as? NSDate else {
			return NSDate(timeInterval: -86400, sinceDate: NSDate())
		}

		return date
	}

	func lastLoadDate() -> NSDate {
		guard let date = userDefaults.objectForKey(UDKey.LastLoadDate) as? NSDate else { return NSDate().earlierDate(NSDate()) }
		return date
	}



	func saveAuthor(author: String) {
		userDefaults.setObject(author, forKey: UDKey.Author)
		userDefaults.synchronize()
	}

	func updateLastWriteDate(date: NSDate) {
		userDefaults.setObject(date, forKey: UDKey.LastWriteDate)
		userDefaults.synchronize()
	}

	func updateLastLoadDate(date: NSDate) {
		userDefaults.setObject(date, forKey: UDKey.LastLoadDate)
		userDefaults.synchronize()
	}

	func saveLastStory(story: Story) {
		userDefaults.setObject(story.date, forKey: AVKey.date)
		userDefaults.setObject(story.rating, forKey: AVKey.rating)
		userDefaults.setObject(story.author, forKey: AVKey.author)
		userDefaults.setObject(story.sentences, forKey: AVKey.sentences)
		userDefaults.setObject(story.colors, forKey: AVKey.colors)
		userDefaults.synchronize()
	}

	func getLastStory() -> Story {
		let date = userDefaults.objectForKey(AVKey.date) as! NSDate
		let rating = userDefaults.objectForKey(AVKey.rating) as! Int
		let author = userDefaults.objectForKey(AVKey.author) as! String
		let sentences = userDefaults.objectForKey(AVKey.sentences) as! [String]
		let colors = userDefaults.objectForKey(AVKey.colors) as! [Int]

		let story = Story(date: date, sentences: sentences, colors: colors, rating: rating, author: author)
		return story
	}


}



