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
	static let Sentences = "Sentences"
	static let Colors = "Colors"

	static let TipA = "TipA"
	static let TipB = "TipB"
}

protocol UserDefaults {
	var userDefaults: NSUserDefaults { get }

	func saveAuthor(author: String)
	func getAuthor() -> String

	func updateLastWriteDate(date: NSDate)
	func lastWriteDate() -> NSDate

	func tip_A_shown() -> Bool
	func tip_B_shown() -> Bool
	func saveTip_A_asShown()
	func saveTip_B_asShown()

	func updateLastLoadDate(date: NSDate)
	func lastLoadDate() -> NSDate

	func saveSentencesAndColors(sentences: [String], colors: [Int])
	func getSentences() -> [String]?
	func getColors() -> [Int]?
	func removeSentencesAndColors()

	func saveLikedStoryIndex(index: Int)
	func removeLikedStoryIndex(index: Int)
	func likedStoryIndexes() -> [Int]
	func removeAllLikedStoryIndexes()

	func saveLastStoryID(ID: String)
	func getLastStoryID() -> String
}

extension UserDefaults {

	var userDefaults: NSUserDefaults {
		return NSUserDefaults.standardUserDefaults()
	}

	var yesterday: NSDate {
		let yesterday = NSDate(timeIntervalSinceNow: -86400)
		let stringYesterday = yesterday.string(.MMddyy)
		return NSDate.getDateWithString(stringYesterday)
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
		guard let date = userDefaults.objectForKey(UDKey.LastWriteDate) as? NSDate else { return yesterday }
		return date
	}

	func tip_A_shown() -> Bool {
		guard let shown = userDefaults.objectForKey(UDKey.TipA) as? Bool else { return false }
		return shown
	}

	func tip_B_shown() -> Bool {
		guard let shown = userDefaults.objectForKey(UDKey.TipB) as? Bool else { return false }
		return shown
	}

	func saveTip_A_asShown() {
		userDefaults.setBool(true, forKey: UDKey.TipA)
		userDefaults.synchronize()
	}

	func saveTip_B_asShown() {
		userDefaults.setBool(true, forKey: UDKey.TipB)
		userDefaults.synchronize()
	}


	func updateLastLoadDate(date: NSDate) {
		userDefaults.setObject(date, forKey: UDKey.LastLoadDate)
		userDefaults.synchronize()
	}

	func lastLoadDate() -> NSDate {
		guard let date = userDefaults.objectForKey(UDKey.LastLoadDate) as? NSDate else { return yesterday }
		return date
	}

	func saveSentencesAndColors(sentences: [String], colors: [Int]) {
		userDefaults.setObject(sentences, forKey: UDKey.Sentences)
		userDefaults.setObject(colors, forKey: UDKey.Colors)
		userDefaults.synchronize()
	}

	func getSentences() -> [String]? {
		return userDefaults.objectForKey(UDKey.Sentences) as? [String]
	}

	func getColors() -> [Int]? {
		return userDefaults.objectForKey(UDKey.Colors) as? [Int]
	}

	func removeSentencesAndColors() {
		userDefaults.setObject(nil, forKey: UDKey.Sentences)
		userDefaults.setObject(nil, forKey: UDKey.Colors)
		userDefaults.synchronize()
	}


	func saveLikedStoryIndex(index: Int) {
		guard let likes = userDefaults.objectForKey(UDKey.LikedStoryIndexes) as? [Int] else { return }
		let newLikes = likes + [index]
		userDefaults.setObject(newLikes, forKey: UDKey.LikedStoryIndexes)
		userDefaults.synchronize()
	}

	func removeLikedStoryIndex(index: Int) {
		guard let likes = userDefaults.objectForKey(UDKey.LikedStoryIndexes) as? [Int] else { return }
		let newLikes = likes.filter({ $0 != index })
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



