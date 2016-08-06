//
//  RecentSearchTableViewController.swift
//  Smashtag
//
//  Created by enrico  gigante on 09/07/16.
//

import UIKit

class RecentSearchTableViewController: UITableViewController {
    private let userDefaults = UserDefaults()
    
    private var recentSearches: [String] {
        get{
            return userDefaults.returnWhatIsStored()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Recent Searches"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recentSearches.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Secent Search Cell", forIndexPath: indexPath)

        let ricerche = recentSearches[indexPath.row]
        //cell.accessoryType = .DetailDisclosureButton
        cell.textLabel?.text = ricerche

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("TweetSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            userDefaults.delateSearchTerm(removeAtIndexPath: indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
       performSegueWithIdentifier("showPopular", sender: indexPath)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier =  segue.identifier{
            switch identifier{
            case "TweetSegue":
                if let tweetVC = segue.destinationViewController as? TweetTableViewController {
                    if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell){
                        let searchText = recentSearches[indexPath.row]
                        
                        tweetVC.searchText = searchText
                        tweetVC.searchTextField.text = searchText
                        
                    }
                }
            case "showPopular":
                if let popularTVC = segue.destinationViewController as? PopularTableViewController{
                    if let indexPath = sender as? NSIndexPath{
                        popularTVC.mention = recentSearches[indexPath.row]
              
                    }
                }
            default: break
            }
        }
        
    }
}
