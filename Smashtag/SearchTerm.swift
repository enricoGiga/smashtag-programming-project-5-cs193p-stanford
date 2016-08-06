//
//  SearchTerm.swift
//  Smashtag
//
//  Created by enrico  gigante on 15/07/16.

//

import Foundation
import CoreData


class SearchTerm: NSManagedObject {
    class func statisticsFor(keyword: String, mention: MentionM, inManagedObjectContext context: NSManagedObjectContext) -> SearchTerm?
    {
    if let searchM = NSEntityDescription.insertNewObjectForEntityForName("SearchTerm", inManagedObjectContext: context) as? SearchTerm {
        searchM.count = 1
        searchM.keyword = keyword
        searchM.mention = mention
        return searchM
    }
    return nil
}

}
