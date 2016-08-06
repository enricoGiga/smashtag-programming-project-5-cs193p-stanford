//
//  TweetersTableViewController.swift
//  Smashtag
//
//  Created by CS193p Instructor.

//
// notiamo che questa MVC non importa tweet, perchè usa esclusivamente il database
import UIKit
import CoreData

// uses CoreDataTableViewController as its superclass
// so all we need to do is set the fetchedResultsController var !!!!!!!!!!!!
// and implement tableView(cellForRowAtIndexPath:)

// CoreDataTableViewController ha a sua volta come super classe UITableViewController, quindi l'unica cosa che bisogna ereditare è
class TweetersTableViewController: CoreDataTableViewController
{
    // cosa deve fare: riceve una mention ( es #clarinet)  e cerca  nel nostro database tutti gli user che hanno twittato quella mentions
    // quindi il nostro model sarà quella mention e il nostro database:
    var mention: String? { didSet { updateUI() } }
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    private func updateUI() {
        // devo evitare il crash nel caso in cui mention sia nil quindi metto il seguente if:
        if let context = managedObjectContext where mention?.characters.count > 0 {
            let request = NSFetchRequest(entityName: "UserM")
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@ and screenName beginswith[c] %@", mention!, "c")
            //request.predicate = NSPredicate(format: "any tweets.text contains[c] %@ and !screenName beginswith[c] %@", mention!, "darkside")
            request.sortDescriptors = [NSSortDescriptor(
                // this sempre deve essere un attribut dell'entity TwitterUser
                key: "screenName",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]
            // #selector(metod): The method to use when comparing the properties of objects, for example caseInsensitiveCompare: or localizedCompare:. The selector must specify a method implemented by the value of the property identified by keyPath.
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        } else {
            // in questo caso CoreDataTableViewController pulisce la table
            fetchedResultsController = nil
        }
    }
    
    // this is the only UITableViewDataSource method we have to implement
    // if we use a CoreDataTableViewController
    // the most important call is fetchedResultsController?.objectAtIndexPath(indexPath)
    // (that's how we get the object that is in this row so we can load the cell up)
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterUserCell", forIndexPath: indexPath)

        if let twitterUser = fetchedResultsController?.objectAtIndexPath(indexPath) as? UserM {
            var screenName: String?
            twitterUser.managedObjectContext?.performBlockAndWait {
                // it's easy to forget to do this on the proper queue
                screenName = twitterUser.screenName
                // we're not assuming the context is a main queue context
                // so we'll grab the screenName and return to the main queue
                // to do the cell.textLabel?.text setting
            }
            cell.textLabel?.text = screenName
            if let count = tweetCountWithMentionByTwitterUser(twitterUser) {
                cell.detailTextLabel?.text = (count == 1) ? "1 tweet" : "\(count) tweets"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
    
        return cell
    }
    
    // private func which figures out how many tweets
    // were tweeted by the given user that contain our mention
    
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
