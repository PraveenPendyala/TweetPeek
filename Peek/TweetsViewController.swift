//
//  ViewController.swift
//  Peek
//
//  Created by Naga Praveen Kumar Pendyala on 5/23/16.
//  Copyright © 2016 Peek. All rights reserved.
//

import UIKit

class TweetsViewController: UITableViewController, TweetDownloadDelegate {
    
    var tweetDownload: TweetDownload = TweetDownload()
    let imageProvider = ImageProvider()
    var tweets = [Tweet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetDownload.delegate = self;
        
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(TweetsViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        
        tweetDownload.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?q=%40Peek&count=100")
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(retweet(_:)), name: "retweetNotification", object: nil)
    }
    
    
    func retweet(notification: NSNotification)
    {
        let tweet = notification.userInfo!["tweet"] as! Tweet
        tweetDownload.postRequest("https://api.twitter.com/1.1/statuses/retweet/\(tweet.id).json")
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func refresh(sender:AnyObject) {
        tweetDownload.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?q=%40Peek&count=100&since_id=\(tweets[0].id)")
                refreshControl?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        imageProvider.clearCache()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = tweets.count
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TweetCell
        if(indexPath.row%2 == 0)
        {
            cell.backgroundColor = UIColor.cyanColor()
        }
        else
        {
            cell.backgroundColor = UIColor.yellowColor()
        }
        let tweet = tweets[indexPath.row]
        cell.tweet = tweet
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width/2
        cell.avatarImageView.clipsToBounds = true
        imageProvider.imageWithName(tweet.avatar) {
            (image: UIImage) in
            // set the thumbnail images in the table view
            cell.avatarImageView.image = image
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            tweets.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    func finishedDownloading(tweet: Tweet) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tweets.append(tweet)
            self.tableView.reloadData()
        })
    }



}

