//
//  MentionsTableViewCell.swift
//  SmashTag
//
//  Created by Michael Chang on 7/31/16.
//  Copyright © 2016 Michael Chang. All rights reserved.
//

import UIKit

class MentionsTableViewCell: UITableViewCell {

    
    @IBOutlet var tweetImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: NSURL? {
        didSet {
            tweetImage = nil
            if contentView.window != nil {
                updateUI()
            }
        }
    }

    func updateUI() {
        if let url = imageURL {                                             // if image URL exists
            spinner?.startAnimating()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let contentsOfURL = NSData(contentsOfURL: url)              // convert url to NSData, does it come back nil??
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL {                               // if url hasn't changed
                        if let imageData = contentsOfURL {                  // NSData exists
                            if let image = UIImage(data: imageData) {
                                self.tweetImage?.image = image // convert NSData to image data
                                print("\(imageData) should get stored here: \(self.tweetImage?.image)")
                            }
                        } else {
                            print("Nothing.")
                            self.spinner?.stopAnimating()
                        }
                    } else {
                        print("Ignored data returned from url \(url)")
                    }
                }
            }
        }
    }
    
//    func viewDidLoad() {
//        self.viewDidLoad()
//    }
}

