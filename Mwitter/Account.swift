//
//  Account.swift
//  Mwitter
//
//  Created by Baris Taze on 5/22/15.
//  Copyright (c) 2015 Baris Taze. All rights reserved.
//

import Foundation

class Account {
    
    private static let kCurrentUserKey = "CurrentUser.Persisted"
    
    var name:String = ""
    var screenName:String = ""
    var tagLine:String = ""
    var profileImageUrl:String = ""
    var location:String = ""
    
    private var originalDictionary:NSDictionary?
    
    func initWithDictionary(dict:NSDictionary) -> Account {
        
        self.name = dict["name"] as! String
        self.screenName = dict["screen_name"] as! String
        self.tagLine = dict["description"] as! String
        self.profileImageUrl = dict["profile_image_url"] as! String
        self.location = dict["location"] as! String
        
        self.originalDictionary = dict
        
        return self
    }
    
    func saveAsCurrentUser() -> Bool {
        
        if(self.originalDictionary != nil) {
            var data = NSJSONSerialization.dataWithJSONObject(self.originalDictionary!, options: NSJSONWritingOptions.allZeros, error: nil) as NSData?
            if(data != nil) {
                NSUserDefaults.standardUserDefaults().setObject(data!, forKey: Account.kCurrentUserKey)
                return true
            }
        }
        
        return false
    }
    
    class func currentUser() -> Account? {
        
        var data = NSUserDefaults.standardUserDefaults().objectForKey(Account.kCurrentUserKey) as? NSData
        if(data != nil) {
            var dict = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as! NSDictionary
            var user = Account().initWithDictionary(dict)
            return user
        }
        else {
            return nil
        }
    }
}