//
//  ViewController.swift
//  Peek
//
//  Created by Naga Praveen Kumar Pendyala on 5/23/16.
//  Copyright © 2016 Peek. All rights reserved.
//

import UIKit
import Foundation

class TweetsViewController: UITableViewController, TweetDownloadDelegate, TweetCellDelegate{
    
    var tweetDownload = TweetDownload()
    var maxid:IntMax = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetDownload.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(TweetsViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        // Do any additional setup after loading the view, typically from a nib.
        tweetDownload.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?q=%40Peek&count=10", refresh: false)
    }
    
    func refresh(sender:AnyObject) {
        tweetDownload.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?q=%40Peek&count=10", refresh: true)
    }
    
    func reTweet(id: IntMax)
    {
        
        tweetDownload.postRequest("https://api.twitter.com/1.1/statuses/retweet/\(id).json",completionBolck: {(msg) -> Void in
            
            var message = msg
            if( message == String(id))
            {
                message = "Successfully Retweeted"
            }
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertController.init(title: "Message", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = tweetDownload.tweets.count
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
            cell.backgroundColor = UIColor.whiteColor()
        }
        let tweet = tweetDownload.tweets[indexPath.row]
        cell.delegate = self
        cell.tweet = tweet
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width/2
        cell.avatarImageView.clipsToBounds = true
        cell.avatarImageView.image = UIImage(data: tweet.avatar)
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row+1 == tweetDownload.tweets.count)
        {
            maxid = tweetDownload.tweets.last!.id-1 > maxid ? maxid : tweetDownload.tweets.last!.id-1
            tweetDownload.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?q=%40Peek&count=10&max_id=\(maxid)", refresh: false)

        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            tweetDownload.tweets.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    func finishedDownloading() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            self.maxid = self.tweetDownload.tweets.last!.id-1
            if self.refreshControl!.refreshing
            {
                self.refreshControl!.endRefreshing()
            }
        })
    }



}

