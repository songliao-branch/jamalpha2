//
//  MeSignInViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/3/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class MeSignInViewController: UIViewController {

    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    var emailTextField: UITextField = UITextField()
    var passwordTextField: UITextField = UITextField()
    
    var topViewImage: UIImage = UIImage(named: "meVCTopBackground")!
    
    var fbLoginManager: FBSDKLoginManager!
    var userName: String!
    var userId: String!
    var userURL: String!
    
    var editView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUpEditView()
        self.setUpTopView()
        self.setUpSignUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpEditView() {
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        self.editView.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight)
        self.editView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(self.editView)
        
        let tapOnEditView: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnEditView.addTarget(self, action: "tapOnEditView:")
        self.editView.addGestureRecognizer(tapOnEditView)
    }
    
    func tapOnEditView(sender: UITapGestureRecognizer) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }

    func setUpTopView() {
        let topView: UIView = UIView()
        topView.frame = CGRectMake(0, 0, self.viewWidth, 0.2 * self.viewHeight)
        self.editView.addSubview(topView)
        
        let blurredImage: UIImage = topViewImage.applyLightEffect()!
        
        let topImageView: UIImageView = UIImageView()
        topImageView.frame = CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height)
        topImageView.image = blurredImage
        topView.addSubview(topImageView)
        
        let headLine: UILabel = UILabel()
        headLine.frame = CGRectMake(0.2 * topView.frame.size.width, 0.2 * topView.frame.size.height, 0.6 * topView.frame.size.width, 0.4 * topView.frame.size.height)
        headLine.text = "Sign in"
        headLine.textAlignment = NSTextAlignment.Center
        topView.addSubview(headLine)
        
        let subHeadLine: UILabel = UILabel()
        subHeadLine.frame = CGRectMake(0.1 * topView.frame.size.width, 0.6 * topView.frame.size.height, 0.8 * topView.frame.size.width, 0.2 * topView.frame.size.height)
        subHeadLine.font = UIFont.systemFontOfSize(12)
        subHeadLine.text = "to upload tabs and save your favorite songs"
        subHeadLine.textAlignment = NSTextAlignment.Center
        topView.addSubview(subHeadLine)
        
        let backButton: UIButton = UIButton()
        backButton.frame = CGRectMake(0.05 * self.viewHeight, 0.05 * self.viewHeight, 0.05 * self.viewHeight, 0.05 * self.viewHeight)
        backButton.setTitle("B", forState: UIControlState.Normal)
        backButton.layer.borderWidth = 1
        backButton.addTarget(self, action: "pressBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        topView.addSubview(backButton)
    }
    
    func pressBackButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setUpSignUpView() {
        let signUpByFBView: UIView = UIView()
        signUpByFBView.frame = CGRectMake(0, 0.225 * self.viewHeight, self.viewWidth, 0.1 * self.viewHeight)
        signUpByFBView.layer.borderWidth = 1
        self.editView.addSubview(signUpByFBView)
        
        self.setUpFBLogin(signUpByFBView)
        
        let orLabel: UILabel = UILabel()
        orLabel.frame = CGRectMake(0, 0.325 * self.viewHeight, self.viewWidth, 0.05 * self.viewHeight)
        orLabel.text = "or"
        orLabel.textAlignment = NSTextAlignment.Center
        self.editView.addSubview(orLabel)
        
        let signUpByTJView: UIView = UIView()
        signUpByTJView.frame = CGRectMake(0, 0.375 * self.viewHeight, self.viewWidth, 0.21 * self.viewHeight)
        signUpByTJView.layer.borderWidth = 1
        self.editView.addSubview(signUpByTJView)
        
        let emailTitleLabel: UILabel = UILabel()
        emailTitleLabel.frame = CGRectMake(0, 0, 0.3 * self.viewWidth, 0.1 * self.viewHeight)
        emailTitleLabel.text = "e-mail:"
        emailTitleLabel.textAlignment = NSTextAlignment.Right
        signUpByTJView.addSubview(emailTitleLabel)
        
        self.emailTextField.frame = CGRectMake(0.3 * self.viewWidth, 0, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.emailTextField.text = "example@gmail.com"
        signUpByTJView.addSubview(self.emailTextField)
        
        let passwordTitleLabel: UILabel = UILabel()
        passwordTitleLabel.frame = CGRectMake(0, 0.11 * self.viewHeight, 0.3 * self.viewWidth, 0.1 * self.viewHeight)
        passwordTitleLabel.text = "password:"
        passwordTitleLabel.textAlignment = NSTextAlignment.Right
        signUpByTJView.addSubview(passwordTitleLabel)
        
        self.passwordTextField.frame = CGRectMake(0.3 * self.viewWidth, 0.11 * self.viewHeight, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.passwordTextField.text = "********"
        signUpByTJView.addSubview(self.passwordTextField)
        
        let forgetPassword: UIButton = UIButton()
        forgetPassword.frame = CGRectMake(0.2 * self.viewWidth, 0.6 * self.viewHeight, 0.6 * self.viewWidth, 0.05 * self.viewHeight)
        forgetPassword.setTitle("Forgot Password", forState: UIControlState.Normal)
        forgetPassword.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        forgetPassword.layer.borderWidth = 1
        forgetPassword.addTarget(self, action: "pressForgetPasswordButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.editView.addSubview(forgetPassword)
    }
    
    func pressForgetPasswordButton(sender: UIButton) {
        print("forget password")
    }

}

// facebook login
extension MeSignInViewController: FBSDKLoginButtonDelegate {
    
    func setUpFBLogin(sender: UIView) {
        let fbLoginButton: FBSDKLoginButton = FBSDKLoginButton()
        fbLoginButton.frame = CGRectMake(0.2 * self.viewWidth, 0.2 * sender.frame.size.height, 0.6 * self.viewWidth, 0.6 * sender.frame.size.height)
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        sender.addSubview(fbLoginButton)
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
                self.userName = result.valueForKey("name") as! String
                self.userId = result.valueForKey("id") as! String
                self.userURL = "http://graph.facebook.com/\(self.userId)/picture?type=large"
            }
        })
    }
}