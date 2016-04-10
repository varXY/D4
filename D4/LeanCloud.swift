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
	func createAndSaveAuthor()
	func uploadStory(story: Story, completion: Completion)
	func getDailyStory(gotStorys: GotStorys)
}

extension LeanCloud {

	func createAndSaveAuthor() {
		if author() == nil {

		}
	}

	func uploadStory(story: Story, completion: Completion) {
		let object = AVObject(className: AVKey.classStory)
		object.setObject(story.sentences, forKey: AVKey.sentences)
		object.setObject(story.colors, forKey: AVKey.colors)
		object.setObject(story.rating, forKey: AVKey.rating)
		object.setObject(story.author, forKey: AVKey.author)

		object.saveInBackgroundWithBlock { (success, error) in
			completion(success, error)
		}
	}

	func getDailyStory(gotStorys: GotStorys) {
		var storys = [Story]()

		let query = AVQuery(className: AVKey.classStory)
		query.orderByAscending(AVKey.date)
//		query.addAscendingOrder(AVKey.)
		query.findObjectsInBackgroundWithBlock { (results, error) in
			if let objects = results as? [AVObject] {

				var index = 0
				repeat {
					let story = Story(object: objects[index])
					storys.insert(story, atIndex: 0)
					index += 1
				} while index < objects.count

				gotStorys(storys)

			}

			if error != nil {
				print(error)
			}


		}

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