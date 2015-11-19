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
    
    
    //TODO: add callback
    class func signUp(email:String, password: String) {
        
        let parameters = [
            "email": email,
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
    
    
    //user can login with either email or username
    class func attemptLogin(email: String, password: String) {
        
        var parameters = [String: String]()
        
        parameters = [
            "attempt_login": "0", //the value does not matter
            "email": email,
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
    

}