//
//  ProfileCell.swift
//  Twitter
//
//  Created by Bhagat, Puneet on 4/23/17.
//  Copyright © 2017 Intuit. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileUserNameLabel: UILabel!
    @IBOutlet weak var profileScreenNameLabel: UILabel!
    @IBOutlet weak var profileTweetLabel: UILabel!
    @IBOutlet weak var profileTimeStampLabel: UILabel!
    
    var tweet: Tweet! {
        didSet {
            profileTweetLabel.text = tweet.text
            profileUserNameLabel.text = tweet.user?.name
            profileScreenNameLabel.text = tweet.user?.screenName
            
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
                profileTimeStampLabel.text = sinceLabelText
            }
            
            
            profileImageView.setImageWith((tweet.user?.profileUrl)!)
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
