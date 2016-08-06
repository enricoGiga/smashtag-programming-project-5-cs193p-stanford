//
//  TweetM.swift
//  Smashtag
//
//  Created by enrico  gigante on 15/07/16.
//

import Foundation
import CoreData
import Twitter

class TweetM: NSManagedObject {
    class func tweetWith(twitterInfo: Tweet, forSearchTerm key: String, inManagedObjectContext context: NSManagedObjectContext) -> TweetM?
    {
        let request = NSFetchRequest(entityName: "TweetM")
        request.predicate = NSPredicate(format: "id = %@", twitterInfo.id)
        let tweetsM = try? context.executeFetchRequest(request)
        if let tweetM = tweetsM?.first as? TweetM {
            return tweetM
        } else {
            if let tweetM = NSEntityDescription.insertNewObjectForEntityForName("TweetM", inManagedObjectContext: context) as? TweetM
            {	tweetM.id = twitterInfo.id
                tweetM.text = twitterInfo.text
                tweetM.created = twitterInfo.created
                tweetM.tweeter = UserM.twitterUserWith(twitterInfo.user, inManagedObjectContext: context)
                
                let twitterMentions = ["hashtags": twitterInfo.hashtags,
                                       "userMentions": twitterInfo.userMentions]
                for (type, mentions) in twitterMentions {
                    for mention in mentions {
                        if let mentionM = MentionM.tweetWith(mention, mentionType: type, forSearchTerm: key, inManagedObjectContext: context) {
                            let mentions = tweetM.mutableSetValueForKey("mentions")
                            mentions.addObject(mentionM)
                        }
                    }
                }
                return tweetM
            }
        }
        return nil 		// non regular exit...
    }
    
}
