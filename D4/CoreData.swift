//
//  CoreData.swift
//  D4
//
//  Created by 文川术 on 4/10/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit
import CoreData


protocol CoreDataAndStory {
	func saveMyStory(_ story: Story, completion: (Bool) -> ())
	func getMyStorys(_ completion: ([Story]) -> ())

	func save100DailyStorys(_ storys: [Story], completion: (Bool) -> ())
	func load100DailyStorys(_ completion: ([Story]) -> ())

	func updateRatingOfDailyStoryInCoreData(_ story: Story)
}

extension CoreDataAndStory {

	func saveMyStory(_ story: Story, completion: (Bool) -> ()) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext

		let entity_0 = NSEntityDescription.entity(forEntityName: "Sentences", in: managedContext)
		let sentences = Sentences(entity: entity_0!, insertInto: managedContext)
		sentences.s0 = story.sentences[0]
		sentences.s1 = story.sentences[1]
		sentences.s2 = story.sentences[2]
		sentences.s3 = story.sentences[3]
		sentences.s4 = story.sentences[4]

		let entity_1 = NSEntityDescription.entity(forEntityName: "Colors", in: managedContext)
		let colors = Colors(entity: entity_1!, insertInto: managedContext)
		colors.c0 = story.colors[0] as NSNumber?
		colors.c1 = story.colors[1] as NSNumber?
		colors.c2 = story.colors[2] as NSNumber?
		colors.c3 = story.colors[3] as NSNumber?
		colors.c4 = story.colors[4] as NSNumber?

		let entity_2 = NSEntityDescription.entity(forEntityName: "MyStory", in: managedContext)
		let myStory = MyStory(entity: entity_2!, insertInto: managedContext)
		myStory.date = story.date
		myStory.rating = story.rating as NSNumber?
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


	func getMyStorys(_ completion: ([Story]) -> ()) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext

		let fetchRequest = NSFetchRequest<MyStory>(entityName: "MyStory")
		fetchRequest.entity = NSEntityDescription.entity(forEntityName: "MyStory", in: managedContext)
		var storys = [Story]()

		do {
			let myStorys = try managedContext.fetch(fetchRequest)
				
            if myStorys.count != 0 {
                storys = myStorys.map({
                    let sentences = [$0.sentences!.s0!, $0.sentences!.s1!, $0.sentences!.s2!, $0.sentences!.s3!, $0.sentences!.s4!]
                    let colors = [$0.colors!.c0! as Int, $0.colors!.c1! as Int, $0.colors!.c2! as Int, $0.colors!.c3! as Int, $0.colors!.c4! as Int]
                    let story = Story(date: $0.date!, sentences: sentences, colors: colors, rating: $0.rating! as Int, author: $0.author!)
                    return story
                })
                storys = storys.reversed()
                
            } else {
                print("no story yet")
            }
            
            completion(storys)
			
		} catch {
			print("can't get my storys")
		}
	}

	func save100DailyStorys(_ storys: [Story], completion: (Bool) -> ()) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext

		let fetchRequest = NSFetchRequest<DailyStory>(entityName: "DailyStory")
		fetchRequest.entity = NSEntityDescription.entity(forEntityName: "DailyStory", in: managedContext)

		do {
			let oldStorys = try managedContext.fetch(fetchRequest)
			if oldStorys.count != 0 {
				oldStorys.forEach({ managedContext.delete($0 as NSManagedObject) })
			}
		} catch {
			print("can't get old storys")
		}

		var success = true
		let _: [DailyStory] = storys.map({
			let entity_0 = NSEntityDescription.entity(forEntityName: "Sentences", in: managedContext)
			let sentences = Sentences(entity: entity_0!, insertInto: managedContext)
			sentences.s0 = $0.sentences[0]
			sentences.s1 = $0.sentences[1]
			sentences.s2 = $0.sentences[2]
			sentences.s3 = $0.sentences[3]
			sentences.s4 = $0.sentences[4]

			let entity_1 = NSEntityDescription.entity(forEntityName: "Colors", in: managedContext)
			let colors = Colors(entity: entity_1!, insertInto: managedContext)
			colors.c0 = $0.colors[0] as NSNumber?
			colors.c1 = $0.colors[1] as NSNumber?
			colors.c2 = $0.colors[2] as NSNumber?
			colors.c3 = $0.colors[3] as NSNumber?
			colors.c4 = $0.colors[4] as NSNumber?

			let entity_2 = NSEntityDescription.entity(forEntityName: "DailyStory", in: managedContext)
			let dailyStory = DailyStory(entity: entity_2!, insertInto: managedContext)
			dailyStory.id = $0.ID
			dailyStory.date = $0.date
			dailyStory.rating = $0.rating as NSNumber?
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

	func load100DailyStorys(_ completion: ([Story]) -> ()) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext

		let fetchRequest = NSFetchRequest<DailyStory>(entityName: "DailyStory")
		fetchRequest.entity = NSEntityDescription.entity(forEntityName: "DailyStory", in: managedContext)

		var storys = [Story]()

		do {
			let dailyStorys = try managedContext.fetch(fetchRequest)
				
            if dailyStorys.count != 0 {
                storys = dailyStorys.map({
                    let sentences = [$0.sentences!.s0!, $0.sentences!.s1!, $0.sentences!.s2!, $0.sentences!.s3!, $0.sentences!.s4!]
                    let colors = [$0.colors!.c0! as Int, $0.colors!.c1! as Int, $0.colors!.c2! as Int, $0.colors!.c3! as Int, $0.colors!.c4! as Int]
                    let story = Story(id: $0.id!, date: $0.date!, sentences: sentences, colors: colors, rating: $0.rating! as Int, author: $0.author!)
                    return story
                })
            }

			completion(storys)

		} catch {
			print("can't load storys from coreData")
		}
	}

	func updateRatingOfDailyStoryInCoreData(_ story: Story) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext

		let fetchRequest = NSFetchRequest<DailyStory>(entityName: "DailyStory")
		fetchRequest.entity = NSEntityDescription.entity(forEntityName: "DailyStory", in: managedContext)
		fetchRequest.predicate = NSPredicate(format:"id == %@", story.ID)

		do {
			let ratingChangedStory = try managedContext.fetch(fetchRequest)
			
            if ratingChangedStory.count == 1 {
                ratingChangedStory.forEach({ $0.rating = story.rating as NSNumber? })
            }
			
		} catch {
			print("can't update rating in coreData")
		}

		do {
			try managedContext.save()
		} catch {
			print("can't save rating in coreData")
		}
	}

}




