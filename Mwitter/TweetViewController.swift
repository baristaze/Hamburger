//
//  TweetViewController.swift
//  Mwitter
//
//  Created by Baris Taze on 5/23/15.
//  Copyright (c) 2015 Baris Taze. All rights reserved.
//

import UIKit

protocol NewTweetDelegate {
    func onNewTweet(tweet:Tweet)
}

class TweetViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var charCountLabel: UILabel!
    var delegate:NewTweetDelegate?
    var tweetToReply:Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.text = ""
        self.textView.backgroundColor = UIColor(red: 250, green: 250, blue: 210, alpha: 1.0)
        self.textView.layer.borderWidth = 0.5
        self.textView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.charCountLabel.text = "140"
        self.charCountLabel.textColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onEdit:"), name: UITextViewTextDidChangeNotification, object: nil)
        
        if(self.tweetToReply != nil) {
            self.textView.text = "@" + self.tweetToReply!.user!.screenName
        }
        
        self.textView.becomeFirstResponder()
    }

    func onEdit(notification:NSNotification) {
        let text = self.textView.text
        let remaining = (140 - count(text))
        self.charCountLabel.text = remaining.description
        if remaining < 0 {
            self.charCountLabel.textColor = UIColor.redColor()
        }
        else {
            self.charCountLabel.textColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
        }
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSend(sender: AnyObject) {
        var text = self.textView.text
        text = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if count(text) > 140 {
            UIAlertView(title: "Error", message: "Any tweet longer than 140 characters is not cool", delegate: nil, cancelButtonTitle: "OK").show()
            return
        }
        
        if(self.tweetToReply == nil) {
            TwitterClient.sharedInstance.tweet(text, callback: { (tweet:Tweet?) -> Void in
                if tweet != nil {
                    self.dismissViewControllerAnimated(true){
                        self.delegate?.onNewTweet(tweet!)
                    }
                }
                else {
                    UIAlertView(title: "Failed", message: "Sending tweet failed. Please try again later!", delegate: nil, cancelButtonTitle: "OK").show()
                }
            })
        }
        else {
            let mention = "@" + self.tweetToReply!.user!.screenName
            if(text.rangeOfString(mention) == nil){
                UIAlertView(title: "Error", message: "You need to mention " + mention, delegate: nil, cancelButtonTitle: "OK").show()
                return
            }
            else {
                TwitterClient.sharedInstance.replyById(self.tweetToReply!.id, text: text, callback: { (tweet:Tweet?) -> Void in
                    if tweet != nil {
                        self.dismissViewControllerAnimated(true){
                            self.delegate?.onNewTweet(tweet!)
                        }
                    }
                    else {
                        UIAlertView(title: "Failed", message: "Replying to the tweet failed. Please try again later!", delegate: nil, cancelButtonTitle: "OK").show()
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
