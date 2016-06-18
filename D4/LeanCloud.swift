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
typealias GotStorys = [Story] -> Void

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
	func uploadStory(story: Story, completion: Completion)
	func getDailyStory(gotStorys: GotStorys)
	func updateRating(ID: String, rating: Int, done: (Bool) -> ())
}

extension LeanCloud {

	func uploadStory(story: Story, completion: Completion) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		let object = AVObject(className: AVKey.classStory)
		object.setObject(story.sentences, forKey: AVKey.sentences)
		object.setObject(story.colors, forKey: AVKey.colors)
		object.setObject(story.rating, forKey: AVKey.rating)
		object.setObject(story.author, forKey: AVKey.author)

		object.saveInBackgroundWithBlock { (success, error) in
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			if success { self.saveLastStoryID(object.objectId) }
			completion(success, error)
		}
	}

	func getDailyStory(gotStorys: GotStorys) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		var storys = [Story]()

		let today = NSDate()
		let stringToday = today.string(.MMddyy)
		let trueToday = NSDate.getDateWithString(stringToday)

		let query = AVQuery(className: AVKey.classStory)
		query.orderByDescending(AVKey.date)
		query.limit = 50
		query.whereKey("createdAt", greaterThan: trueToday)
		query.findObjectsInBackgroundWithBlock { (results, error) in
			if let objects = results as? [AVObject] {
				let filteredObjects = objects.filter({ self.testObject($0) == true })
				storys = results.count != 0 ? filteredObjects.map({ Story(object: $0) }) : [Story]()

				let myStory = self.getSelfLastOneStory()

				self.get49bestStorysOfyesterday({ (bestStorys) in
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
					let story100 = self.mergeThree(storys, array_1: bestStorys, myStory: myStory)
					print(story100.count)
					if story100.count <= 16 {
						self.getAllStory({ (storys) in
							gotStorys(storys)
						})
					} else {
						gotStorys(story100)
					}

				})
			}

			if error != nil {
				print(error)
				gotStorys([Story]())
			}

		}

	}

	func getSelfLastOneStory() -> Story? {
		let ID = getLastStoryID()
		let query = AVQuery(className: AVKey.classStory)
		guard let object = query.getObjectWithId(ID) else { return nil }
		return Story(object: object)
	}

	func get49bestStorysOfyesterday(gotStorys: GotStorys) {
		var storys = [Story]()

		let yesterday = NSDate(timeIntervalSinceNow: -86400)
		let stringYesterday = yesterday.string(.MMddyy)
		let trueyesterday = NSDate.getDateWithString(stringYesterday)

		let today = NSDate()
		let stringToday = today.string(.MMddyy)
		let trueToday = NSDate.getDateWithString(stringToday)

		let query = AVQuery(className: AVKey.classStory)
		query.whereKey("createdAt", lessThan: trueToday)
		query.whereKey("createdAt", greaterThan: trueyesterday)
		query.addDescendingOrder(AVKey.rating)
		query.limit = 49
		query.findObjectsInBackgroundWithBlock { (results, error) in
			if let objects = results as? [AVObject] {
				if results.count != 0 {
					let filteredObjects = objects.filter({ self.testObject($0) == true })
					storys = filteredObjects.map({ Story(object: $0) })
				}
				gotStorys(storys)
			} else {
				gotStorys([Story]())
			}

			if error != nil {
				print(error)
				gotStorys([Story]())
			}
			
		}

	}

	func getAllStory(gotStorys: GotStorys) {
		var storys = [Story]()

		let query = AVQuery(className: AVKey.classStory)
		query.orderByDescending(AVKey.date)
		query.findObjectsInBackgroundWithBlock { (results, error) in
			if let objects = results as? [AVObject] {
				if results.count != 0 {
					let filteredObjects = objects.filter({ self.testObject($0) == true })
					storys = filteredObjects.map({ Story(object: $0) })
				}
			}

			gotStorys(storys)

		}
	}

	func updateRating(ID: String, rating: Int, done: (Bool) -> ()) {
		let story = AVObject(outDataWithClassName: AVKey.classStory, objectId: ID)
		story.setObject(rating, forKey: AVKey.rating)
		story.saveInBackgroundWithBlock { (success, error) in
			if error != nil { print(error) }
			done(success)
		}
	}

	// MARK: - Tools

	func testObject(object: AVObject) -> Bool {
		let A = object.createdAt != nil
		let B = object.objectForKey(AVKey.sentences) != nil
		let C = object.objectForKey(AVKey.colors) != nil
		let D = object.objectForKey(AVKey.rating) != nil
		let E = object.objectForKey(AVKey.author) != nil

		return A && B && C && D && E
	}

	func mergeThree(array_0: [Story], array_1: [Story], myStory: Story?) -> [Story]{
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
			let randomIndex = newArray.count != 0 ? random() % newArray.count : 0
			newArray.insert(myStory!, atIndex: randomIndex)
		}

		return newArray
	}


}

//class LeanCloud {
//
//	var objectKey = ""
//
//	func test() {
//		let post = AVObject(className: "TestClassName")
//		post.setObject([10, 12, 55], forKey: "Test_1")
//		post.saveInBackgroundWithBlock { (success, error) in
//			print(success)
//			print(post.objectId)
//			self.objectKey = post.objectId
//
//
//		}
//	}
//
//	func getQuery() {
//		let query = AVQuery(className: "TestClassName")
//		query.getObjectInBackgroundWithId(objectKey) { (object, error) in
//
//			if error == nil {
//				print("nil")
//			}
//
//			guard let value1 = object.objectForKey("Test_1") else { return }
//			print(value1)
//
//			if let value0 = object.objectForKey("Test_1") as? [Int] {
//				print(value0)
//			}
//
//			print(object.createdAt)
//
//			if let value = object.valueForKey("Likes") {
//				print("Get \(value) Likes")
//			}
//
//			//			object.deleteInBackground()
//		}
//
//	}
//
//	func findObject() {
//		let query = AVQuery(className: "TestClassName")
//		query.whereKey("Test_0", equalTo: "4")
//		query.findObjectsInBackgroundWithBlock { (objects, error) in
//			if objects.count != 0 {
//				print(objects.count)
//
//				var index = 0
//				repeat {
//					print(objects[index].objectId)
//					index += 1
//				} while index < objects.count
//			}
//		}
//	}
//
//	func updateLikes() {
//		let post = AVObject(className: "TestClassName")
//		post.setObject(0, forKey: "Likes")
//		post.saveInBackgroundWithBlock { (success, error) in
//			if error == nil && success {
//				post.incrementKey("Likes")
//				post.fetchWhenSave = true
//				post.saveInBackground()
//
//				self.objectKey = post.objectId
//
//				print(post.objectForKey("Likes"))
//			}
//		}
//	}
//}