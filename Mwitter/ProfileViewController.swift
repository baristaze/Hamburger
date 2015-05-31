//
//  ProfileViewController.swift
//  Mwitter
//
//  Created by Baris Taze on 5/31/15.
//  Copyright (c) 2015 Baris Taze. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewTweetDelegate, TweetUpdateDelegate {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var numbersSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl:UIRefreshControl!
    
    private var tweets = [Tweet]()
    private var tweetToReply:Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var me = Account.currentUser()!
        
        if(me.profileBackgroundImageUrl != nil){
            self.backgroundImage.setImageWithURL(NSURL(string: me.profileBackgroundImageUrl!))
        }
        
        self.profileImage.setImageWithURL(NSURL(string: me.profileImageUrl))
        
        self.numbersSegment.setTitle("TWEETS: " + me.tweetCount.description, forSegmentAtIndex: 0)
        self.numbersSegment.setTitle("FOLLOWING: " + me.followingCount.description, forSegmentAtIndex: 1)
        self.numbersSegment.setTitle("FOLLOWER: " + me.followerCount.description, forSegmentAtIndex: 2)

        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // create refreshing control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(self.refreshControl, atIndex: 0)
        
        self.loadMoreTweets(false)
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
    
    func onNewTweet(tweet:Tweet) {
        // not for this view
    }
    
    func onFavorited(tweet:Tweet, responseTweet:Tweet, sender:TweetCell?) {
        self.tableView.reloadData()
    }
    
    func onRetweeted(tweet:Tweet, responseTweet:Tweet, sender:TweetCell?) {
        self.tableView.reloadData()
    }
    
    func onRefresh() {
        self.loadMoreTweets(true);
    }
    
    func onReplyRequest(tweet:Tweet) {
        self.tweetToReply = tweet
        self.performSegueWithIdentifier("me.reply.segue", sender: self)
    }
    
    func loadMoreTweets(endRefreshing:Bool){
        
        let showSpinner = !endRefreshing
        var sinceId:Int64? = self.tweets.count > 0 ? self.tweets[0].id : nil
        TwitterClient.sharedInstance.getUserTimeLine(sinceId) { (tweets:[Tweet]?) -> Void in
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
