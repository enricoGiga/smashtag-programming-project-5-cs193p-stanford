//
//  MentionM+CoreDataProperties.swift
//  Smashtag
//
//  Created by enrico  gigante on 15/07/16.

//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MentionM {

    @NSManaged var keyword: String?
    @NSManaged var type: String?
    @NSManaged var tweets: NSSet?
    @NSManaged var mentioned: NSSet?

}
