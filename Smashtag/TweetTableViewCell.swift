//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//

import UIKit
import MBProgressHUD

class TweetTableViewCell: UITableViewCell
{
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI()
    {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            setBodyText(tweet)
            tweetScreenNameLabel?.text = "\(tweet.user)"
            if let profileImageURL = tweet.user.profileImageURL {
                if let imageData = NSData(contentsOfURL: profileImageURL) { // blocks main thread!
                    tweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }

    }

    func setBodyText(tweet: Tweet){
        tweetTextLabel?.text = tweet.text
        var text = tweet.text
        if !tweet.media.isEmpty{
            for _ in tweet.media {
                text += " 📷" 
                
            }
        }
        let attributedString = NSMutableAttributedString(string: text)
        
        if !tweet.hashtags.isEmpty {
            for hashtag in tweet.hashtags {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: hashtag.nsrange)
            }
        }
        
        if !tweet.urls.isEmpty {
            for url in tweet.urls {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: url.nsrange)
            }
        }
        
        if !tweet.userMentions.isEmpty {
            for userMention in tweet.userMentions {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: userMention.nsrange)
            }
        }
        
        tweetTextLabel?.attributedText = attributedString
    }
}

