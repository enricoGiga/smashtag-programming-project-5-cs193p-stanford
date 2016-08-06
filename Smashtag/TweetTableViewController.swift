//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//

import UIKit

import CoreData
import MBProgressHUD

class TweetTableViewController: UITableViewController, UITextFieldDelegate
    
{
    // MARK: Model
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    @IBAction func moreOptions(sender: UIBarButtonItem) {
        initAlert()
    }
    
    // if this is nil, then we simply don't update the database
    // having this default to the AppDelegate's context is a little bit of "demo cheat"
    // probably it would be better to subclass TweetTableViewController
    // and set this var in that subclass and then use that subclass in our storyboard
    // (the only purpose of that subclass would be to pick what database we're using)


    // user default object
    private let userDefaults = UserDefaults()
    // le ricerche effettuate dall'user devono essere memorizzate in maniera persistente
    private var searchTerm: [String]{
        get{
            return userDefaults.returnWhatIsStored()
        }
        set{
           userDefaults.store(newValue)
        }
        
    }
    var tweets = [Array<Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            lastTwitterRequest = nil
            showLoadingHUD()
            searchForTweets()
            
            title = searchText
            // inserisco l'elemento nell'array delle ricerche recenti al primo posto
            if let searchText = searchText{
                if !searchTerm.contains(searchText){
                    searchTerm.insert(searchText, atIndex: 0)
                }else {
                    userDefaults.deletateSerchTermWithKey(removeKey: searchText)
                    searchTerm.insert(searchText, atIndex: 0)
                }
                
            }
        }
    }
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading..."
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    // MARK: Constants
    
    private struct Storyboard {
        // Cell Identifier
        static let TweetCellIdentifier = "Tweet"
        static let MentionsCellIdentifier = "Mentions Identifier"
        // Segue Indentifier
        static let TweetersSegueIdentifier = "Tweeters Mentioning Search Term"
        static let  MentionsSegueIdentifier = "Mentions Segue Identifier"
        static let CollectionSegueIdentifier = "Show Images"
        
        //static let
    }
    
    // MARK: Fetching Tweets
    
    private var twitterRequest: Request? {
        if lastTwitterRequest == nil {
            if let query = searchText where !query.isEmpty {
                return Request(search: query + " -filter:retweets", count: 100)
            }
        }
        return lastTwitterRequest?.requestForNewer
    }
    
    private var lastTwitterRequest: Request?

    private func searchForTweets()
    {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                            weakSelf?.updateDatabase(newTweets)
                        }
                    }
                    weakSelf?.refreshControl?.endRefreshing()
                    weakSelf?.hideLoadingHUD()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    // add the Twitter.Tweets to our database

    private func updateDatabase(newTweets: [Tweet]) {
        managedObjectContext!.performBlockAndWait{
            for twitterInfo in newTweets {
                // the _ = just lets readers of our code know
                // that we are intentionally ignoring the return value
                _ = TweetM.tweetWith(twitterInfo, forSearchTerm: self.searchText!, inManagedObjectContext: self.managedObjectContext!)           }
            // there is a method in AppDelegate
            // which will save the context as well
            // but we're just showing how to save and catch any error here
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core Data Error: \(error)")
            }
        }
        printDatabaseStatistics()
        //delateDatabase()
        
        // note that even though we do this print()
        // AFTER printDatabaseStatistics() is called
        // it will print BEFORE because printDatabaseStatistics()
        // returns immediately after putting a closure on the context's queue
        // (that closure then runs sometime later, after this print())
        print("done printing database statistics")
    }
    private func delateDatabase(){
        // Initialize Fetch Request
        managedObjectContext?.performBlockAndWait {
            //elimino i tweet
            let fetchRequest = NSFetchRequest(entityName: "Tweet")
            
            // Configure Fetch Request
            fetchRequest.includesPropertyValues = false
            
           // let tweetCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
           // if tweetCount > 4500{
                if let items = try? self.managedObjectContext?.executeFetchRequest(fetchRequest) as! [NSManagedObject]{
                    
                    for item in items {
                        self.managedObjectContext?.deleteObject(item)
                        
                    }
                }
           // }
           
            let fetchRequestdue = NSFetchRequest(entityName: "UserM")
             fetchRequest.includesPropertyValues = false
            if let items = try? self.managedObjectContext?.executeFetchRequest(fetchRequestdue) as! [NSManagedObject]{
                
                for item in items {
                    self.managedObjectContext?.deleteObject(item)
                    
                }
            }

            do{
                try self.managedObjectContext?.save()
                
            } catch {
                print ("ho un errore nell'eliminazione dei tweet")
            }
        }
        
        
    }
    // print out how many Tweets and TwitterUsers are in the database
    // uses two different ways of counting them
    // the second way (countForFetchRequest) is much more efficient
    // (since it does the count in the database itself)


    private func printDatabaseStatistics() {
        managedObjectContext?.performBlock
            {	if let results = try? self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "UserM"))
            {	print("\(results.count) TwitterUsers")
                }
                let tweetMCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "TweetM"), error: nil)
                print(tweetMCount, " Tweets")
                let mentionsCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "MentionM"), error: nil)
                print(mentionsCount, " Mentions")
                let searchTermCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "SearchTerm"), error: nil)
                print(searchTermCount, " searchTermCount")
        }
    }
    // prepare for the segue that happens
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier{
            switch identifier {
            // when the user hits the Tweeters bar button item
            case Storyboard.TweetersSegueIdentifier:
                if let tweetersTVC = segue.destinationViewController as? TweetersTableViewController {
                    tweetersTVC.mention = searchText
                    tweetersTVC.managedObjectContext = managedObjectContext
                }
            case Storyboard.MentionsSegueIdentifier:
                if let thisCell = sender as? TweetTableViewCell{
                    if let mentionsTVC = segue.destinationViewController as? MentionsTableViewController {
                        if let indexPath = tableView.indexPathForCell(thisCell){
                            mentionsTVC.tweet = tweets[indexPath.section][indexPath.row]//thisCell.tweet
                        }
                    }
                }
            case Storyboard.CollectionSegueIdentifier:
                if let tcvc = segue.destinationViewController as? ImageCollectionViewController {
                    tcvc.tweets = tweets
                    tcvc.title = title
                }
            default: break
            }
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
    
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        searchForTweets()
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        return "Tweets table"
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath)

        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
    
        return cell
    }
    
    private func initAlert(){
        let alert = UIAlertController(title: "Options", message: "Select one of the following options...", preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(
            title: "Show Tweet's Images",
            style: UIAlertActionStyle.Default){(action: UIAlertAction) -> Void in
                self.performSegueWithIdentifier(Storyboard.CollectionSegueIdentifier, sender: self)
            }
        )
        
        alert.addAction(UIAlertAction(
            title: "List of Tweeters",
            style: UIAlertActionStyle.Default){(action: UIAlertAction) -> Void in
                self.performSegueWithIdentifier(Storyboard.TweetersSegueIdentifier, sender: self)
            }
        )
        
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Cancel){(action: UIAlertAction) -> Void in
            // non faccio niente
            }
        )
        
        alert.modalPresentationStyle = .Popover
        presentViewController(alert, animated: true, completion: nil)
        

    
    }

    
    // MARK: Outlets

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            
            searchTextField.delegate = self
            
            searchTextField.text = searchText

        }
    }
    
    // MARK: UITextFieldDelegate
    //
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //per rimuove la tastiera dopo aver premuto enter
        textField.resignFirstResponder()
        searchText = textField.text
        
        return true
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }


}
