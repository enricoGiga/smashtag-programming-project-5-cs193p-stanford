//
//  PopularTableViewController.swift
//  Smashtag
//
//  Created by enrico  gigante on 15/07/16.
//

import UIKit
import CoreData
class PopularTableViewController:  CoreDataTableViewController{

    var mention: String? { didSet { updateUI() } }
   //var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    var managedObjectContext: NSManagedObjectContext? {
        let delegate = UIApplication.sharedApplication().delegate
        return (delegate as? AppDelegate)?.managedObjectContext
    }

    private func updateUI() {
        if let context = managedObjectContext where mention?.isEmpty != true {
            let request = NSFetchRequest(entityName: "SearchTerm")
            request.predicate = NSPredicate(format: "keyword LIKE[cd] %@ AND count > %@", mention!, "1")
            
            let sortDescriptorA = NSSortDescriptor(
                key: "mention.type",
                ascending: true,
                selector: #selector(NSString.localizedStandardCompare(_:)))
            let sortDescriptorB = NSSortDescriptor(
                key: "count",
                ascending: false)
            let sortDescriptorC = NSSortDescriptor(key: "mention.keyword", ascending: true,  selector: #selector(NSString.localizedStandardCompare(_:)))
            request.sortDescriptors = [sortDescriptorA, sortDescriptorB, sortDescriptorC]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "mention.type",
                cacheName: nil)
            
        } else {
            fetchedResultsController = nil
        }
    }
    override func viewDidLoad() {

        updateUI()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {	let cell = tableView.dequeueReusableCellWithIdentifier("popularMentionsCell", forIndexPath: indexPath)
        var keyword: String?
        var count: String?
        if let searchTermM = fetchedResultsController?.objectAtIndexPath(indexPath) as? SearchTerm {
            searchTermM.managedObjectContext?.performBlockAndWait {  // asynchronous
                keyword =  (searchTermM.mention as? MentionM)!.keyword
                count = searchTermM.count!.stringValue
            }
            cell.textLabel?.text = keyword
            cell.detailTextLabel?.text = "tweets.count: " + (count ?? "-")
        }
        
        return cell
    }
    private func tweetCountWithMentionByTwitterUser(user: UserM) -> Int?
    {
        var count: Int?
        user.managedObjectContext?.performBlockAndWait {
            let request = NSFetchRequest(entityName: "TweetM")
            request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", self.mention!, user)
            count = user.managedObjectContext?.countForFetchRequest(request, error: nil)
        }
        return count
    }


}
