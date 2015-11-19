//
//  MeViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/8/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class MeLoginOrSignupViewController: UIViewController {

    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    var statusAndNavigationBarHeight: CGFloat = CGFloat()
    
    var subtitleLabel: UILabel!
    var selectedIndex: Int = 0
    
    var signUpButton: UIButton!
    var logInButton: UIButton!
    var indicatorTriangleView: UIImageView! //indicate whether it's sign up or log in
    
    var editSignUpScrollView: UIScrollView = UIScrollView()
    var editLogInScrollView: UIScrollView = UIScrollView()
    
    var emailSignUpTextField: UITextField = UITextField()
    var emailSignUpBackgroundLabel: UILabel = UILabel()
    var resetButton: UIButton = UIButton()
    
    var emailLogInBackgroundLabel: UILabel = UILabel()
    let emailLogInTextField: UITextField = UITextField()
    var passwordLogInBackgroundLabel: UILabel = UILabel()
    let passwordLogInTextField: UITextField = UITextField()
    
    var fbLoginButton: FBSDKLoginButton = FBSDKLoginButton()
    var nextButton: UIButton = UIButton()
    
    var userName: String!
    var userId: String!
    var userURL: String!
    var userEmail: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        self.statusAndNavigationBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height + (self.navigationController?.navigationBar.height)!
        
        setUpNavigationBar()
        setUpTopView()
        setUpSignUpEditScrollView()
        setUpLogInEditScrollView()
    }

    
    override func viewWillAppear(animated: Bool) {
        setUpNavigationBar()
    }
    
    func setUpNavigationBar(){
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        // hide the navigation bar
        self.navigationController?.navigationBar.hidden = true
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    func setUpTopView() {
        let topView: UIView = UIView()
        topView.frame = CGRectMake(0, 0, self.viewWidth, 0.17 * self.viewHeight + self.statusAndNavigationBarHeight)
        topView.backgroundColor = UIColor(patternImage: UIImage(named: "meVCTopBackground")!)
        self.view.addSubview(topView)
        
        let imageWidth: CGFloat = self.viewWidth / 3
        let imageHeight: CGFloat = (self.navigationController?.navigationBar.frame.size.height)! - 15
        let titleImageView: UIImageView = UIImageView()
        titleImageView.frame = CGRectMake(topView.frame.size.width / 2 - imageWidth / 2, UIApplication.sharedApplication().statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.size.height)! / 2 - imageHeight / 2 + 5, imageWidth, imageHeight)
        titleImageView.image = UIImage(named: "logo_bold")
        topView.addSubview(titleImageView)
        
        subtitleLabel = UILabel()
        subtitleLabel.frame = CGRectMake(0, self.statusAndNavigationBarHeight, topView.frame.size.width, 0.1 * self.viewHeight)
        subtitleLabel.text = "Sign up to upload tabs and save your favorite songs"
        subtitleLabel.textColor = UIColor.whiteColor()
        subtitleLabel.font = UIFont.systemFontOfSize(15)
        subtitleLabel.textAlignment = NSTextAlignment.Center
        subtitleLabel.numberOfLines = 2
        subtitleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        topView.addSubview(subtitleLabel)
    
        let yOffSet: CGFloat = 10
        signUpButton = UIButton(frame: CGRect(x: 0, y: topView.frame.height-50-yOffSet, width: viewWidth/2, height: 50))
        signUpButton.setTitle("Sign Up", forState: .Normal)
        signUpButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        signUpButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signUpButton.addTarget(self, action: "tapToSignUp:", forControlEvents: .TouchUpInside)
        topView.addSubview(signUpButton)
        
        logInButton = UIButton(frame: CGRect(x: viewWidth/2, y: signUpButton.frame.origin.y, width: viewWidth/2, height: 50))
        logInButton.setTitle("Log In", forState: .Normal)
        logInButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        logInButton.addTarget(self, action: "tapToLogIn:", forControlEvents: .TouchUpInside)
        logInButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        topView.addSubview(logInButton)
        
        indicatorTriangleView = UIImageView(frame: CGRect(x: 0, y: topView.frame.height-10, width: 25, height: 10))
        indicatorTriangleView.image = UIImage(named: "triangle")
        indicatorTriangleView.center.x = signUpButton.center.x
        topView.addSubview(indicatorTriangleView)
    }
    
    func tapToLogIn(sender: UIButton) {
        self.indicatorTriangleView.center.x = self.logInButton.center.x
        self.subtitleLabel.text = "Log in to upload tabs and save your favorite songs"
        if self.selectedIndex == 0 {
            self.editSignUpScrollView.removeFromSuperview()
            self.view.addSubview(self.editLogInScrollView)
            self.selectedIndex = 1
        }
    }

    func tapToSignUp(sender: UIButton) {
        self.indicatorTriangleView.center.x = self.signUpButton.center.x
        self.subtitleLabel.text = "Sign up to upload tabs and save your favorite songs"
        if self.selectedIndex == 1 {
            self.editLogInScrollView.removeFromSuperview()
            self.view.addSubview(self.editSignUpScrollView)
            self.selectedIndex = 0
        }
    }
    
    func tapOnTopView(sender: UITapGestureRecognizer) {
        self.emailSignUpTextField.resignFirstResponder()
        self.emailLogInTextField.resignFirstResponder()
        self.passwordLogInTextField.resignFirstResponder()
    }

}

// log in scroll view
extension MeLoginOrSignupViewController {
    func setUpLogInEditScrollView() {
        self.editLogInScrollView.frame = CGRectMake(0, 0.17 * self.viewHeight + self.statusAndNavigationBarHeight, self.viewWidth, self.viewHeight - self.statusAndNavigationBarHeight - (self.tabBarController?.tabBar.frame.size.height)! - 0.17 * self.viewHeight)
        self.editLogInScrollView.contentSize = CGSizeMake(self.viewWidth, self.editLogInScrollView.frame.size.height + 15)
        
        self.emailLogInBackgroundLabel.frame = CGRectMake(0.1 * self.viewHeight, 0, self.viewWidth - 0.1 * self.viewHeight, 0.1 * self.viewHeight)
        self.emailLogInBackgroundLabel.text = "Enter your email"
        self.emailLogInBackgroundLabel.textColor = UIColor.grayColor()
        self.editLogInScrollView.addSubview(self.emailLogInBackgroundLabel)
        
        
        self.emailLogInTextField.frame = CGRectMake(0.1 * self.viewHeight, 0, self.viewWidth - 0.1 * self.viewHeight, 0.1 * self.viewHeight)
        self.emailLogInTextField.backgroundColor = UIColor.clearColor()
        self.emailLogInTextField.addTarget(self, action: "valueChangedInLogInEmailTextField:", forControlEvents: UIControlEvents.EditingChanged)
        self.emailLogInTextField.accessibilityIdentifier = "unedit"
        self.emailLogInTextField.autocorrectionType = UITextAutocorrectionType.No
        self.editLogInScrollView.addSubview(self.emailLogInTextField)
        
        self.passwordLogInBackgroundLabel.frame = CGRectMake(0.1 * self.viewHeight, 0.1 * self.viewHeight, self.viewWidth - 0.1 * self.viewHeight, 0.1 * self.viewHeight)
        self.passwordLogInBackgroundLabel.text = "Enter your password"
        self.passwordLogInBackgroundLabel.textColor = UIColor.grayColor()
        self.editLogInScrollView.addSubview(self.passwordLogInBackgroundLabel)
        
        self.passwordLogInTextField.frame = CGRectMake(0.1 * self.viewHeight, 0.1 * self.viewHeight, self.viewWidth - 0.1 * self.viewHeight, 0.1 * self.viewHeight)
        self.passwordLogInTextField.backgroundColor = UIColor.clearColor()
        self.passwordLogInTextField.addTarget(self, action: "valueChangedInLogInPasswordTextField:", forControlEvents: UIControlEvents.EditingChanged)
        self.passwordLogInTextField.accessibilityIdentifier = "unedit"
        self.passwordLogInTextField.autocorrectionType = UITextAutocorrectionType.No
        self.editLogInScrollView.addSubview(self.passwordLogInTextField)
        
        let logInButton: UIButton = UIButton()
        logInButton.frame = CGRectMake(0, 0.2 * self.viewHeight, self.viewWidth, 0.1 * self.viewHeight)
        logInButton.setTitle("Log In", forState: UIControlState.Normal)
        logInButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        logInButton.addTarget(self, action: "pressLogInButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.editLogInScrollView.addSubview(logInButton)
    }
    
    func valueChangedInLogInEmailTextField(sender: UITextField) {
        if sender.text == "" {
            self.editLogInScrollView.addSubview(self.emailLogInBackgroundLabel)
            sender.accessibilityIdentifier = "unedit"
        } else {
            if sender.accessibilityIdentifier == "unedit" {
                self.emailLogInBackgroundLabel.removeFromSuperview()
                sender.accessibilityIdentifier = "edit"
            }
        }
    }
    
    func valueChangedInLogInPasswordTextField(sender: UITextField) {
        if sender.text == "" {
            self.editLogInScrollView.addSubview(self.passwordLogInBackgroundLabel)
            sender.accessibilityIdentifier = "unedit"
        } else {
            if sender.accessibilityIdentifier == "unedit" {
                self.passwordLogInBackgroundLabel.removeFromSuperview()
                sender.accessibilityIdentifier = "edit"
            }
        }
    }
    
    func pressLogInButton(sender: UIButton) {
        
        UserManager.attemptLogin(emailLogInTextField.text!, password: passwordLogInTextField.text!, isEmail: true)
        
//        
//        let meVC: MeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("meVC") as! MeViewController
//        //self.navigationController?.viewControllers = NSArray(object: meVC) as! [UIViewController]
//        self.navigationController?.setViewControllers(NSArray(object: meVC) as! [UIViewController], animated: true)
//        //self.presentViewController(meVC, animated: true, completion: nil)
    }
}

// sign up scroll view
extension MeLoginOrSignupViewController {
    func setUpSignUpEditScrollView() {
        self.editSignUpScrollView.frame = CGRectMake(0, 0.17 * self.viewHeight + self.statusAndNavigationBarHeight, self.viewWidth, self.viewHeight - self.statusAndNavigationBarHeight - (self.tabBarController?.tabBar.frame.size.height)! - 0.17 * self.viewHeight)
        self.editSignUpScrollView.contentSize = CGSizeMake(self.viewWidth, self.editSignUpScrollView.frame.size.height + 15)
        self.view.addSubview(self.editSignUpScrollView)
        
        self.fbLoginButton.frame = CGRectMake(0, 0.12 * self.viewHeight, self.viewWidth, 0.1 * self.viewHeight)
        self.setUpFBLogin()
        self.editSignUpScrollView.addSubview(self.fbLoginButton)
        
        self.nextButton.frame = CGRectMake(0, 0.12 * self.viewHeight, self.viewWidth, 0.1 * self.viewHeight)
        self.nextButton.setTitle("Next", forState: UIControlState.Normal)
        self.nextButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.nextButton.addTarget(self, action: "pressNextButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.resetButton.frame = CGRectMake(self.viewWidth - 0.1 * self.viewHeight, 0, 0.1 * self.viewHeight, 0.1 * self.viewHeight)
        self.resetButton.setTitle("R", forState: UIControlState.Normal)
        self.resetButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.resetButton.addTarget(self, action: "pressResetButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.emailSignUpBackgroundLabel.frame = CGRectMake(0.1 * self.viewHeight, 0, self.viewWidth - 0.1 * self.viewHeight, 0.1 * self.viewHeight)
        self.emailSignUpBackgroundLabel.text = "Enter your email"
        self.emailSignUpBackgroundLabel.textColor = UIColor.grayColor()
        self.editSignUpScrollView.addSubview(self.emailSignUpBackgroundLabel)
        
        self.emailSignUpTextField.frame = CGRectMake(0.1 * self.viewHeight, 0, self.viewWidth - 0.1 * self.viewHeight, 0.1 * self.viewHeight)
        self.emailSignUpTextField.backgroundColor = UIColor.clearColor()
        self.emailSignUpTextField.addTarget(self, action: "valueChangedInEmailTextField:", forControlEvents: UIControlEvents.EditingChanged)
        self.emailSignUpTextField.accessibilityIdentifier = "unedit"
        self.emailSignUpTextField.autocorrectionType = UITextAutocorrectionType.No
        self.editSignUpScrollView.addSubview(self.emailSignUpTextField)
        
    }
    
    func valueChangedInEmailTextField(sender: UITextField) {
        if sender.text == "" {
            self.editSignUpScrollView.addSubview(self.emailSignUpBackgroundLabel)
            self.editSignUpScrollView.addSubview(fbLoginButton)
            self.nextButton.removeFromSuperview()
            self.resetButton.removeFromSuperview()
            sender.accessibilityIdentifier = "unedit"
        } else {
            if sender.accessibilityIdentifier == "unedit" {
                self.emailSignUpBackgroundLabel.removeFromSuperview()
                self.fbLoginButton.removeFromSuperview()
                self.editSignUpScrollView.addSubview(self.nextButton)
                self.editSignUpScrollView.addSubview(self.resetButton)
                sender.accessibilityIdentifier = "edit"
            }
        }
    }
    
    func pressResetButton(sender: UIButton) {
        self.emailSignUpTextField.text = ""
        self.emailSignUpTextField.accessibilityIdentifier = "unedit"
        self.editSignUpScrollView.addSubview(self.emailSignUpBackgroundLabel)
        self.editSignUpScrollView.addSubview(self.fbLoginButton)
        self.resetButton.removeFromSuperview()
        self.nextButton.removeFromSuperview()
    }
    
    func pressNextButton(sender: UIButton) {
        if self.emailSignUpTextField.text != "" {
            self.emailSignUpTextField.resignFirstResponder()
            self.emailLogInTextField.resignFirstResponder()
            self.passwordLogInTextField.resignFirstResponder()
            let meSignUpVC: MeSignUpViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("mesignupVC"))! as! MeSignUpViewController
            meSignUpVC.email = self.emailSignUpTextField.text!
            self.navigationController?.pushViewController(meSignUpVC, animated: true)
        }
    }
}
