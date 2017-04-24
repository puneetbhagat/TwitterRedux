//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Bhagat, Puneet on 4/22/17.
//  Copyright © 2017 Intuit. All rights reserved.
//

import UIKit
import AFNetworking

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //hamburger bar button
    @IBOutlet weak var hamburgerBarButton: UIBarButtonItem!
    
    //header elements
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var screenNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    //tweets table elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var profileViewNumTweetsLabel: UILabel!
    @IBOutlet weak var profileNumFollowersLabel: UILabel!
    @IBOutlet weak var profileNumFollowingLabel: UILabel!
    
    //table view properties
    let maxHeaderHeight: CGFloat = 270;
    let minHeaderHeight: CGFloat = 135;
    var previousScrollOffset: CGFloat = 0
    var tweets = [Tweet]()
    var minTweetId = INT64_MAX
    var user = User.currentUser!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerHeightConstraint.constant = maxHeaderHeight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        //set header elements
        if let bannerUrl = user.bannerUrl {
            bannerImageView.setImageWith(bannerUrl)
        } else {
            //bannerImageView.image = UIImage(named: "twitter_default_banner")
        }
        
        if let profileUrl = user.profileUrl {
            profileImageView.setImageWith(profileUrl)
        }
        
        screenNameLabel.text = user.name
        profileViewNumTweetsLabel.text = "\(user.tweetCount!)"
        profileNumFollowersLabel.text = "\(user.followers!)"
        profileNumFollowingLabel.text = "\(user.following!)"
        
        //pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        fetchTweets(maxId: -1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }
    
    //get updated data
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        fetchTweets(maxId: -1)
        refreshControl.endRefreshing()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - previousScrollOffset
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        var newHeight = headerHeightConstraint.constant
        if isScrollingDown {
            newHeight = max(minHeaderHeight, headerHeightConstraint.constant - abs(scrollDiff))
        } else if isScrollingUp {
            newHeight = min(maxHeaderHeight, headerHeightConstraint.constant + abs(scrollDiff))
        }
        
        if newHeight != headerHeightConstraint.constant {
            headerHeightConstraint.constant = newHeight
            setScrollPosition(position: self.previousScrollOffset)
        }
        
        previousScrollOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidStopScrolling() {
        let range = maxHeaderHeight - minHeaderHeight
        let midPoint = minHeaderHeight + (range / 2)
        
        if headerHeightConstraint.constant > midPoint {
            // expand header
            self.expandHeader()
        } else {
            // condense header
            self.collapseHeader()
        }
    }
    
    func setScrollPosition(position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: position)
    }
    
    func collapseHeader() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func updateHeader() {
        let range = maxHeaderHeight - minHeaderHeight
        let openAmount = headerHeightConstraint.constant - minHeaderHeight
        let percentage = openAmount / range
        
        self.screenNameTopConstraint.constant = -openAmount + 10
        self.bannerImageView.alpha = percentage
    }
    
    func fetchTweets(maxId: Int64) {
        TwitterClient.sharedInstance.homeTimeline(withMaxId: maxId, success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.minTweetId = self.getMinTweetId(tweets: tweets)
            self.tableView.reloadData()
        }) { (error: Error) in
            print("error: \(error.localizedDescription)")
        }
    }
    
    func getMinTweetId(tweets: [Tweet]) -> Int64 {
        var minId = INT64_MAX
        for tweet in tweets {
            if tweet.tweetId! < minId {
                minId = tweet.tweetId!
            }
        }
        return minId
    }

}
