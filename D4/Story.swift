//
//  Story.swift
//  D4
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import AVOSCloud

struct Story: UserDefaults {

	var ID = "No"
	let date: Date
	let sentences: [String]
	let colors: [Int]
	var rating: Int
	let author: String

	init(id: String, date: Date, sentences: [String], colors: [Int], rating: Int, author: String) {
		self.ID = id
		self.date = date
		self.sentences = sentences
		self.colors = colors
		self.rating = rating
		self.author = author
	}

	init(date: Date, sentences: [String], colors: [Int], rating: Int, author: String) {
		self.date = date
		self.sentences = sentences
		self.colors = colors
		self.rating = rating
		self.author = author
	}

	init(object: AVObject) {
		ID = object.objectId
		date = object.createdAt
		sentences = object.object(forKey: AVKey.sentences) as! [String]
		colors = object.object(forKey: AVKey.colors) as! [Int]
		rating = object.object(forKey: AVKey.rating) as! Int
		author = object.object(forKey: AVKey.author) as! String
	}

	init(sentences: [String], colors: [Int]) {
		date = Date()
		self.sentences = sentences
		self.colors = colors
		rating = 0
	
		let userDefaults = Foundation.UserDefaults.standard
		if let storedAuthor = userDefaults.string(forKey: UDKey.Author) {
			author = storedAuthor
		} else {
			let deviceID = UIDevice.current.identifierForVendor?.uuidString
			author = sentences[0] + date.string(.MMddyy) + "&" + deviceID!
			saveAuthor(author)
		}
	}

}
