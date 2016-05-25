//
//  TweetCell.swift
//  Peek
//
//  Created by Naga Praveen Kumar Pendyala on 5/23/16.
//  Copyright © 2016 Peek. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell{

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    //adding values to the labels in the cell

    var tweet: Tweet!{
        didSet {
            nameLabel.text = tweet.name
            tweetLabel.text = tweet.tweet
        }
        
    }
    @IBAction func retweetBtn(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("retweetNotification", object: nil, userInfo: ["tweet": tweet])
    }
    
    
}
