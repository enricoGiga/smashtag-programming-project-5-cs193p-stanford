//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by enrico  gigante on 06/07/16.
//

import UIKit

class MentionsTableViewController: UITableViewController {
    var tweet: Tweet?{
        didSet{
            mentions.removeAll()
            tableView.reloadData()
            if let user = tweet?.user{
                title = user.name
            }
            
            if let images = tweet?.media{
                if !images.isEmpty{
                    var imageMention: [Item] = []
                    for image in images{
                        imageMention.append(Item.media(image.url, image.aspectRatio))
                    }
                    let imageM = Mentions(title: "Image", item: imageMention)
                    mentions.append(imageM)
                }
            }
            //URL
            if let urls = tweet?.urls{
                if !urls.isEmpty{
                    var urlsWord : [Item] = []
                    //aggiungo tutti gli urls in urlsWord
                    for url in urls {
                        urlsWord.append(Item.Keyword(url.keyword))
                    }
                    let urlMention =  Mentions(title: "Url", item: urlsWord)
                    mentions.append(urlMention)
                }
            }
            //hashtags
            if let hashtags = tweet?.hashtags{
                if !hashtags.isEmpty{
                    var hashtagsWord : [Item] = []
                    
                    for hashtag in hashtags {
                        hashtagsWord.append(Item.Keyword(hashtag.keyword)) //.append(hashtag.keyword)
                    }
                    let hashMention = Mentions(title: "Hastag", item: hashtagsWord)
                    mentions.append(hashMention)
                }
            }
            //userMentions
            if let userMentions = tweet?.userMentions{
                if !userMentions.isEmpty {
                    var mentionsWord : [Item] = []
                    for user in userMentions {
                        mentionsWord.append(Item.Keyword(user.keyword))
                    }
                    let userMention = Mentions(title: "User", item: mentionsWord)
                    mentions.append(userMention)
                }
            }
            
            tableView?.reloadData()
        }
    }
    
    private var mentions = [Mentions]()
    private struct Mentions {
        var title: String
        var item: [Item]
    }
    private enum Item{
        case Keyword(String)
        case media(NSURL, Double)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private struct storyboard{
        static let showImageSegue = "Show Image"
        static let rewindTweetTableSegue = "Show tweets"
    }

    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentions.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].item.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mention = mentions[indexPath.section].item[indexPath.row]
        
        switch mention {
        case .Keyword(let keyword):
            let cell = tableView.dequeueReusableCellWithIdentifier("Mentions Identifier", forIndexPath: indexPath)
            cell.textLabel?.text = keyword
            return cell
           
        case .media(let url, _):
            let cell =  tableView.dequeueReusableCellWithIdentifier("Mentions Identifier", forIndexPath: indexPath) as! MentionTableViewCell
            cell.imageUrl = url
            return cell
            
        }
    
        
        
        
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return mentions[section].title
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let mention = mentions[indexPath.section].item[indexPath.row]
        
        switch mention {
        case .media(_, let aspectRatio):
            return tableView.bounds.size.width / CGFloat(aspectRatio)
            
        default: return UITableViewAutomaticDimension
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let mention = mentions[indexPath.section].item[indexPath.row]
        switch mention {
        case .media(_, _):
            performSegueWithIdentifier(storyboard.showImageSegue, sender: tableView.cellForRowAtIndexPath(indexPath))
        case .Keyword(let keyword):
            if keyword.hasPrefix("http"){
                if let nsurl = NSURL(string: keyword){
                    UIApplication.sharedApplication().openURL(nsurl)
                }
            }else if keyword.hasPrefix("@") || keyword.hasPrefix("#"){
                performSegueWithIdentifier(storyboard.rewindTweetTableSegue, sender: tableView.cellForRowAtIndexPath(indexPath))
         
            }
        }
        
    }
    
    private func unwind() {
        performSegueWithIdentifier(storyboard.rewindTweetTableSegue, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier{
            
            switch identifier {
            case storyboard.showImageSegue:
                if let indexPath = tableView.indexPathForCell(sender as! MentionTableViewCell){
                    if let scrollVC = segue.destinationViewController as? ScrollViewController{
                        let mention = mentions[indexPath.section].item[indexPath.row]
                        switch mention {
                        case .media(let url, _):
                            scrollVC.imageURL = url
                        default:
                            break
                        }
                    }
                }
            case storyboard.rewindTweetTableSegue:
                if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell){
                    if let tweetVC = segue.destinationViewController as? TweetTableViewController{
                        let mention = mentions[indexPath.section].item[indexPath.row]
                        switch mention {
                        case .Keyword(let keyword):
                            tweetVC.searchText = keyword
                            tweetVC.searchTextField.text = keyword
                        default:
                            break
                        }
                    }
                }
            default: break
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

