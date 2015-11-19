//
//  UserManager.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/17/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let userTokenKey = "USERTOKENKEY"

//TODO: this entire class is pending changes upon finished API
class UserManager: NSObject {
    

    class func validateEmail(email: String) {
        
    }
    
    class func validateUsername(username: String) {
    
    }
    //user can login with either email or username
    class func attemptLogin(credential: String, password: String, isEmail: Bool) {
        
        var parameters = [String: String]()
        
        let credentialKey = isEmail ? "email" : "username"
        parameters = [
            "attempt_login": "0", //the value does not matter
            credentialKey: credential,
            "password": password
        ]
        
        Alamofire.request(.POST, jamBaseURL + "/users", parameters: parameters, encoding: .JSON).responseJSON
            {
                response in
                switch response.result {
                case .Success:
                    print(response)
                    // store user token
                case .Failure(let error):
                    print(error)
                }
        }
        
    }
    
    
    //TODO: add callback
    class func signUp(email:String, username: String, password: String) {
        
        let parameters = [
            "email": email,
            "username": username,
            "password": password
        ]

        Alamofire.request(.POST, jamBaseURL + "/users", parameters: parameters, encoding: .JSON).responseJSON
            {
                response in
                switch response.result {
                case .Success:
                    print(response)
                    
                    
                    //store user token
                    print("User created")
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
}