//
//  MentionCell.swift
//  Twitter
//
//  Created by Bhagat, Puneet on 4/22/17.
//  Copyright © 2017 Intuit. All rights reserved.
//

import UIKit

class MentionCell: UITableViewCell {

    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var twitterProfileView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    var tweet: Tweet! {
        didSet {
            userNameLabel.text = tweet.user?.name
            screenNameLabel.text = tweet.user?.screenName
            tweetLabel.text = tweet.text

            let ts = tweet.timestamp
            
            let dateFormatter = DateFormatter()
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
                timestampLabel.text = sinceLabelText
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
