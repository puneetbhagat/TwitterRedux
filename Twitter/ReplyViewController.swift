//
//  ReplyViewController.swift
//  Twitter
//
//  Created by Bhagat, Puneet on 4/15/17.
//  Copyright © 2017 Intuit. All rights reserved.
//

import UIKit

class ReplyViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var replyImageView: UIImageView!
    @IBOutlet weak var replyNameLabel: UILabel!
    @IBOutlet weak var replyScreenNameLabel: UILabel!
    @IBOutlet weak var replyTweetTextView: UITextView!
    @IBOutlet weak var replyCharactersRemainingLabel: UILabel!

    var tweet: Tweet?
    var numCharsRemaining: Int? {
        didSet {
            replyCharactersRemainingLabel.text = String(numCharsRemaining ?? 0) + " chars"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        replyTweetTextView.delegate = self

        replyNameLabel.text = tweet?.user?.name
        replyScreenNameLabel.text = tweet?.user?.screenName
        replyImageView.setImageWith((tweet?.user?.profileUrl)!)
        replyTweetTextView.text = "@\(tweet!.user!.screenName!) "
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onTweetButton(_ sender: Any) {
        if let text = replyTweetTextView.text {
            TwitterClient.sharedInstance.replyToTweet(withTweetId: (tweet?.tweetId!)!, andText: text,
                success: { (tweet: Tweet) in
                    let alert = UIAlertController(title: "Reply",
                                                  message: "Reply posted to @\(self.tweet!.user!.screenName!)",
                                                  preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK",
                                                 style: .destructive,
                                                 handler: { (action) in
                                                    self.dismiss(animated: true, completion: nil)
                                                 })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    print("success in replying to tweet!")
                },
                failure: { (error: Error?) in
                    print("Error replying to tweet: \(error?.localizedDescription)")
                }
            )
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        numCharsRemaining = 140 - replyTweetTextView.text.characters.count
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = replyTweetTextView.text ?? ""
        guard let stringRange = range.range(for: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return updatedText.characters.count <= 140
    }
}

extension NSRange {
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        
        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
        
        return fromIndex ..< toIndex
    }
}
