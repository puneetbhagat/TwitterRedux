//
//  TwitterClient.swift
//  Twitter
//
//  Created by Bhagat, Puneet on 4/14/17.
//  Copyright © 2017 Intuit. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "zJkMaqDk0VuttH2VGSstGcyM1", consumerSecret: "8hQaOxdmtVhv6HO7H66AMxShaq423KjxZrrIPhsultYQ1uIoxo")!
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        //get the request token
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string:"apTwitterDemo://oauth"), scope: nil,
            success: { (requestToken: BDBOAuth1Credential?) in
                print("Got the request token!")
                                            
                //allow safari to open the redirect link
                if let token = requestToken?.token {
                    let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)")!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            },
            failure: { (error: Error?) in
                print("Error: \(error?.localizedDescription)")
                self.loginFailure?(error!)
            }
        )
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        deauthorize()
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken,
            success: { (accessToken: BDBOAuth1Credential?) in
                self.currentAccount(
                    success: { (user: User) in
                        User.currentUser = user
                        self.loginSuccess?()
                    },
                    failure: { (error: Error) in
                        print("error: \(error.localizedDescription)")
                        self.loginFailure?(error)
                    }
                )
            },
            failure: { (error: Error?) in
                print("Was unable to get access token: \(error?.localizedDescription)")
                self.loginFailure?(error!)
            }
        )
    }
    
    //get tweets from the home timeline
    func homeTimeline(withMaxId tweetId: Int64, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        var params = [String: Any]()
        
        if tweetId != -1 {
            params["max_id"] = tweetId
        }
        
        get("1.1/statuses/home_timeline.json", parameters: params, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) in
                let tweetsDictArr = response as! [NSDictionary]
                let tweets = Tweet.getTweetsArray(dicts: tweetsDictArr)
                success(tweets)
            },
            
            failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            }
        )
    }
    
    //get tweets from the home timeline
    func mentionsTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/mentions_timeline.json", parameters: nil, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) in
                let tweetsDictArr = response as! [NSDictionary]
                let tweets = Tweet.getTweetsArray(dicts: tweetsDictArr)
                success(tweets)
        },
            
            failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
        }
        )
    }
    
    //verify the current credentials of the logged in account
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) in
                let userDict = response as! NSDictionary
                let user = User(user: userDict)
                
                success(user)
            },
            failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            }
        )
    }
    
    //reply to a tweet
    func replyToTweet(withTweetId tweetId: Int64, andText text:String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var params = [String: Any]()
        params["status"] = text
        params["in_reply_to_status_id"] = tweetId
        
        post("1.1/statuses/update.json", parameters: params, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) in
                let replyTweet = Tweet(tweetDict: response as! NSDictionary)
                success(replyTweet)
            },
            failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            }
        )
    }
    
    //retweet or unretweet
    func retweet(withTweetId tweetId: Int64, alreadyRetweeted: Bool, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var url: String?
        if(alreadyRetweeted) {
            url = "1.1/statuses/unretweet/\(tweetId).json"
        } else {
            url = "1.1/statuses/retweet/\(tweetId).json"
        }
        post(url!, parameters: nil, progress: nil,
             success: { (task: URLSessionDataTask, response: Any?) in
                let retweetTweet = Tweet(tweetDict: response as! NSDictionary)
                success(retweetTweet)
            },
             failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            }
        )
    }
    
    //favorite or unfavorite
    func favorite(withTweetId tweetId: Int64, alreadyFavorited: Bool, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var url: String?
        if(alreadyFavorited) {
            url = "1.1/favorites/destroy.json"
        } else {
            url = "1.1/favorites/create.json"
        }
        
        var params = [String: Any]()
        params["id"] = tweetId
        
        post(url!, parameters: params, progress: nil,
             success: { (task: URLSessionDataTask, response: Any?) in
                let favTweet = Tweet(tweetDict: response as! NSDictionary)
                success(favTweet)
            },
             failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            }
        )
    }    
}
