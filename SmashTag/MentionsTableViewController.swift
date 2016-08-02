//
//  MentionsTableViewController.swift
//  SmashTag
//
//  Created by Michael Chang on 7/29/16.
//  Copyright © 2016 Michael Chang. All rights reserved.
//

import UIKit
import Twitter

class MentionsTableViewController: UITableViewController {

    // MARK: Create data model- use array of struct with array of enums to fit sections and rows
    
    var mentions: [Mentions] = []

    struct Mentions: CustomStringConvertible            // unique mentions per mention type
    {
        var title: String
        var data: [MentionItem]
        var description: String { return "\(title): \(data)" }      // trailing closure
    }
    
    enum MentionItem: CustomStringConvertible           // either will be keyword or image, same require of each
    {
        case Keyword(String)
        case Image(NSURL, Double)
        var description: String {
            switch self {
            case .Keyword(let keyword): return keyword
            case .Image(let url, _): return url.path!
            }
        }
    }
    
    // MARK: Create data instance, if items exist, pass into mention struct of mentionItems
    
    var tweet: Twitter.Tweet? {
        didSet {
            title = tweet?.user.name
            if let media = tweet?.media {
                mentions.append(Mentions(title: "Images",
                    data: media.map{ MentionItem.Image($0.url, $0.aspectRatio) }))
            }
            
            if let url = tweet?.urls {
                mentions.append(Mentions(title: "URLs",
                    data: url.map{ MentionItem.Keyword($0.keyword) }))
            }
            
            if let hashtag = tweet?.hashtags {
                mentions.append(Mentions(title: "Hashtags",
                    data: hashtag.map{ MentionItem.Keyword($0.keyword) }))
            }
            
            if let userMention = tweet?.userMentions {
                mentions.append(Mentions(title: "User Mentions",
                    data: userMention.map{ MentionItem.Keyword($0.keyword) }))
            }
        }
    }
    
    // MARK: Constants for storyboard
    
    struct Storyboard {
        static let KeywordCellReusableIdentifier = "Keyword Cell"
        static let ImageCellReusableIdentifier = "Image Cell"
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentions.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mention = mentions[indexPath.section].data[indexPath.row]
        switch mention {
        case .Keyword(let keyword):
            let cell = tableView.dequeueReusableCellWithIdentifier(
                Storyboard.KeywordCellReusableIdentifier,
                forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = keyword
            return cell
        case .Image(let url, let ratio):
            let cell = tableView.dequeueReusableCellWithIdentifier(
                Storyboard.ImageCellReusableIdentifier,
                forIndexPath: indexPath) as! MentionsTableViewCell
            cell.imageURL = url
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let mention = mentions[indexPath.section].data[indexPath.row]
        switch mention {
        case .Image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }
}
