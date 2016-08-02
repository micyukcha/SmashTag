//
//  TweetTableViewCell.swift
//  SmashTag
//
//  Created by Michael Chang on 7/27/16.
//  Copyright © 2016 Michael Chang. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell
{
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    var hashtagColor = UIColor.magentaColor()
    var urlColor = UIColor.orangeColor()
    var userMentionsColor = UIColor.blueColor()

    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!

    func updateUI()
    {
        tweetScreenNameLabel?.text = nil
        tweetTextLabel?.text = nil
        tweetCreatedLabel?.text = nil
        tweetProfileImageView?.image = nil
        
        // load new info from tweet (if any)
        if let tweet = self.tweet
        {
            //create NSMutableAttribute string API tweet.text
            var tweetText = tweet.text
            
            //append image to text if it contains media
            for _ in tweet.media {
                tweetText += " 📷"
            }
            
            //
            let attributedText = NSMutableAttributedString(string: tweetText)
            attributedText.changeKeywordColors(tweet.hashtags, color: hashtagColor)
            attributedText.changeKeywordColors(tweet.urls, color: urlColor)
            attributedText.changeKeywordColors(tweet.userMentions, color: userMentionsColor)
            
            tweetTextLabel?.attributedText = attributedText
            
            //if image exists, convert URL -> NSData -> UIImage
            if let profileImageURL = tweet.user.profileImageURL {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    let contentsOfURL = NSData(contentsOfURL: profileImageURL)
                    dispatch_async(dispatch_get_main_queue()) {
                        if let imageData = contentsOfURL {
                            self.tweetProfileImageView?.image = UIImage(data: imageData)
                        } else {
                            print("Ignored data returned from url \(profileImageURL)")
                        }
                    }
                }
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)"
            
            //if data greater, use dateStyle, otherwise timeStyel
            let formatter = NSDateFormatter()
            
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
            
            if tweet.hashtags.count + tweet.urls.count + tweet.userMentions.count + tweet.media.count > 0 {
                accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            } else {
                accessoryType = UITableViewCellAccessoryType.None
            }
        }
    }
}

// MARK: Extensions

extension NSMutableAttributedString {
    func changeKeywordColors(keywords: [Mention], color: UIColor) {
        for keyword in keywords {
            addAttribute(NSForegroundColorAttributeName, value: color, range: keyword.nsrange)
        }
    }
}
