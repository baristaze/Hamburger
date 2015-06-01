//
//  TweetReadViewController.swift
//  Mwitter
//
//  Created by Baris Taze on 5/26/15.
//  Copyright (c) 2015 Baris Taze. All rights reserved.
//

import UIKit

class TweetReadViewController: UIViewController {

    var tweet:Tweet?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var favCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favImageView: UIImageView!
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var replyImageView: UIImageView!
    
    static let favoriteImage = UIImage(named: "favorite_default")
    static let favoriteOnImage = UIImage(named: "favorite_on")
    
    static let retweetImage = UIImage(named: "retweet_default")
    static let retweetOnImage = UIImage(named: "retweet_on")
    
    private var favoriteTapRecognizer:UITapGestureRecognizer?
    private var retweetTapRecognizer:UITapGestureRecognizer?
    
    private var replyTapRecognizer1:UITapGestureRecognizer?
    private var replyTapRecognizer2:UITapGestureRecognizer?
    
    var delegate:TweetUpdateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.favoriteTapRecognizer = UITapGestureRecognizer(target:self, action:Selector("onFav:"))
        self.retweetTapRecognizer = UITapGestureRecognizer(target:self, action:Selector("onRetweet:"))
        self.favImageView.addGestureRecognizer(self.favoriteTapRecognizer!)
        self.retweetImageView.addGestureRecognizer(self.retweetTapRecognizer!)
        
        self.replyTapRecognizer1 = UITapGestureRecognizer(target:self, action:Selector("onReply:"))
        self.replyTapRecognizer2 = UITapGestureRecognizer(target:self, action:Selector("onReply:"))
        self.replyImageView.addGestureRecognizer(self.replyTapRecognizer1!)
        self.replyLabel.addGestureRecognizer(self.replyTapRecognizer2!)
        
        self.reloadDataFrom(self.tweet!)
    }

    func reloadDataFrom(tweet:Tweet) {
        
        self.profileImageView.setImageWithURL(NSURL(string:tweet.user!.profileImageUrl))
        self.nameLabel.text = tweet.user!.name
        self.screenNameLabel.text = "@" + tweet.user!.screenName
        self.bioLabel.text = tweet.user!.tagLine
        self.createdAtLabel.text = tweet.createdAt!.timeAgoSimple()
        self.tweetLabel.text = tweet.text
        self.favCountLabel.text = tweet.favoritesCount.description
        self.retweetCountLabel.text = tweet.retweetCount.description
        
        if tweet.favorited {
            self.favImageView.image = TweetReadViewController.favoriteOnImage
        }
        else {
            self.favImageView.image = TweetReadViewController.favoriteImage
        }
        
        if tweet.retweeted {
            self.retweetImageView.image = TweetReadViewController.retweetOnImage
        }
        else {
            self.retweetImageView.image = TweetReadViewController.retweetImage
        }
    }

    func onFav(recognizer:UITapGestureRecognizer){
        if(self.tweet!.favorited){
            return
        }
        
        TwitterClient.sharedInstance.favoriteById(self.tweet!.id, callback: { (updatedTweet:Tweet?) -> Void in
            if(updatedTweet != nil) {
                self.tweet!.favorited = true
                self.tweet!.favoritesCount++
                self.favCountLabel.text = self.tweet!.favoritesCount.description
                self.favImageView.image = TweetReadViewController.favoriteOnImage
                self.delegate?.onFavorited(self.tweet!, responseTweet: updatedTweet!, sender:nil)
            }
        })
    }
    
    func onRetweet(recognizer:UITapGestureRecognizer){
        if(self.tweet!.retweeted){
            return
        }

        TwitterClient.sharedInstance.retweetById(self.tweet!.id, callback: { (updatedTweet:Tweet?) -> Void in
            if(updatedTweet != nil) {
                self.tweet!.retweeted = true
                self.tweet!.retweetCount++
                self.retweetCountLabel.text = self.tweet!.retweetCount.description
                self.retweetImageView.image = TweetReadViewController.retweetOnImage
                self.delegate?.onRetweeted(self.tweet!, responseTweet: updatedTweet!, sender:nil)
            }
        })
    }

    func onReply(recognizer:UITapGestureRecognizer){
        self.performSegueWithIdentifier("tweet.reply.segue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onProfileImage(sender: AnyObject) {
        self.performSegueWithIdentifier("profile.vc.from.read", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var nav = segue.destinationViewController as! UINavigationController
        
        if(nav.topViewController is TweetViewController){
            var vc = nav.topViewController as! TweetViewController
            vc.tweetToReply = self.tweet!
        }
        else{
            var vc = nav.topViewController as! ProfileViewController
            vc.account = self.tweet!.user
        }
    }
}
