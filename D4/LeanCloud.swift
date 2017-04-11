//
//  LeanCloud.swift
//  D4
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import AVOSCloud

typealias Completion = (Bool?, NSError?) -> Void
typealias GotStorys = ([Story]) -> Void

struct AVKey {
	static let classStory = "Story"
	static let sentences = "Sentences"
	static let colors = "Colors"
	static let rating = "Rating"
	static let author = "Author"
	static let date = "createdAt"

	static let classAuthor = "C_Author"
}

protocol LeanCloud: UserDefaults {
	func uploadStory(_ story: Story, completion: @escaping Completion)
	func getDailyStory(_ gotStorys: @escaping GotStorys)
	func updateRating(_ ID: String, rating: Int, done: @escaping (Bool) -> ())
}

extension LeanCloud {

	func uploadStory(_ story: Story, completion: @escaping Completion) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		let object = AVObject(className: AVKey.classStory)
		object?.setObject(story.sentences, forKey: AVKey.sentences)
		object?.setObject(story.colors, forKey: AVKey.colors)
		object?.setObject(story.rating, forKey: AVKey.rating)
		object?.setObject(story.author, forKey: AVKey.author)

		object?.saveInBackground { (success, error) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			if success { self.saveLastStoryID((object?.objectId)!) }
			completion(success, error as NSError?)
		}
	}

	func getDailyStory(_ gotStorys: @escaping GotStorys) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		var storys = [Story]()

		let today = Date()
		let stringToday = today.string(.MMddyy)
		let trueToday = Date.getDateWithString(stringToday)

		let query = AVQuery(className: AVKey.classStory)
		query?.order(byDescending: AVKey.date)
		query?.limit = 50
		query?.whereKey("createdAt", greaterThan: trueToday)
		query?.findObjectsInBackground { (results, error) in
			if let objects = results as? [AVObject] {
				let filteredObjects = objects.filter({ self.testObject($0) == true })
				storys = results?.count != 0 ? filteredObjects.map({ Story(object: $0) }) : [Story]()

				let myStory = self.getSelfLastOneStory()

				self.get49bestStorysOfyesterday({ (bestStorys) in
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
					let story100 = self.mergeThree(storys, array_1: bestStorys, myStory: myStory)
					print(story100.count)
					if story100.count <= 20 {
						self.getAllStory({ (storys) in
							gotStorys(storys)
						})
					} else {
						gotStorys(story100)
					}

				})
			}

			if error != nil {
				print(error!)
				gotStorys([Story]())
			}

		}

	}

	func getSelfLastOneStory() -> Story? {
		let ID = getLastStoryID()
		let query = AVQuery(className: AVKey.classStory)
		guard let object = query?.getObjectWithId(ID) else { return nil }
		return Story(object: object)
	}

	func get49bestStorysOfyesterday(_ gotStorys: @escaping GotStorys) {
		var storys = [Story]()

		let yesterday = Date(timeIntervalSinceNow: -86400)
		let stringYesterday = yesterday.string(.MMddyy)
		let trueyesterday = Date.getDateWithString(stringYesterday)

		let today = Date()
		let stringToday = today.string(.MMddyy)
		let trueToday = Date.getDateWithString(stringToday)

		let query = AVQuery(className: AVKey.classStory)
		query?.whereKey("createdAt", lessThan: trueToday)
		query?.whereKey("createdAt", greaterThan: trueyesterday)
		query?.addDescendingOrder(AVKey.rating)
		query?.limit = 49
		query?.findObjectsInBackground { (results, error) in
			if let objects = results as? [AVObject] {
				if results?.count != 0 {
					let filteredObjects = objects.filter({ self.testObject($0) == true })
					storys = filteredObjects.map({ Story(object: $0) })
				}
				gotStorys(storys)
			} else {
				gotStorys([Story]())
			}

			if error != nil {
				print(error!)
				gotStorys([Story]())
			}
			
		}

	}

	func getAllStory(_ gotStorys: @escaping GotStorys) {
		var storys = [Story]()

		let query = AVQuery(className: AVKey.classStory)
		query?.order(byDescending: AVKey.date)
		query?.findObjectsInBackground { (results, error) in
			if let objects = results as? [AVObject] {
				if results?.count != 0 {
					let filteredObjects = objects.filter({ self.testObject($0) == true })
					storys = filteredObjects.map({ Story(object: $0) })
				}
			}

			gotStorys(storys)

		}
	}

	func updateRating(_ ID: String, rating: Int, done: @escaping (Bool) -> ()) {
		let story = AVObject(outDataWithClassName: AVKey.classStory, objectId: ID)
		story?.setObject(rating, forKey: AVKey.rating)
		story?.saveInBackground { (success, error) in
			if error != nil { print(error!) }
			done(success)
		}
	}

	// MARK: - Tools

	func testObject(_ object: AVObject) -> Bool {
		let A = object.createdAt != nil
		let B = object.object(forKey: AVKey.sentences) != nil
		let C = object.object(forKey: AVKey.colors) != nil
		let D = object.object(forKey: AVKey.rating) != nil
		let E = object.object(forKey: AVKey.author) != nil

		return A && B && C && D && E
	}

	func mergeThree(_ array_0: [Story], array_1: [Story], myStory: Story?) -> [Story]{
		var newArray = [Story]()
		var i = 0

		if array_1.count != 0 {
			if array_0.count >= array_1.count {
				repeat {
					if i < array_1.count { newArray.append(array_1[i]) }
					newArray.append(array_0[i])
					i += 1
				} while i < array_0.count

			} else {
				repeat {
					newArray.append(array_1[i])
					if i < array_0.count { newArray.append(array_0[i]) }
					i += 1
				} while i < array_1.count
				
			}
		} else {
			newArray += array_0
		}

		if myStory != nil {
			let randomIndex = newArray.count != 0 ? Int(arc4random_uniform(UInt32(newArray.count))) : 0
			newArray.insert(myStory!, at: randomIndex)
		}

		return newArray
	}


}
