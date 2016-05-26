//
//  Tweet.swift
//  Peek
//
//  Created by Naga Praveen Kumar Pendyala on 5/23/16.
//  Copyright © 2016 Peek. All rights reserved.
//

import Foundation

class Tweet {
    
    var name: String
    var tweet: String
    var avatar: NSData
    var id: IntMax
    
    init(name: String, tweet: String, avatar: String, id: String)
    {
        self.name = name
        self.tweet = tweet
        self.id = IntMax(id)!
        let avatarURL = NSURL(string: avatar)
        self.avatar = NSData(contentsOfURL: avatarURL!)!
    }
}