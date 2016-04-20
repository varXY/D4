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
	let date: NSDate
	let sentences: [String]
	let colors: [Int]
	var rating: Int
	let author: String

	init(id: String, date: NSDate, sentences: [String], colors: [Int], rating: Int, author: String) {
		self.ID = id
		self.date = date
		self.sentences = sentences
		self.colors = colors
		self.rating = rating
		self.author = author
	}

	init(date: NSDate, sentences: [String], colors: [Int], rating: Int, author: String) {
		self.date = date
		self.sentences = sentences
		self.colors = colors
		self.rating = rating
		self.author = author
	}

	init(object: AVObject) {
		ID = object.objectId
		date = object.createdAt
		sentences = object.objectForKey(AVKey.sentences) as! [String]
		colors = object.objectForKey(AVKey.colors) as! [Int]
		rating = object.objectForKey(AVKey.rating) as! Int
		author = object.objectForKey(AVKey.author) as! String
	}

	init(sentences: [String], colors: [Int]) {
		date = NSDate()
		self.sentences = sentences
		self.colors = colors
		rating = 0
	
		let userDefaults = NSUserDefaults.standardUserDefaults()
		if let storedAuthor = userDefaults.stringForKey(UDKey.Author) {
			author = storedAuthor
		} else {
			let deviceID = UIDevice.currentDevice().identifierForVendor?.UUIDString
			author = sentences[0] + date.string(.MMddyy) + "&" + deviceID!
			saveAuthor(author)
		}
	}

}