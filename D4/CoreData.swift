//
//  CoreData.swift
//  D4
//
//  Created by 文川术 on 4/10/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit
import CoreData


protocol CoreDataAndStory {
	func saveMyStory(story: Story, completion: (Bool) -> ())
	func getMyStorys(completion: ([Story]) -> ())

	func save100DailyStorys(storys: [Story], completion: (Bool) -> ())
	func load100DailyStorys(completion: ([Story]) -> ())
}

extension CoreDataAndStory {

	func saveMyStory(story: Story, completion: (Bool) -> ()) {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext

		let entity_0 = NSEntityDescription.entityForName("Sentences", inManagedObjectContext: managedContext)
		let sentences = Sentences(entity: entity_0!, insertIntoManagedObjectContext: managedContext)
		sentences.s0 = story.sentences[0]
		sentences.s1 = story.sentences[1]
		sentences.s2 = story.sentences[2]
		sentences.s3 = story.sentences[3]
		sentences.s4 = story.sentences[4]

		let entity_1 = NSEntityDescription.entityForName("Colors", inManagedObjectContext: managedContext)
		let colors = Colors(entity: entity_1!, insertIntoManagedObjectContext: managedContext)
		colors.c0 = story.colors[0]
		colors.c1 = story.colors[1]
		colors.c2 = story.colors[2]
		colors.c3 = story.colors[3]
		colors.c4 = story.colors[4]

		let entity_2 = NSEntityDescription.entityForName("MyStory", inManagedObjectContext: managedContext)
		let myStory = MyStory(entity: entity_2!, insertIntoManagedObjectContext: managedContext)
		myStory.date = story.date
		myStory.rating = story.rating
		myStory.author = story.author
		myStory.sentences = sentences
		myStory.colors = colors

		do {
			try managedContext.save()
			completion(true)
		} catch {
			completion(false)
		}
	}


	func getMyStorys(completion: ([Story]) -> ()) {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext

		let fetchRequest = NSFetchRequest(entityName: "MyStory")
		fetchRequest.entity = NSEntityDescription.entityForName("MyStory", inManagedObjectContext: managedContext)
		var storys = [Story]()

		do {
			let fetchResults = try managedContext.executeFetchRequest(fetchRequest)
			if let myStorys = fetchResults as? [MyStory] {
				
				if myStorys.count != 0 {
					storys = myStorys.map({
						let sentences = [$0.sentences!.s0!, $0.sentences!.s1!, $0.sentences!.s2!, $0.sentences!.s3!, $0.sentences!.s4!]
						let colors = [$0.colors!.c0! as Int, $0.colors!.c1! as Int, $0.colors!.c2! as Int, $0.colors!.c3! as Int, $0.colors!.c4! as Int]
						let story = Story(date: $0.date!, sentences: sentences, colors: colors, rating: $0.rating! as Int, author: $0.author!)
						return story
					})
					storys = storys.reverse()

				} else {
					print("no story yet")
				}

				completion(storys)

			}

		} catch {
			print("can't get my storys")
		}
	}

	func save100DailyStorys(storys: [Story], completion: (Bool) -> ()) {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext

		let fetchRequest = NSFetchRequest(entityName: "DailyStory")
		fetchRequest.entity = NSEntityDescription.entityForName("DailyStory", inManagedObjectContext: managedContext)

		do {
			let oldStorys = try managedContext.executeFetchRequest(fetchRequest)
			if oldStorys.count != 0 {
				oldStorys.forEach({ managedContext.deleteObject($0 as! NSManagedObject) })
			}
		} catch {
			print("can't get old storys")
		}

		var success = true
		let _: [DailyStory] = storys.map({
			let entity_0 = NSEntityDescription.entityForName("Sentences", inManagedObjectContext: managedContext)
			let sentences = Sentences(entity: entity_0!, insertIntoManagedObjectContext: managedContext)
			sentences.s0 = $0.sentences[0]
			sentences.s1 = $0.sentences[1]
			sentences.s2 = $0.sentences[2]
			sentences.s3 = $0.sentences[3]
			sentences.s4 = $0.sentences[4]

			let entity_1 = NSEntityDescription.entityForName("Colors", inManagedObjectContext: managedContext)
			let colors = Colors(entity: entity_1!, insertIntoManagedObjectContext: managedContext)
			colors.c0 = $0.colors[0]
			colors.c1 = $0.colors[1]
			colors.c2 = $0.colors[2]
			colors.c3 = $0.colors[3]
			colors.c4 = $0.colors[4]

			let entity_2 = NSEntityDescription.entityForName("DailyStory", inManagedObjectContext: managedContext)
			let dailyStory = DailyStory(entity: entity_2!, insertIntoManagedObjectContext: managedContext)
			dailyStory.id = $0.ID
			dailyStory.date = $0.date
			dailyStory.rating = $0.rating
			dailyStory.author = $0.author
			dailyStory.sentences = sentences
			dailyStory.colors = colors

			do {
				try managedContext.save()
			} catch {
				print("can't save")
				success = false
			}

			return dailyStory
		})

		completion(success)

	}

	func load100DailyStorys(completion: ([Story]) -> ()) {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext

		let fetchRequest = NSFetchRequest(entityName: "DailyStory")
		fetchRequest.entity = NSEntityDescription.entityForName("DailyStory", inManagedObjectContext: managedContext)

		var storys = [Story]()

		do {
			let results = try managedContext.executeFetchRequest(fetchRequest)
			if let dailyStorys = results as? [DailyStory] {
				if dailyStorys.count != 0 {
					storys = dailyStorys.map({
						let sentences = [$0.sentences!.s0!, $0.sentences!.s1!, $0.sentences!.s2!, $0.sentences!.s3!, $0.sentences!.s4!]
						let colors = [$0.colors!.c0! as Int, $0.colors!.c1! as Int, $0.colors!.c2! as Int, $0.colors!.c3! as Int, $0.colors!.c4! as Int]
						let story = Story(id: $0.id!, date: $0.date!, sentences: sentences, colors: colors, rating: $0.rating! as Int, author: $0.author!)
						return story
					})
				}
			}

			completion(storys)

		} catch {
			print("can't load storys from coreData")
		}
	}

}




