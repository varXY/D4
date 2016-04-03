//
//  Story.swift
//  D4
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import AVOSCloud


struct Story {

	let date: NSDate
	let sentences: [String]
	let colors: [Int]
	let rating: Int
	let auther: String

	init(object: AVObject) {
		date = object.createdAt
		sentences = object.objectForKey(AVKey.sentences) as! [String]
		colors = object.objectForKey(AVKey.colors) as! [Int]
		rating = object.objectForKey(AVKey.rating) as! Int
		auther = object.objectForKey(AVKey.auther) as! String
	}

	init(sentences: [String], colors: [Int]) {
		date = NSDate()
		self.sentences = sentences
		self.colors = colors
		rating = 0
		auther = "56fe08e479bc4400523bc0c3"
	}

}