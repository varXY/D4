//
//  Sentences+CoreDataProperties.swift
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

extension Sentences {

    @NSManaged var s0: String?
    @NSManaged var s1: String?
    @NSManaged var s2: String?
    @NSManaged var s3: String?
    @NSManaged var s4: String?
    @NSManaged var myStory: NSManagedObject?
    @NSManaged var dailyStory: NSManagedObject?

}
