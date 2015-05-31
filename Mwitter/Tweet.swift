//
//  Tweet.swift
//  Mwitter
//
//  Created by Baris Taze on 5/22/15.
//  Copyright (c) 2015 Baris Taze. All rights reserved.
//

import Foundation

class Tweet {

    var id:Int64 = 0
    var text:String = ""
    var createdAt:NSDate?
    var favorited:Bool = false
    var retweeted:Bool = false
    var retweetCount:Int32 = 0
    var favoritesCount:Int32 = 0
    var user:Account?
    
    func initWithDictionary(dict:NSDictionary) -> Tweet {
        
        let createdAtString = dict["created_at"] as! String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        self.createdAt = formatter.dateFromString(createdAtString)
        
        self.id = (dict["id"] as! NSNumber).longLongValue
        self.text = dict["text"] as! String
        self.favorited = dict["favorited"] as! Bool
        self.retweeted = dict["retweeted"] as! Bool
        self.retweetCount = (dict["retweet_count"] as! NSNumber).intValue
        self.favoritesCount = (dict["favorites_count"] as? NSNumber)?.intValue ?? 0
        self.user = Account().initWithDictionary(dict["user"] as! NSDictionary)
        
        return self
    }
    
    class func fromArray(array:NSArray) -> [Tweet] {
        
        var tweets = [Tweet]()
        for val in array {
            tweets.append(Tweet().initWithDictionary(val as! NSDictionary))
        }
        
        return tweets
    }
}