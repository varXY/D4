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
		
		do {
			let fetchResults = try managedContext.executeFetchRequest(fetchRequest)
			if let myStorys = fetchResults as? [MyStory] {
				
				if myStorys.count != 0 {
					var i = myStorys.count - 1
					var storys = [Story]()
					repeat {
						let sentences: [String] = [
							myStorys[i].sentences!.s0!,
							myStorys[i].sentences!.s1!,
							myStorys[i].sentences!.s2!,
							myStorys[i].sentences!.s3!,
							myStorys[i].sentences!.s4!
						]

						let colors: [Int] = [
							myStorys[i].colors!.c0! as Int,
							myStorys[i].colors!.c1! as Int,
							myStorys[i].colors!.c2! as Int,
							myStorys[i].colors!.c3! as Int,
							myStorys[i].colors!.c4! as Int
						]

						let story = Story(date: myStorys[i].date!, sentences: sentences, colors: colors, rating: myStorys[i].rating! as Int, author: myStorys[i].author!)
						storys.append(story)

						i -= 1
					} while i > -1

					completion(storys)

				} else {
					print("no story yet")
				}

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
				var i = 0
				repeat {
					managedContext.deleteObject(oldStorys[i] as! NSManagedObject)
					i += 1
				} while i < oldStorys.count
			}

		} catch {
			print("can't get old storys")
		}

		var i = 0
		repeat {
			let entity_0 = NSEntityDescription.entityForName("Sentences", inManagedObjectContext: managedContext)
			let sentences = Sentences(entity: entity_0!, insertIntoManagedObjectContext: managedContext)
			sentences.s0 = storys[i].sentences[0]
			sentences.s1 = storys[i].sentences[1]
			sentences.s2 = storys[i].sentences[2]
			sentences.s3 = storys[i].sentences[3]
			sentences.s4 = storys[i].sentences[4]

			let entity_1 = NSEntityDescription.entityForName("Colors", inManagedObjectContext: managedContext)
			let colors = Colors(entity: entity_1!, insertIntoManagedObjectContext: managedContext)
			colors.c0 = storys[i].colors[0]
			colors.c1 = storys[i].colors[1]
			colors.c2 = storys[i].colors[2]
			colors.c3 = storys[i].colors[3]
			colors.c4 = storys[i].colors[4]

			let entity_2 = NSEntityDescription.entityForName("DailyStory", inManagedObjectContext: managedContext)
			let dailyStory = DailyStory(entity: entity_2!, insertIntoManagedObjectContext: managedContext)
			dailyStory.date = storys[i].date
			dailyStory.rating = storys[i].rating
			dailyStory.author = storys[i].author
			dailyStory.sentences = sentences
			dailyStory.colors = colors

			do {
				try managedContext.save()
				print(i)
			} catch {
				print("can't save", i)
			}
			
			i += 1
		} while i < storys.count

		completion(true)

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
					var i = 0
					repeat {
						let sentences: [String] = [
							dailyStorys[i].sentences!.s0!,
							dailyStorys[i].sentences!.s1!,
							dailyStorys[i].sentences!.s2!,
							dailyStorys[i].sentences!.s3!,
							dailyStorys[i].sentences!.s4!
						]

						let colors: [Int] = [
							dailyStorys[i].colors!.c0! as Int,
							dailyStorys[i].colors!.c1! as Int,
							dailyStorys[i].colors!.c2! as Int,
							dailyStorys[i].colors!.c3! as Int,
							dailyStorys[i].colors!.c4! as Int
						]

						let story = Story(date: dailyStorys[i].date!, sentences: sentences, colors: colors, rating: dailyStorys[i].rating! as Int, author: dailyStorys[i].author!)
						storys.append(story)

						i += 1
					} while i < dailyStorys.count
				}


			}

			completion(storys)

		} catch {
			print("can't load storys from coreData")
		}
	}

}




