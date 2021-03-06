//
//  UserM.swift
//  Smashtag
//
//  Created by enrico  gigante on 15/07/16.

//

import Foundation
import CoreData
import Twitter

class UserM: NSManagedObject {
    class func twitterUserWith(twitterInfo: User, inManagedObjectContext context: NSManagedObjectContext) -> UserM?
    {
        let request = NSFetchRequest(entityName: "UserM")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
        if let userM = (try? context.executeFetchRequest(request))?.first as? UserM
        {	return userM
        } else
            if let userM = NSEntityDescription.insertNewObjectForEntityForName("UserM", inManagedObjectContext: context) as? UserM
            {	userM.screenName = twitterInfo.screenName
                userM.name = twitterInfo.name
                return userM
        } // else
        return nil
    }
}
