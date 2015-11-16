//
//  FBLogin.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/4/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

extension MeLoginViewController: FBSDKLoginButtonDelegate {
    
    func setUpFBLogin() {
        self.fbLoginButton.delegate = self
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.fbLoginButton.loginBehavior = FBSDKLoginBehavior.Web
        self.fbLoginButton.defaultAudience = FBSDKDefaultAudience.Friends
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            returnUserData()
            if result.grantedPermissions.contains("email")
            {
                // Do work
                print("\(result)")
                returnUserData()

            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil){
                // Process error
                print("graph request Error: \(error)")
            } else {
                print("FB fetched user: \(result)")
                //self.userEmail = result.valueForKey("email") as! String
                self.userName = result.valueForKey("name") as! String
                self.userId = result.valueForKey("id") as! String
                self.userURL = "http://graph.facebook.com/\(self.userId)/picture?type=large"
            }
        })
    }
}