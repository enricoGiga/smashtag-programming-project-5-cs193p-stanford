//
//  TweetM+CoreDataProperties.swift
//  Smashtag
//
//  Created by enrico  gigante on 15/07/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TweetM {

    @NSManaged var created: NSDate?
    @NSManaged var id: String?
    @NSManaged var text: String?
    @NSManaged var tweeter: NSManagedObject?
    @NSManaged var mentions: NSSet?

}
