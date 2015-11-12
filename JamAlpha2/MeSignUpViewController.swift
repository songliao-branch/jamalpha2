//
//  MeSignUpViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/11/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class MeSignUpViewController: UIViewController {

    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    var statusAndNavigationBarHeight: CGFloat = CGFloat()
    
    var editView: UIScrollView = UIScrollView()
    
    var profileImageView: UIImageView = UIImageView()
    
    var email: String = String()
    
    var emailTestField: UITextField = UITextField()
    var usernameTextField: UITextField = UITextField()
    var passwordTextField: UITextField = UITextField()
    
    var emailBackgroundLabel: UILabel = UILabel()
    var usernameBackgroundLabel: UILabel = UILabel()
    var passwordBackgroundLabel: UILabel = UILabel()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        self.statusAndNavigationBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height + (self.navigationController?.navigationBar.height)!
        
        setUpNavigationBar()
        setUpEditView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavigationBar(){
//        let logo = UIImageView(frame: CGRect(origin: CGPointZero, size: CGSizeMake(self.view.frame.width/2, 22)))
//        logo.image = UIImage(named: "logo_bold")
//        logo.center = CGPointMake(self.view.center.x, 25) // half of navigation height
//        logo.contentMode = UIViewContentMode.ScaleAspectFit
//        //add logo to navigation bar
//        self.navigationController!.navigationBar.addSubview(logo)
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        // hide the navigation bar
        self.navigationController?.navigationBar.hidden = false
        // change the navigationbar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        // 
        self.navigationController?.navigationBar.translucent = false
        
        self.view.backgroundColor = UIColor(red: 0.918, green: 0.918, blue: 0.918, alpha: 1)
    }
    
    func setUpEditView() {
        
        editView.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight - self.statusAndNavigationBarHeight)
        editView.contentSize = CGSizeMake(self.viewWidth, self.viewHeight - self.statusAndNavigationBarHeight + 0.1 * self.viewHeight)
        self.view.addSubview(editView)
        
        let imageWidth: CGFloat = 0.15 * self.viewHeight
        self.profileImageView.frame = CGRectMake(self.viewWidth / 2 - imageWidth / 2, 0.05 * self.viewHeight, imageWidth, imageWidth)
        self.profileImageView.layer.borderWidth = 1
        self.profileImageView.layer.cornerRadius = 0.5 * imageWidth
        self.profileImageView.image = UIImage(named: "me")
        self.profileImageView.userInteractionEnabled = true
        editView.addSubview(self.profileImageView)
        
        let addProfileImageButton: UIButton = UIButton()
        addProfileImageButton.frame = CGRectMake(0, 0, imageWidth, imageWidth)
        addProfileImageButton.layer.cornerRadius = 0.5 * imageWidth
        addProfileImageButton.setTitle("+", forState: UIControlState.Normal)
        addProfileImageButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        addProfileImageButton.addTarget(self, action: "pressAddProfileImageButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.profileImageView.addSubview(addProfileImageButton)
        
        let emailTitleImage: UIImageView = UIImageView()
        emailTitleImage.frame = CGRectMake(0.05 * self.viewWidth, 0.3 * self.viewHeight - 0.05 * self.viewWidth, 0.1 * self.viewWidth, 0.1 * self.viewWidth)
        emailTitleImage.image = UIImage(named: "email")
        editView.addSubview(emailTitleImage)
        self.emailTestField.frame = CGRectMake(0.25 * self.viewWidth, 0.25 * self.viewHeight, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.emailTestField.backgroundColor = UIColor.clearColor()
        self.emailTestField.text = self.email
        self.emailTestField.addTarget(self, action: "valueChangeOnEmailTestField:", forControlEvents: UIControlEvents.EditingChanged)
        self.emailTestField.accessibilityIdentifier = "edit"
        editView.addSubview(self.emailTestField)
        
        self.emailBackgroundLabel.frame = CGRectMake(0.25 * self.viewWidth, 0.25 * self.viewHeight, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.emailBackgroundLabel.text = "Enter your email"
        self.emailBackgroundLabel.textColor = UIColor.grayColor()
        
        let usernameTitleImage: UIImageView = UIImageView()
        usernameTitleImage.frame = CGRectMake(0.05 * self.viewWidth, 0.4 * self.viewHeight - 0.05 * self.viewWidth, 0.1 * self.viewWidth, 0.1 * self.viewWidth)
        usernameTitleImage.image = UIImage(named: "user")
        editView.addSubview(usernameTitleImage)
        self.usernameTextField.frame = CGRectMake(0.25 * self.viewWidth, 0.35 * self.viewHeight, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.usernameTextField.backgroundColor = UIColor.clearColor()
        self.usernameTextField.addTarget(self, action: "valueChangeOnUsernameTextField:", forControlEvents: UIControlEvents.EditingChanged)
        self.usernameTextField.accessibilityIdentifier = "unedit"
        editView.addSubview(self.usernameTextField)
        
        self.usernameBackgroundLabel.frame = CGRectMake(0.25 * self.viewWidth, 0.35 * self.viewHeight, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.usernameBackgroundLabel.text = "Enter your username"
        self.usernameBackgroundLabel.textColor = UIColor.grayColor()
        editView.addSubview(self.usernameBackgroundLabel)
        
        let passwordTitleImage: UIImageView = UIImageView()
        passwordTitleImage.frame = CGRectMake(0.05 * self.viewWidth, 0.5 * self.viewHeight - 0.05 * self.viewWidth, 0.1 * self.viewWidth, 0.1 * self.viewWidth)
        passwordTitleImage.image = UIImage(named: "password")
        editView.addSubview(passwordTitleImage)
        self.passwordTextField.frame = CGRectMake(0.25 * self.viewWidth, 0.45 * self.viewHeight, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.passwordTextField.backgroundColor = UIColor.clearColor()
        self.passwordTextField.addTarget(self, action: "valueChangeOnPasswordTextField:", forControlEvents: UIControlEvents.EditingChanged)
        self.passwordTextField.accessibilityIdentifier = "unedit"
        editView.addSubview(self.passwordTextField)
        
        self.passwordBackgroundLabel.frame = CGRectMake(0.25 * self.viewWidth, 0.45 * self.viewHeight, 0.7 * self.viewWidth, 0.1 * self.viewHeight)
        self.passwordBackgroundLabel.text = "Enter your password"
        self.passwordBackgroundLabel.textColor = UIColor.grayColor()
        editView.addSubview(self.passwordBackgroundLabel)
        
        let tapOnEditView: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnEditView.addTarget(self, action: "tapOnEditView:")
        editView.addGestureRecognizer(tapOnEditView)
        
    }
    
    func tapOnEditView(sender: UITapGestureRecognizer) {
        self.emailTestField.resignFirstResponder()
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    func valueChangeOnEmailTestField(sender: UITextField) {
        if sender.text == "" {
            self.editView.addSubview(self.emailBackgroundLabel)
            sender.accessibilityIdentifier = "unedit"
        } else {
            if sender.accessibilityIdentifier == "unedit" {
                self.emailBackgroundLabel.removeFromSuperview()
                sender.accessibilityIdentifier = "edit"
            }
        }
    }

    func valueChangeOnUsernameTextField(sender: UITextField) {
        if sender.text == "" {
            self.editView.addSubview(self.usernameBackgroundLabel)
            sender.accessibilityIdentifier = "unedit"
        } else {
            if sender.accessibilityIdentifier == "unedit" {
                self.usernameBackgroundLabel.removeFromSuperview()
                sender.accessibilityIdentifier = "edit"
            }
        }
    }
    
    func valueChangeOnPasswordTextField(sender: UITextField) {
        if sender.text == "" {
            self.editView.addSubview(self.passwordBackgroundLabel)
            sender.accessibilityIdentifier = "unedit"
        } else {
            if sender.accessibilityIdentifier == "unedit" {
                self.passwordBackgroundLabel.removeFromSuperview()
                sender.accessibilityIdentifier = "edit"
            }
        }
    }
}

extension MeSignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pressAddProfileImageButton(sender: UIButton) {
        let refreshAlert = UIAlertController(title: "Add Photo", message: "Camera or Photo Library", preferredStyle: UIAlertControllerStyle.Alert)
        let photoPicker = UIImagePickerController()
        photoPicker.setEditing(true, animated: true)
        
        photoPicker.delegate = self
        photoPicker.preferredContentSize = CGSize(width: 54, height: 54)
        photoPicker.navigationBar.barTintColor = UIColor.mainPinkColor()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            refreshAlert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                photoPicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(photoPicker, animated: true, completion: nil)

            }))
        }
        refreshAlert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(photoPicker, animated: true, completion: nil)
        }))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.profileImageView.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
