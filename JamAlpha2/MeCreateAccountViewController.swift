//
//  MeViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/2/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit


// create accoount 
extension MeViewController {
    
    func initialCreateAccountView() {
        self.setUpCreatAccountEditView()
        self.setUpCreatAccountTopView()
        self.setUpCreatAccountSignUpView()
    }
    
    func setUpCreatAccountEditView() {
        self.createAccountEditView.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight - (self.tabBarController?.tabBar.frame.size.height)!)
        self.createAccountEditView.backgroundColor = UIColor.grayColor()
        
        let tapOnEditView: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnEditView.addTarget(self, action: "tapOnEditView:")
        self.createAccountEditView.addGestureRecognizer(tapOnEditView)
    }
    
    func tapOnCreatAccountEditView(sender: UITapGestureRecognizer) {
        self.createAccountEmailTextField.resignFirstResponder()
        self.createAccountPasswordTextField.resignFirstResponder()
    }
    
    
    func setUpCreatAccountTopView() {
        let topView: UIView = UIView()
        topView.frame = CGRectMake(0, 0, self.viewWidth, 0.2 * self.viewHeight)
        self.createAccountEditView.addSubview(topView)
        
        let blurredImage: UIImage = self.createAccountTopViewImage.applyLightEffect()!
        
        let topImageView: UIImageView = UIImageView()
        topImageView.frame = CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height)
        topImageView.image = blurredImage
        topView.addSubview(topImageView)
        
        let headLine: UILabel = UILabel()
        headLine.frame = CGRectMake(0.2 * topView.frame.size.width, 0.2 * topView.frame.size.height, 0.6 * topView.frame.size.width, 0.4 * topView.frame.size.height)
        headLine.text = "Create Account"
        headLine.textAlignment = NSTextAlignment.Center
        topView.addSubview(headLine)
        
        let subHeadLine: UILabel = UILabel()
        subHeadLine.frame = CGRectMake(0.1 * topView.frame.size.width, 0.6 * topView.frame.size.height, 0.8 * topView.frame.size.width, 0.2 * topView.frame.size.height)
        subHeadLine.font = UIFont.systemFontOfSize(12)
        subHeadLine.text = "to upload tabs and save your favorite songs"
        subHeadLine.textAlignment = NSTextAlignment.Center
        topView.addSubview(subHeadLine)
    }
    
    func setUpCreatAccountSignUpView() {
        let signUpByFBView: UIView = UIView()
        signUpByFBView.frame = CGRectMake(0, 0.225 * self.viewHeight, self.viewWidth, 0.1 * self.viewHeight)
        signUpByFBView.layer.borderWidth = 1
        self.createAccountEditView.addSubview(signUpByFBView)
        
        self.setUpFBLogin(signUpByFBView)
        
        let orLabel: UILabel = UILabel()
        orLabel.frame = CGRectMake(0, 0.325 * self.viewHeight, self.viewWidth, 0.05 * self.viewHeight)
        orLabel.text = "or"
        orLabel.textAlignment = NSTextAlignment.Center
        self.createAccountEditView.addSubview(orLabel)
        
        let signUpByTJView: UIView = UIView()
        signUpByTJView.frame = CGRectMake(0, 0.375 * self.viewHeight, self.viewWidth, 0.21 * self.viewHeight)
        signUpByTJView.layer.borderWidth = 1
        self.createAccountEditView.addSubview(signUpByTJView)
        
        let emailTitleLabel: UILabel = UILabel()
        emailTitleLabel.frame = CGRectMake(0, 0, 0.3 * self.viewWidth, 0.1 * self.viewHeight)
        emailTitleLabel.text = "e-mail:"
        emailTitleLabel.textAlignment = NSTextAlignment.Right
        signUpByTJView.addSubview(emailTitleLabel)
        
        self.createAccountEmailTextField.frame = CGRectMake(0.3 * self.viewWidth, 0, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.createAccountEmailTextField.text = "example@gmail.com"
        signUpByTJView.addSubview(self.createAccountEmailTextField)
        
        let passwordTitleLabel: UILabel = UILabel()
        passwordTitleLabel.frame = CGRectMake(0, 0.11 * self.viewHeight, 0.3 * self.viewWidth, 0.1 * self.viewHeight)
        passwordTitleLabel.text = "password:"
        passwordTitleLabel.textAlignment = NSTextAlignment.Right
        signUpByTJView.addSubview(passwordTitleLabel)
        
        self.createAccountPasswordTextField.frame = CGRectMake(0.3 * self.viewWidth, 0.11 * self.viewHeight, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.createAccountPasswordTextField.text = "********"
        signUpByTJView.addSubview(self.createAccountPasswordTextField)
        
        let createAccountButton: UIButton = UIButton()
        createAccountButton.frame = CGRectMake(0.3 * self.viewWidth, 0.6 * self.viewHeight, 0.4 * self.viewWidth, 0.05 * self.viewHeight)
        createAccountButton.setTitle("Create", forState: UIControlState.Normal)
        createAccountButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        createAccountButton.layer.borderWidth = 1
        createAccountButton.addTarget(self, action: "pressCreateAccountButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.createAccountEditView.addSubview(createAccountButton)
        
        let signInButton: UIButton = UIButton()
        signInButton.frame = CGRectMake(0.3 * self.viewWidth, 0.7 * self.viewHeight, 0.4 * self.viewWidth, 0.05 * self.viewHeight)
        signInButton.setTitle("Sign In", forState: UIControlState.Normal)
        signInButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        signInButton.layer.borderWidth = 1
        signInButton.addTarget(self, action: "pressSignInButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.createAccountEditView.addSubview(signInButton)
    }
    
    func pressCreateAccountButton(sender: UIButton) {
        let email = self.createAccountEmailTextField.text!
        let password = self.createAccountPasswordTextField.text!
        print("create account")
    }
    
    func pressSignInButton(sender: UIButton) {
        self.dismissSecondView(self.createAccountEditView)
        self.addSecondView(self.signInEditView)
        
    }

}

