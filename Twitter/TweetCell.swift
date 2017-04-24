//
//  TweetCell.swift
//  Twitter
//
//  Created by Bhagat, Puneet on 4/14/17.
//  Copyright © 2017 Intuit. All rights reserved.
//

import UIKit
import AFNetworking

class TweetCell: UITableViewCell {

    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var twitterProfileView: UIImageView!
    @IBOutlet weak var tweetTimeSinceLabel: UILabel!
    
    
    var tweet: Tweet! {
        didSet {
            tweetLabel.text = tweet.text
            userNameLabel.text = tweet.user?.name
            timestampLabel.text = tweet.user?.screenName
            
            let ts = tweet.timestamp
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let dateString = dateFormatter.string(from: ts as! Date)
            timestampLabel.text = dateString
            
            dateFormatter.dateFormat = "MMM d"
            let sinceString = dateFormatter.string(from: ts as! Date)
            var sinceLabelText = sinceString
            if let since = tweet.timestamp?.timeIntervalSinceNow {
                let hours = round(since / 3600.0) * -1.0
                if hours < 1 {
                    let mins = round(since / 60.0) * -1.0
                    sinceLabelText = "\(Int(mins))m"
                } else if hours < 24 {
                    sinceLabelText = "\(Int(hours))h"
                }
                tweetTimeSinceLabel.text = sinceLabelText
            }
            
            
            twitterProfileView.setImageWith((tweet.user?.profileUrl)!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
