//
//  TwitterClient.swift
//  Mwitter
//
//  Created by Baris Taze on 5/22/15.
//  Copyright (c) 2015 Baris Taze. All rights reserved.
//

import UIKit

protocol TwitterClientProtocol {
    func onLoginTwitter()
}

class TwitterClient: BDBOAuth1RequestOperationManager {
 
    private static let kConsumerKey = "IF1zQnMYaTEcVYW2fPXca6iwi"
    private static let kConsumerSecret = "Vp6ajHiolNINK5EsOIwLkf8rpLw8kzSs4aHQQJVLt96nXpvC0b"
    private static let kBaseUrl = "https://api.twitter.com"
    
    var delegate:TwitterClientProtocol?
    
    private init(baseUrl:NSURL!, consumerKey:String, consumerSecret:String) {
        super.init(baseURL:baseUrl, consumerKey:consumerKey, consumerSecret:consumerSecret)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let sharedInstance = TwitterClient(baseUrl:NSURL(string:kBaseUrl), consumerKey:kConsumerKey, consumerSecret:kConsumerSecret)
    
    func login() {
        
        self.requestSerializer.removeAccessToken()
        
        self.fetchRequestTokenWithPath(
            "oauth/request_token",
            method: "GET",
            callbackURL: NSURL(string:"cptwitterdemo://oath"),
            scope: nil,
            success: { (requestToken:BDBOAuth1Credential!) -> Void in
                
                println("request token retrieved")
                let urlString = String(format: "%@/oauth/authorize?oauth_token=%@", TwitterClient.kBaseUrl, requestToken.token)
                let url = NSURL(string: urlString)
                UIApplication.sharedApplication().openURL(url!)
            },
            failure: { (error:NSError!) -> Void in
                UIAlertView(title: "Error", message: "request token failed", delegate: nil, cancelButtonTitle: "OK").show()
            })
    }
    
    func openUrl(url:NSURL) {
        
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        self.fetchAccessTokenWithPath(
            "oauth/access_token",
            method: "POST",
            requestToken: requestToken,
            success: { (accessToken:BDBOAuth1Credential!) -> Void in
                println("access token retrieved")
                self.requestSerializer.saveAccessToken(accessToken)
                if(self.delegate != nil) {
                    self.delegate!.onLoginTwitter()
                }
                // self.adHocTests()
            },
            failure: { (error:NSError!) -> Void in
                UIAlertView(title: "Error", message: "access token failed", delegate: nil, cancelButtonTitle: "OK").show()
            }
        )
    }
    
    func getCurrentAccount(callback:((Account?)->Void)){
        
        self.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
            println("account retrieved successfully")
            println(response)
            let a = Account().initWithDictionary(response as! NSDictionary)
            callback(a);
            
        }) { (AFHTTPRequestOperation, NSError) -> Void in
            callback(nil);
            println("retrieving account failed");
        }
    }
    
    func getHomeTimelineSince(sinceId:Int64?, callback:(([Tweet]?)->Void)) {
        
        var urlString = "1.1/statuses/home_timeline.json"
        if(sinceId != nil){
            urlString += "?since_id=" + sinceId!.description
        }
        self.GET(
            urlString,
            parameters: nil,
            success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                println("timeline retrieved successfully");
                let tweets = Tweet.fromArray(response as! NSArray)
                callback(tweets)
            },
            failure: { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                callback(nil)
                println("retrieving timeline failed: %@", error)
        })
    }
    
    func getMentionsSince(sinceId:Int64?, callback:([Tweet]? -> Void)) {

        var urlString = "1.1/statuses/mentions_timeline.json"
        if(sinceId != nil){
            urlString += "?since_id=" + sinceId!.description
        }
        self.GET(
            urlString,
            parameters: nil,
            success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                println("mentions retrieved successfully");
                let tweets = Tweet.fromArray(response as! NSArray)
                callback(tweets)
            },
            failure: { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                callback(nil)
                println("mentions timeline failed: %@", error)
        })
    }
    
    func getUserTimeLine(sinceId:Int64?, userScreenName:String?, callback:([Tweet]? -> Void)) {
        var urlString = "1.1/statuses/user_timeline.json"
        var delim = "?"
        if(sinceId != nil){
            urlString += "?since_id=" + sinceId!.description
            delim = "&"
        }
        if(userScreenName != nil){
            urlString += delim + "screen_name=" + userScreenName!
        }
        
        self.GET(
            urlString,
            parameters: nil,
            success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                println("user timeline retrieved successfully");
                let tweets = Tweet.fromArray(response as! NSArray)
                callback(tweets)
            },
            failure: { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                callback(nil)
                println("user timeline failed: %@", error)
        })

    }
    
    func tweet(text:String, callback:((Tweet?)->Void)) {
        
        let textEscaped = text.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        var urlString = "1.1/statuses/update.json?status=" + textEscaped!
        self.POST(
            urlString,
            parameters: nil,
            constructingBodyWithBlock: nil,
            success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                println("tweeted successfully")
                let tweet = Tweet().initWithDictionary(response as! NSDictionary)
                callback(tweet)
            })
            { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                println("tweeting failed: %@", error)
                callback(nil)
        }
    }
    
    func retweetById(id:Int64, callback:((Tweet?)->Void)) {
        
        var urlString = String(format:"1.1/statuses/retweet/%@.json", id.description)
        self.POST(
            urlString,
            parameters: nil,
            constructingBodyWithBlock: nil,
            success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                println("retweeted successfully")
                let tweet = Tweet().initWithDictionary(response as! NSDictionary)
                callback(tweet)
            })
            { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                println("retweeted failed: %@", error)
                callback(nil)
            }
    }
    
    func favoriteById(id:Int64, callback:((Tweet?)->Void)) {
        
        var urlString = String(format:"1.1/favorites/create.json?id=%@", id.description)
        self.POST(
            urlString,
            parameters: nil,
            constructingBodyWithBlock: nil,
            success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                println("fav successfully")
                let tweet = Tweet().initWithDictionary(response as! NSDictionary)
                callback(tweet)
            })
            { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                println("fav failed: %@", error)
                callback(nil)
        }
    }
    
    func replyById(id:Int64, text:String, callback:((Tweet?)->Void)) {
        
        let textEscaped = text.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        var urlString = "1.1/statuses/update.json?in_reply_to_status_id=" + id.description + "&status=" + textEscaped!
        self.POST(
            urlString,
            parameters: nil,
            constructingBodyWithBlock: nil,
            success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                println("replied successfully")
                let tweet = Tweet().initWithDictionary(response as! NSDictionary)
                callback(tweet)
            })
            { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                println("reply failed: %@", error)
                callback(nil)
        }
    }
    
    func logout(){
        self.requestSerializer.removeAccessToken()
    }
    
    private func adHocTests() {
        
        self.getCurrentAccount { (account:Account?) -> Void in
            println(account?.screenName ?? "no screenname")
        }
        
        self.getHomeTimelineSince(nil) { (tweets: [Tweet]?) -> Void in
            let count = tweets?.count ?? 0
            println(tweets?.count.description ?? "no tweets")
            if tweets != nil {
                for tweet in tweets! {
                    // println(String(format:"%@ - %@", tweet.createdAt!.timeAgo(), tweet.text))
                }
            }
        }
        
        self.tweet("test test test", callback: { (tweet:Tweet?) -> Void in
            println(tweet?.text ?? "no tweet")
            
            if(tweet != nil) {
                
                self.retweetById(tweet!.id, callback: { (updatedTweet:Tweet?) -> Void in
                    println(updatedTweet?.retweetCount.description ?? "no retweet")
                })
                
                self.favoriteById(tweet!.id, callback: { (updatedTweet:Tweet?) -> Void in
                    println(updatedTweet?.favoritesCount.description ?? "no fav")
                })
            }
        })
    }
}
