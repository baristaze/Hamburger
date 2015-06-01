//
//  TimelineViewController.swift
//  Mwitter
//
//  Created by Baris Taze on 5/22/15.
//  Copyright (c) 2015 Baris Taze. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewTweetDelegate, TweetUpdateDelegate {

    @IBOutlet private weak var menuButton: UIBarButtonItem!
    
    @IBOutlet private weak var tableView: UITableView!
    private var refreshControl:UIRefreshControl!
    private var infiniteLoadingStarted = false
    
    private var tweets = [Tweet]()
    
    private var tweetToReply:Tweet?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // create refreshing control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(self.refreshControl, atIndex: 0)
        
        self.loadMoreTweets(false, endInfiniteLoad:false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("tweet.cell", forIndexPath: indexPath) as! TweetCell
        var tweet = self.tweets[indexPath.row]
        cell.reloadDataFrom(tweet)
        cell.delegate = self
        
        return cell
    }
    
    func openNewTweetVC(){
        self.tweetToReply = nil
        self.performSegueWithIdentifier("new.tweet.segue", sender: self)
    }
    
    func onNewTweet(tweet:Tweet) {
        self.tweets.insert(tweet, atIndex: 0)
        self.tableView.reloadData()
    }
    
    func onFavorited(tweet:Tweet, responseTweet:Tweet, sender:TweetCell?) {
        self.tableView.reloadData()
    }
    
    func onRetweeted(tweet:Tweet, responseTweet:Tweet, sender:TweetCell?) {
        self.tableView.reloadData()
    }
    
    func onRefresh() {
        self.loadMoreTweets(true, endInfiniteLoad: false);
    }
    
    func onReplyRequest(tweet:Tweet) {
        self.tweetToReply = tweet
        self.performSegueWithIdentifier("tweet.compose.reply", sender: self)
    }
    
    func loadMoreTweets(endRefreshing:Bool, endInfiniteLoad:Bool){
        
        let showSpinner = !endRefreshing && !endInfiniteLoad
        var sinceId:Int64? = self.tweets.count > 0 ? self.tweets[0].id : nil
        TwitterClient.sharedInstance.getHomeTimelineSince(sinceId) { (tweets:[Tweet]?) -> Void in
            if(tweets != nil){
                if(endRefreshing){
                    var index = 0
                    for tweet in tweets! {
                        self.tweets.insert(tweet, atIndex: index++)
                    }
                }
                else {
                    for tweet in tweets! {
                        self.tweets.append(tweet)
                    }
                }
                
                self.tableView.reloadData()
            }
            
            if(endRefreshing){
                self.refreshControl.endRefreshing()
            }
            
            if(endInfiniteLoad){
                self.infiniteLoadingStarted = false;
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var nav = segue.destinationViewController as? UINavigationController
        if(nav == nil){
        }
        else if(nav!.topViewController is TweetViewController){
            var vc = nav!.topViewController as! TweetViewController
            vc.delegate = self
            if(self.tweetToReply != nil){
                vc.tweetToReply = self.tweetToReply!
                self.tweetToReply = nil
            }
        }
        else if(nav!.topViewController is TweetReadViewController){
            var vc = nav!.topViewController as! TweetReadViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            let tweet = self.tweets[indexPath!.row]
            vc.tweet = tweet
            vc.delegate = self;
        }
        else {
        }
    }
}

