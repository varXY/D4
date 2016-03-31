//
//  LeanCloud.swift
//  D4
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import AVOSCloud

class LeanCloud {

	var objectKey = ""

	func test() {
		let post = AVObject(className: "TestClassName")
		post.setObject([10, 12, 55], forKey: "Test_1")
		post.saveInBackgroundWithBlock { (success, error) in
			print(success)
			print(post.objectId)
			self.objectKey = post.objectId


		}
	}

	func getQuery() {
		let query = AVQuery(className: "TestClassName")
		query.getObjectInBackgroundWithId(objectKey) { (object, error) in

			if error == nil {
				print("nil")
			}

			guard let value1 = object.objectForKey("Test_1") else { return }
			print(value1)

			if let value0 = object.objectForKey("Test_1") as? [Int] {
				print(value0)
			}

			print(object.createdAt)

			if let value = object.valueForKey("Likes") {
				print("Get \(value) Likes")
			}

			//			object.deleteInBackground()
		}

	}

	func findObject() {
		let query = AVQuery(className: "TestClassName")
		query.whereKey("Test_0", equalTo: "4")
		query.findObjectsInBackgroundWithBlock { (objects, error) in
			if objects.count != 0 {
				print(objects.count)

				var index = 0
				repeat {
					print(objects[index].objectId)
					index += 1
				} while index < objects.count
			}
		}
	}

	func updateLikes() {
		let post = AVObject(className: "TestClassName")
		post.setObject(0, forKey: "Likes")
		post.saveInBackgroundWithBlock { (success, error) in
			if error == nil && success {
				post.incrementKey("Likes")
				post.fetchWhenSave = true
				post.saveInBackground()

				self.objectKey = post.objectId

				print(post.objectForKey("Likes"))
			}
		}
	}
}