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
    
    var topView: UIView!
    var topViewTapGesture: UITapGestureRecognizer!
    var subtitleLabel: UILabel!
    var selectedIndex: Int = 0
    
    var signUpTabButton: UIButton!
    var loginTabButton: UIButton!
    var indicatorTriangleView: UIImageView! //indicate whether it's sign up or log in
    var isSignUpSelected = true
    
    var scrollView: UIScrollView!
    //sign up screen
    var credentialTextField: UITextField! //email in signup screen AND email/user in log in screen
    var orLabel: UILabel! // a label inside the separator from email textfield and facebook button
    var facebookButton: UIButton!
    
    //log in screen
    var passwordTextField: UITextField!
    var passwordTextFieldUnderline: UIView!
    var loginButton: UIButton!
    
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
        setUpViews()
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
        topView = UIView()
        topView.frame = CGRectMake(0, 0, self.viewWidth, 0.17 * self.viewHeight + self.statusAndNavigationBarHeight)
        topView.backgroundColor = UIColor(patternImage: UIImage(named: "meVCTopBackground")!)
        topViewTapGesture = UITapGestureRecognizer(target: self, action: "tapOnTopView:")
        topView.addGestureRecognizer(topViewTapGesture)
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
        signUpTabButton = UIButton(frame: CGRect(x: 0, y: topView.frame.height-50-yOffSet, width: viewWidth/2, height: 50))
        signUpTabButton.setTitle("Sign Up", forState: .Normal)
        signUpTabButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        signUpTabButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signUpTabButton.addTarget(self, action: "signUpTabPressed", forControlEvents: .TouchUpInside)
        topView.addSubview(signUpTabButton)
        
        loginTabButton = UIButton(frame: CGRect(x: viewWidth/2, y: signUpTabButton.frame.origin.y, width: viewWidth/2, height: 50))
        loginTabButton.setTitle("Log In", forState: .Normal)
        loginTabButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        loginTabButton.addTarget(self, action: "loginTabPressed", forControlEvents: .TouchUpInside)
        loginTabButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        topView.addSubview(loginTabButton)
        
        indicatorTriangleView = UIImageView(frame: CGRect(x: 0, y: topView.frame.height-10, width: 25, height: 10))
        indicatorTriangleView.image = UIImage(named: "triangle")
        indicatorTriangleView.center.x = signUpTabButton.center.x
        topView.addSubview(indicatorTriangleView)
    }
    
    func setUpViews() {
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: CGRectGetMaxY(topView.frame), width: viewWidth, height: viewHeight))
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize.height = self.scrollView.frame.size.height + 15
        self.view.addSubview(self.scrollView)
        
        //sign in screen
        let verticalMargin: CGFloat = 10
        credentialTextField = UITextField(frame: CGRect(x: 0, y: verticalMargin, width: viewWidth-20, height: 44))
        credentialTextField.placeholder = "Enter your email"
        credentialTextField.textAlignment = .Center
        credentialTextField.center.x = self.view.center.x
        credentialTextField.tintColor = UIColor.mainPinkColor()
        credentialTextField.clearButtonMode = .WhileEditing
        credentialTextField.autocapitalizationType = .None
        credentialTextField.autocorrectionType = .No
        credentialTextField.accessibilityIdentifier = "unedit"
        credentialTextField.addTarget(self, action: "valueChangedInEmailTextField:", forControlEvents: .EditingChanged)
        scrollView.addSubview(credentialTextField)
        
        let credentialTextFieldUnderline = UIView(frame: CGRect(x: credentialTextField.frame.origin.x, y: CGRectGetMaxY(credentialTextField.frame), width: credentialTextField.frame.width, height: 1))
        credentialTextFieldUnderline.backgroundColor = UIColor.lightGrayColor()
        scrollView.addSubview(credentialTextFieldUnderline)
        
        nextButton.frame = CGRectMake(0, CGRectGetMaxY(credentialTextFieldUnderline.frame)+verticalMargin, self.viewWidth, 44)
        nextButton.setTitle("Next", forState: UIControlState.Normal)
        nextButton.setTitleColor(UIColor.mainPinkColor(), forState: UIControlState.Normal)
        nextButton.addTarget(self, action: "pressNextButton:", forControlEvents: UIControlEvents.TouchUpInside)
        nextButton.hidden = true
        scrollView.addSubview(nextButton)
        
        //set it at the bottom of the scrollview
        let originY: CGFloat = self.view.frame.height - CGRectGetMaxY(topView.frame) - 44 - 64 - 10
        orLabel = UILabel(frame: CGRect(x: 0, y: originY, width: 50, height: 10))
        orLabel.text = "OR"
        orLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12)
        orLabel.textColor = UIColor.lightGrayColor()
        orLabel.backgroundColor = UIColor.whiteColor()
        orLabel.textAlignment = .Center
        orLabel.center.x = self.view.center.x
        scrollView.addSubview(orLabel)
        
        facebookButton = UIButton(frame: CGRect(x: 0, y: CGRectGetMaxY(orLabel.frame), width: viewWidth, height: 44))
        facebookButton.setTitle("Log in with facebook", forState: .Normal)
        facebookButton.setImage(UIImage(named: "facebook_icon"), forState: .Normal)
        facebookButton.setTitleColor(UIColor.facebookBlue(), forState: .Normal)
        facebookButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right:
            0)
        facebookButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        facebookButton.center.x = self.view.center.x
        scrollView.addSubview(facebookButton)

        //log in screen
        passwordTextField = UITextField(frame: CGRect(x: 0, y: CGRectGetMaxY(credentialTextFieldUnderline.frame)+verticalMargin, width: credentialTextField.frame.width, height: credentialTextField.frame.height))
        passwordTextField.secureTextEntry = true
        passwordTextField.hidden = true
        passwordTextField.placeholder = "Password"
        passwordTextField.textAlignment = .Center
        passwordTextField.tintColor = UIColor.mainPinkColor()
        scrollView.addSubview(passwordTextField)
        
        passwordTextFieldUnderline = UITextField(frame: CGRect(x: credentialTextFieldUnderline.frame.origin.x, y: CGRectGetMaxY(passwordTextField.frame), width: credentialTextFieldUnderline.frame.width, height: 1))
        passwordTextFieldUnderline.backgroundColor = UIColor.lightGrayColor()
        passwordTextFieldUnderline.hidden = true
        scrollView.addSubview(passwordTextFieldUnderline)
        
        loginButton = UIButton(frame: CGRect(x: 0, y: CGRectGetMaxY(passwordTextField.frame)+verticalMargin, width: viewWidth, height: 44))
        loginButton.setTitle("Log in", forState: .Normal)
        loginButton.addTarget(self, action: "pressLogInButton:", forControlEvents: .TouchUpInside)
        loginButton.titleLabel?.textAlignment = .Center
        loginButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        loginButton.hidden = true
        scrollView.addSubview(loginButton)
    }
    
    func signUpTabPressed() {
        self.indicatorTriangleView.center.x = self.signUpTabButton.center.x
        self.subtitleLabel.text = "Sign up to upload tabs and save your favorite songs"
        isSignUpSelected = true
        
        credentialTextField.placeholder = "Enter your email"
        if credentialTextField.text!.characters.count > 0 {
            nextButton.hidden = false
        }
        
        //hide log in views
        self.passwordTextField.hidden = true
        self.passwordTextFieldUnderline.hidden = true
        self.loginButton.hidden = true
    }
    
    func loginTabPressed() {
        self.indicatorTriangleView.center.x = self.loginTabButton.center.x
        self.subtitleLabel.text = "Log in to upload tabs and save your favorite songs"
        isSignUpSelected = false
        
        credentialTextField.placeholder = "Email or username"
        nextButton.hidden = true
        //show log in views
        self.passwordTextField.hidden = false
        self.passwordTextFieldUnderline.hidden = false
        self.loginButton.hidden = false
    }
    
    func tapOnTopView(sender: UITapGestureRecognizer) {
        self.credentialTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }

    func valueChangedInEmailTextField(sender: UITextField) {
        if !isSignUpSelected {
            return
        }
        
        if sender.text == "" {
            nextButton.hidden = true
            sender.accessibilityIdentifier = "unedit"
        } else if sender.accessibilityIdentifier == "unedit" {
            nextButton.hidden = false
            sender.accessibilityIdentifier = "edit"
        }
    }
    

    func pressNextButton(sender: UIButton) {
        if self.credentialTextField.text != "" {
            self.credentialTextField.resignFirstResponder()
            let meSignUpVC: MeSignUpViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("mesignupVC"))! as! MeSignUpViewController
            meSignUpVC.email = self.credentialTextField.text!
            self.navigationController?.pushViewController(meSignUpVC, animated: true)
        }
    }
    
    func pressLogInButton(sender: UIButton) {
        
        //UserManager.attemptLogin(emailLogInTextField.text!, password: passwordLogInTextField.text!, isEmail: true)

        let meVC: MeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("meVC") as! MeViewController
        //self.navigationController?.viewControllers = NSArray(object: meVC) as! [UIViewController]
        self.navigationController?.setViewControllers(NSArray(object: meVC) as! [UIViewController], animated: true)
        self.presentViewController(meVC, animated: true, completion: nil)
    }
}


