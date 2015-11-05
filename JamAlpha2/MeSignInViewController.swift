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

extension MeViewController {

    func initialSignInView() {
        self.setUpEditView()
        self.setUpTopView()
        self.setUpSignUpView()
    }
    
    func setUpEditView() {
        self.signInEditView.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight - (self.tabBarController?.tabBar.frame.size.height)!)
        self.signInEditView.backgroundColor = UIColor.grayColor()
        
        let tapOnEditView: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnEditView.addTarget(self, action: "tapOnEditView:")
        self.signInEditView.addGestureRecognizer(tapOnEditView)
    }
    
    func tapOnEditView(sender: UITapGestureRecognizer) {
        self.signInEmailTextField.resignFirstResponder()
        self.signInPasswordTextField.resignFirstResponder()
    }

    func setUpTopView() {
        let topView: UIView = UIView()
        topView.frame = CGRectMake(0, 0, self.viewWidth, 0.2 * self.viewHeight)
        self.signInEditView.addSubview(topView)
        
        let blurredImage: UIImage = self.signInTopViewImage.applyLightEffect()!
        
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
    
    func setUpSignUpView() {
        let signUpByFBView: UIView = UIView()
        signUpByFBView.frame = CGRectMake(0, 0.225 * self.viewHeight, self.viewWidth, 0.1 * self.viewHeight)
        signUpByFBView.layer.borderWidth = 1
        self.signInEditView.addSubview(signUpByFBView)
        
        self.setUpFBLogin(signUpByFBView)
        
        let orLabel: UILabel = UILabel()
        orLabel.frame = CGRectMake(0, 0.325 * self.viewHeight, self.viewWidth, 0.05 * self.viewHeight)
        orLabel.text = "or"
        orLabel.textAlignment = NSTextAlignment.Center
        self.signInEditView.addSubview(orLabel)
        
        let signUpByTJView: UIView = UIView()
        signUpByTJView.frame = CGRectMake(0, 0.375 * self.viewHeight, self.viewWidth, 0.21 * self.viewHeight)
        signUpByTJView.layer.borderWidth = 1
        self.signInEditView.addSubview(signUpByTJView)
        
        let emailTitleLabel: UILabel = UILabel()
        emailTitleLabel.frame = CGRectMake(0, 0, 0.3 * self.viewWidth, 0.1 * self.viewHeight)
        emailTitleLabel.text = "e-mail:"
        emailTitleLabel.textAlignment = NSTextAlignment.Right
        signUpByTJView.addSubview(emailTitleLabel)
        
        self.signInEmailTextField.frame = CGRectMake(0.3 * self.viewWidth, 0, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.signInEmailTextField.text = "example@gmail.com"
        signUpByTJView.addSubview(self.signInEmailTextField)
        
        let passwordTitleLabel: UILabel = UILabel()
        passwordTitleLabel.frame = CGRectMake(0, 0.11 * self.viewHeight, 0.3 * self.viewWidth, 0.1 * self.viewHeight)
        passwordTitleLabel.text = "password:"
        passwordTitleLabel.textAlignment = NSTextAlignment.Right
        signUpByTJView.addSubview(passwordTitleLabel)
        
        self.signInPasswordTextField.frame = CGRectMake(0.3 * self.viewWidth, 0.11 * self.viewHeight, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.signInPasswordTextField.text = "********"
        signUpByTJView.addSubview(self.signInPasswordTextField)
        
        let signInButton: UIButton = UIButton()
        signInButton.frame = CGRectMake(0.2 * self.viewWidth, 0.6 * self.viewHeight, 0.6 * self.viewWidth, 0.05 * self.viewHeight)
        signInButton.setTitle("Sign In", forState: UIControlState.Normal)
        signInButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        signInButton.layer.borderWidth = 1
        signInButton.addTarget(self, action: "pressSignInButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.signInEditView.addSubview(signInButton)
        
        let forgetPassword: UIButton = UIButton()
        forgetPassword.frame = CGRectMake(0.2 * self.viewWidth, 0.7 * self.viewHeight, 0.6 * self.viewWidth, 0.05 * self.viewHeight)
        forgetPassword.setTitle("Forgot Password", forState: UIControlState.Normal)
        forgetPassword.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        forgetPassword.layer.borderWidth = 1
        forgetPassword.addTarget(self, action: "pressForgetPasswordButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.signInEditView.addSubview(forgetPassword)
    }
    
    func pressSignInButton(sender: UIButton) {
        self.dismissSecondView(self.createAccountEditView)
        self.dismissSecondView(self.signInEditView)
    }
    
    func pressForgetPasswordButton(sender: UIButton) {
        print("forget password")
    }
    
    func pressBackButton(sender: UIButton) {
        self.dismissSecondView(self.signInEditView)
        self.addSecondView(self.createAccountEditView)
    }


}
