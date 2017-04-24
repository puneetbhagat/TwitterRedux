//
//  Tweet.swift
//  Twitter
//
//  Created by Bhagat, Puneet on 4/13/17.
//  Copyright © 2017 Intuit. All rights reserved.
//

import Foundation

class Tweet: NSObject {
    
    var text: String?
    var timestamp: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var user: User?
    var tweetId: Int64?
    var favorited: Bool?
    var retweeted: Bool?
    var isFavorite = false {
        didSet {
            if isFavorite {
                favoritesCount += 1
            } else {
                favoritesCount -= 1
            }
        }
    }
    var isRetweeted = false {
        didSet {
            if isRetweeted {
                retweetCount += 1
            } else {
                retweetCount -= 1
            }
        }
    }

    func callbackSuccess(tweet: Tweet) {
    }
    
    func callbackFailure(error: Error) {
        print("unable to set flag for isFavorite or isRetweeted")
    }
    
    
    init(tweetDict: NSDictionary) {
        self.text = tweetDict["text"] as? String
        
        let createdAtString = tweetDict["created_at"] as? String
        if let createdAtString = createdAtString {
            let dateFormatter = DateFormatter()
            //Tue Aug 28 21:16:23 +0000 2012
            dateFormatter.dateFormat = "EEEE MMM d HH:mm:ss Z yyyy"
            self.timestamp = dateFormatter.date(from: createdAtString) as NSDate?
        }
        
        self.retweetCount = (tweetDict["retweet_count"] as? Int) ?? 0
        self.favoritesCount = (tweetDict["favourites_count"] as? Int) ?? 0
        self.user = User(user: tweetDict["user"] as! NSDictionary)
        self.tweetId = tweetDict["id"] as? Int64
        self.favorited = tweetDict["favorited"] as? Bool
        self.retweeted = tweetDict["retweeted"] as? Bool
    }
    
    //get the complete list of tweets
    class func getTweetsArray(dicts: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dict in dicts {
            tweets.append(Tweet(tweetDict: dict))
        }
        return tweets
    }
}
