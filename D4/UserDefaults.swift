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

	static let notificationIndex = "NotificationIndex"
	static let askedAllowNotification = "AskedAllowNotification"
}

protocol UserDefaults {
	var userDefaults: Foundation.UserDefaults { get }

	func saveAuthor(_ author: String)
	func getAuthor() -> String

	func updateLastWriteDate(_ date: Date)
	func lastWriteDate() -> Date

	func tip_A_shown() -> Bool
	func tip_B_shown() -> Bool
	func saveTip_A_asShown()
	func saveTip_B_asShown()

	func updateLastLoadDate(_ date: Date)
	func lastLoadDate() -> Date

	func saveSentencesAndColors(_ sentences: [String], colors: [Int])
	func getSentences() -> [String]?
	func getColors() -> [Int]?
	func removeSentencesAndColors()

	func saveLikedStoryIndex(_ index: Int)
	func removeLikedStoryIndex(_ index: Int)
	func likedStoryIndexes() -> [Int]
	func removeAllLikedStoryIndexes()

	func saveLastStoryID(_ ID: String)
	func getLastStoryID() -> String

	func saveNotificationIndex(_ index: Int)
	func getNotificationIndex() -> Int

	func saveAskedAllowNotification(_ allow: Bool)
	func getAskedAllowNotification() -> Bool
}

extension UserDefaults {

	var userDefaults: Foundation.UserDefaults {
		return Foundation.UserDefaults.standard
	}

	var yesterday: Date {
		let yesterday = Date(timeIntervalSinceNow: -86400)
		let stringYesterday = yesterday.string(.MMddyy)
		return Date.getDateWithString(stringYesterday)
	}

	func saveAuthor(_ author: String) {
		userDefaults.set(author, forKey: UDKey.Author)
		userDefaults.synchronize()
	}

	func getAuthor() -> String {
		guard let author = userDefaults.string(forKey: UDKey.Author) else { return "" }
		return author
	}


	func updateLastWriteDate(_ date: Date) {
		userDefaults.set(date, forKey: UDKey.LastWriteDate)
		userDefaults.synchronize()
	}

	func lastWriteDate() -> Date {
		guard let date = userDefaults.object(forKey: UDKey.LastWriteDate) as? Date else { return yesterday }
		return date
	}

	func tip_A_shown() -> Bool {
		guard let shown = userDefaults.object(forKey: UDKey.TipA) as? Bool else { return false }
		return shown
	}

	func tip_B_shown() -> Bool {
		guard let shown = userDefaults.object(forKey: UDKey.TipB) as? Bool else { return false }
		return shown
	}

	func saveTip_A_asShown() {
		userDefaults.set(true, forKey: UDKey.TipA)
		userDefaults.synchronize()
	}

	func saveTip_B_asShown() {
		userDefaults.set(true, forKey: UDKey.TipB)
		userDefaults.synchronize()
	}


	func updateLastLoadDate(_ date: Date) {
		userDefaults.set(date, forKey: UDKey.LastLoadDate)
		userDefaults.synchronize()
	}

	func lastLoadDate() -> Date {
		guard let date = userDefaults.object(forKey: UDKey.LastLoadDate) as? Date else { return yesterday }
		return date
	}

	func saveSentencesAndColors(_ sentences: [String], colors: [Int]) {
		userDefaults.set(sentences, forKey: UDKey.Sentences)
		userDefaults.set(colors, forKey: UDKey.Colors)
		userDefaults.synchronize()
	}

	func getSentences() -> [String]? {
		return userDefaults.object(forKey: UDKey.Sentences) as? [String]
	}

	func getColors() -> [Int]? {
		return userDefaults.object(forKey: UDKey.Colors) as? [Int]
	}

	func removeSentencesAndColors() {
		userDefaults.set(nil, forKey: UDKey.Sentences)
		userDefaults.set(nil, forKey: UDKey.Colors)
		userDefaults.synchronize()
	}


	func saveLikedStoryIndex(_ index: Int) {
		guard let likes = userDefaults.object(forKey: UDKey.LikedStoryIndexes) as? [Int] else { return }
		let newLikes = likes + [index]
		userDefaults.set(newLikes, forKey: UDKey.LikedStoryIndexes)
		userDefaults.synchronize()
	}

	func removeLikedStoryIndex(_ index: Int) {
		guard let likes = userDefaults.object(forKey: UDKey.LikedStoryIndexes) as? [Int] else { return }
		let newLikes = likes.filter({ $0 != index })
		userDefaults.set(newLikes, forKey: UDKey.LikedStoryIndexes)
		userDefaults.synchronize()
	}

	func likedStoryIndexes() -> [Int] {
		guard let likes = userDefaults.object(forKey: UDKey.LikedStoryIndexes) as? [Int] else { return [Int]() }
		return likes
	}

	func removeAllLikedStoryIndexes() {
		userDefaults.set([Int](), forKey: UDKey.LikedStoryIndexes)
		userDefaults.synchronize()
	}



	func saveLastStoryID(_ ID: String) {
		userDefaults.set(ID, forKey: UDKey.LastStoryID)
		userDefaults.synchronize()
	}

	func getLastStoryID() -> String {
		guard let ID = userDefaults.string(forKey: UDKey.LastStoryID) else { return "" }
		return ID
	}

	func saveNotificationIndex(_ index: Int) {
		userDefaults.set(index, forKey: UDKey.notificationIndex)
		userDefaults.synchronize()
	}

	func getNotificationIndex() -> Int {
		guard let index = userDefaults.object(forKey: UDKey.notificationIndex) as? Int else { return 0 }
		return index
	}

	func saveAskedAllowNotification(_ allow: Bool) {
		userDefaults.set(allow, forKey: UDKey.askedAllowNotification)
		userDefaults.synchronize()
	}

	func getAskedAllowNotification() -> Bool {
		guard let allow = userDefaults.object(forKey: UDKey.askedAllowNotification) as? Bool else { return false }
		return allow
	}

}



