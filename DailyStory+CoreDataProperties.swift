//
//  DailyStory+CoreDataProperties.swift
//  D4
//
//  Created by 文川术 on 4/10/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DailyStory {

	@NSManaged var id: String?
    @NSManaged var date: NSDate?
    @NSManaged var rating: NSNumber?
    @NSManaged var author: String?
    @NSManaged var sentences: Sentences?
    @NSManaged var colors: Colors?

}
