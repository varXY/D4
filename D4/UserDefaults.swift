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
	static let LikedStoryIndexes = "LikedStoryIndexes"
	static let LastStoryID = "LastStoryID"
}

protocol UserDefaults {
	var userDefaults: NSUserDefaults { get }

	func saveAuthor(author: String)
	func getAuthor() -> String

	func updateLastWriteDate(date: NSDate)
	func lastWriteDate() -> NSDate

	func updateLastLoadDate(date: NSDate)
	func lastLoadDate() -> NSDate

	func saveLastStory(story: Story)
	func getLastStory() -> Story

	func saveLikedStoryIndex(index: Int)
	func likedStoryIndexes() -> [Int]
	func removeAllLikedStoryIndexes()

	func saveLastStoryID(ID: String)
	func getLastStoryID() -> String
}

extension UserDefaults {

	var userDefaults: NSUserDefaults {
		return NSUserDefaults.standardUserDefaults()
	}


	func saveAuthor(author: String) {
		userDefaults.setObject(author, forKey: UDKey.Author)
		userDefaults.synchronize()
	}

	func getAuthor() -> String {
		guard let author = userDefaults.stringForKey(UDKey.Author) else { return "" }
		return author
	}


	func updateLastWriteDate(date: NSDate) {
		userDefaults.setObject(date, forKey: UDKey.LastWriteDate)
		userDefaults.synchronize()
	}

	func lastWriteDate() -> NSDate {
		guard let date = userDefaults.objectForKey(UDKey.LastWriteDate) as? NSDate else {
			return NSDate(timeInterval: -86400, sinceDate: NSDate())
		}

		return date
	}


	func updateLastLoadDate(date: NSDate) {
		userDefaults.setObject(date, forKey: UDKey.LastLoadDate)
		userDefaults.synchronize()
	}

	func lastLoadDate() -> NSDate {
		guard let date = userDefaults.objectForKey(UDKey.LastLoadDate) as? NSDate else { return NSDate().earlierDate(NSDate()) }
		return date
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


	func saveLikedStoryIndex(index: Int) {
		guard let likes = userDefaults.objectForKey(UDKey.LikedStoryIndexes) as? [Int] else { return }
		let newLikes = likes + [index]
		userDefaults.setObject(newLikes, forKey: UDKey.LikedStoryIndexes)
		userDefaults.synchronize()
	}

	func likedStoryIndexes() -> [Int] {
		guard let likes = userDefaults.objectForKey(UDKey.LikedStoryIndexes) as? [Int] else { return [Int]() }
		return likes
	}

	func removeAllLikedStoryIndexes() {
		userDefaults.setObject([Int](), forKey: UDKey.LikedStoryIndexes)
		userDefaults.synchronize()
	}



	func saveLastStoryID(ID: String) {
		userDefaults.setObject(ID, forKey: UDKey.LastStoryID)
		userDefaults.synchronize()
	}

	func getLastStoryID() -> String {
		guard let ID = userDefaults.stringForKey(UDKey.LastStoryID) else { return "" }
		return ID
	}

}



