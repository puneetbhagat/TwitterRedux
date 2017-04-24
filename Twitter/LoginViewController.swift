//
//  LoginViewController.swift
//  Twitter
//
//  Created by Bhagat, Puneet on 4/13/17.
//  Copyright © 2017 Intuit. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onLogin(_ sender: Any) {
        TwitterClient.sharedInstance.login(success: {
            print("logged in successfully")
            //self.performSegue(withIdentifier: "loginSegue", sender: nil)
            //self.performSegue(withIdentifier: "loginToMentionsSegue", sender: nil)
            self.performSegue(withIdentifier: "LoginSegue", sender: nil)
        }) { (error: Error) in
            print("error with logging in: \(error.localizedDescription)")
        }
    }
}
