//
//  MeViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/8/15.
//  Copyright © 2015 Song Liao. All rights reserved.


import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import SwiftyJSON
import CryptoSwift
import RSKImageCropper
import AWSS3
import AWSCore

class MeLoginOrSignupViewController: UIViewController{
    
    var userProfileViewController: UserProfileViewController?
    var songViewController:SongViewController?
    var isGoToTabEditor:Bool = false
    var isGoToLyricEditor:Bool = false
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    var statusAndNavigationBarHeight: CGFloat = CGFloat()
    
    var topView: UIView!
    var hideKeyboardGesture: UITapGestureRecognizer!
    var subtitleLabel: UILabel!
    var signUpTabButton: UIButton!
    var loginTabButton: UIButton!
    var indicatorTriangleView: UIImageView! //indicate whether it's sign up or log in
    var isSignUpSelected = true
    var settingsButton: UIButton!
    
    var suspended:Bool = false
    
    var showCloseButton = false
    var closeButton: UIButton! //only visible when this is presented modally
    
    var scrollView: UIScrollView!
    //sign up screen
    var welcomeLabel: UILabel! // welcome label to replace the nick name at sign in screen
    var nickNameTextField: UITextField! // nick name in sign up screen
    var emailTextField: UITextField! //email in signup screen AND email/user in log in screen
    var orLabel: UILabel! // a label inside the separator from email textfield and facebook button
    var facebookButton: UIButton!
    
    //log in screen
    var passwordTextField: UITextField!
    var submitButton: UIButton!
    
    var fbLoginButton: FBSDKLoginButton = FBSDKLoginButton()
    var nextButton: UIButton = UIButton()
    
    // AWS S3
    var awsS3: AWSS3Manager = AWSS3Manager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        //TODO: check if user is signed in already.
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        setUpTopView()
        setUpViews()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    func setUpTopView() {
        topView = UIView()
        topView.frame = CGRectMake(0, 0, self.viewWidth, 200)
        topView.backgroundColor = UIColor(patternImage: UIImage(named: "meVCTopBackground")!)
        let topViewTapGesture = UITapGestureRecognizer(target: self, action: "topViewTapGesture:")
        topView.addGestureRecognizer(topViewTapGesture)
        self.view.addSubview(topView)
        
        let logo = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        logo.image = UIImage(named: "logo_bold")
        logo.center = CGPoint(x: topView.center.x, y: topView.center.y - 20)
        logo.contentMode = .ScaleAspectFill
        logo.sizeToFit()
        topView.addSubview(logo)
        
        subtitleLabel = UILabel()
        subtitleLabel.frame = CGRectMake(0, CGRectGetMaxY(logo.frame), topView.frame.size.width-50, 50)
        subtitleLabel.text = "Sign up to upload tabs and save your favorite songs"
        subtitleLabel.textColor = UIColor.whiteColor()
        subtitleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
        subtitleLabel.textAlignment = .Center
        subtitleLabel.numberOfLines = 2
        subtitleLabel.lineBreakMode = .ByWordWrapping
        subtitleLabel.center.x = topView.center.x
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
        
        closeButton = UIButton(frame: CGRect(x: 25, y: 25, width: 35, height: 35))
        closeButton.setImage(UIImage(named: "closebutton"), forState: .Normal)
        closeButton.addTarget(self, action: "closeButtonPressed", forControlEvents: .TouchUpInside)
        topView.addSubview(closeButton)
        
        settingsButton = UIButton(frame: CGRect(x: self.view.frame.width-25-25, y: 25, width: 25, height: 25))
        settingsButton.setImage(UIImage(named: "settings_icon"), forState: .Normal)
        settingsButton.addTarget(self, action: "settingsButtonPressed", forControlEvents: .TouchUpInside)
        topView.addSubview(settingsButton)
        
        if !showCloseButton {
            closeButton.hidden = true
        }
        
        if showCloseButton {
            settingsButton.hidden = true
        }
    }
    
    func closeButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil )
    }
    
    func settingsButtonPressed() {
        let settingsVC = self.storyboard?.instantiateViewControllerWithIdentifier("settingsviewcontroller") as! SettingsViewController
        self.showViewController(settingsVC, sender: nil)
    }
    
    func setUpViews() {
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: CGRectGetMaxY(topView.frame), width: viewWidth, height: viewHeight))
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize.height = self.scrollView.frame.size.height + 15
        scrollView.delegate = self
        let scrollViewTapGesture = UITapGestureRecognizer(target: self, action: "scrollViewTapGesture:")
        scrollView.addGestureRecognizer(scrollViewTapGesture)
        self.view.addSubview(self.scrollView)
        
        //sign in screen
        let verticalMargin: CGFloat = 10
        welcomeLabel = UILabel(frame: CGRect(x: 0, y: verticalMargin, width: viewWidth - 20, height: 44))
        welcomeLabel.text = "Welcome Back"
        welcomeLabel.textAlignment = NSTextAlignment.Center
        welcomeLabel.textColor = UIColor.mainPinkColor()
        
        nickNameTextField = UITextField(frame: CGRect(x: 0, y: verticalMargin, width: viewWidth - 20, height: 44))
        nickNameTextField.placeholder = "Display Name"
        nickNameTextField.textAlignment = .Center
        nickNameTextField.center.x = self.view.center.x
        nickNameTextField.tintColor = UIColor.mainPinkColor()
        nickNameTextField.clearButtonMode = .WhileEditing
        nickNameTextField.autocapitalizationType = .None
        nickNameTextField.autocorrectionType = .No
        nickNameTextField.delegate = self
        nickNameTextField.tag = 0
        scrollView.addSubview(nickNameTextField)
        
        let credentialTextFieldUnderline1 = UIView(frame: CGRect(x: nickNameTextField.frame.origin.x, y: CGRectGetMaxY(nickNameTextField.frame), width: nickNameTextField.frame.width, height: 1))
        credentialTextFieldUnderline1.backgroundColor = UIColor.lightGrayColor()
        scrollView.addSubview(credentialTextFieldUnderline1)
        
        emailTextField = UITextField(frame: CGRect(x: 0, y: CGRectGetMaxY(credentialTextFieldUnderline1.frame)+verticalMargin, width: viewWidth - 20, height: 44))
        emailTextField.placeholder = "Email"
        emailTextField.textAlignment = .Center
        emailTextField.center.x = self.view.center.x
        emailTextField.tintColor = UIColor.mainPinkColor()
        emailTextField.clearButtonMode = .WhileEditing
        emailTextField.autocapitalizationType = .None
        emailTextField.autocorrectionType = .No
        emailTextField.delegate = self
        emailTextField.tag = 1
        scrollView.addSubview(emailTextField)
        

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
        facebookButton.addTarget(self, action: "pressFacebookButton:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(facebookButton)
        
        //TODO: hide facebook in beta mode
//        facebookButton.hidden = true
//        orLabel.hidden = true
        
        //log in screen
        let credentialTextFieldUnderline2 = UIView(frame: CGRect(x: emailTextField.frame.origin.x, y: CGRectGetMaxY(emailTextField.frame), width: emailTextField.frame.width, height: 1))
        credentialTextFieldUnderline2.backgroundColor = UIColor.lightGrayColor()
        scrollView.addSubview(credentialTextFieldUnderline2)
        
        passwordTextField = UITextField(frame: CGRect(x: 0, y: CGRectGetMaxY(credentialTextFieldUnderline2.frame)+verticalMargin, width: emailTextField.frame.width, height: emailTextField.frame.height))
        passwordTextField.secureTextEntry = true
        passwordTextField.placeholder = "Password (Mininum 6 characters)"
        passwordTextField.textAlignment = .Center
        passwordTextField.clearButtonMode = .WhileEditing
        passwordTextField.tintColor = UIColor.mainPinkColor()
        passwordTextField.delegate = self
        passwordTextField.tag = 2
        scrollView.addSubview(passwordTextField)
        
        let passwordTextFieldUnderline = UITextField(frame: CGRect(x: credentialTextFieldUnderline2.frame.origin.x, y: CGRectGetMaxY(passwordTextField.frame), width: credentialTextFieldUnderline2.frame.width, height: 1))
        passwordTextFieldUnderline.backgroundColor = UIColor.lightGrayColor()
        scrollView.addSubview(passwordTextFieldUnderline)
        
        submitButton = UIButton(frame: CGRect(x: viewWidth/2-60, y: CGRectGetMaxY(passwordTextField.frame)+verticalMargin, width: 120, height: 44))
        submitButton.setTitle("Sign Up", forState: .Normal)
        submitButton.addTarget(self, action: "submitPressed", forControlEvents: .TouchUpInside)
        submitButton.titleLabel?.textAlignment = .Center
        submitButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        submitButton.setTitleColor(UIColor.grayColor(), forState: .Disabled)
        scrollView.addSubview(submitButton)
    }
    
    func signUpTabPressed() {
        self.indicatorTriangleView.center.x = self.signUpTabButton.center.x
        self.subtitleLabel.text = "Sign up to upload tabs and save your favorite songs"
        if isSignUpSelected == false {
            self.scrollView.addSubview(self.nickNameTextField)
            self.welcomeLabel.removeFromSuperview()
        }
        isSignUpSelected = true
        
        
        self.passwordTextField.placeholder = "Password (Mininum 6 characters)"
        self.submitButton.setTitle("Sign up", forState: .Normal)
        
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            }, completion: nil)
    }
    
    func loginTabPressed() {
        self.indicatorTriangleView.center.x = self.loginTabButton.center.x
        self.subtitleLabel.text = "Log in to upload tabs and save your favorite songs"
        if isSignUpSelected == true {
            self.nickNameTextField.removeFromSuperview()
            self.scrollView.addSubview(self.welcomeLabel)
        }
        isSignUpSelected = false
        
        
        self.submitButton.setTitle("Log in", forState: .Normal)
        self.passwordTextField.placeholder = "Password"
        
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            }, completion: nil)
    }
    
    func topViewTapGesture(sender: UITapGestureRecognizer) {
        self.nickNameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            }, completion: nil)
    }
    
    func scrollViewTapGesture(sender: UITapGestureRecognizer) {
        self.nickNameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            }, completion: nil)
    }

    
    func submitPressed() {
        
        if isSignUpSelected && nickNameTextField.text == nil {
            self.showMessage("Nick Name field is empty", message: "", actionTitle: "OK", completion: nil)
            return
        }
        
        guard let email = emailTextField.text where emailTextField.text?.characters.count > 0 else {
            self.showMessage("Email field is empty", message: "", actionTitle: "OK", completion: nil)
            return
        }
        
        guard let password = passwordTextField.text where passwordTextField.text?.characters.count > 0 else {
            self.showMessage("Password is empty", message: "", actionTitle: "OK", completion: nil)
            return
        }
        
        //validate email is in email format
        if !email.isValidEmail() {
            self.showMessage("Email is not valid", message: "", actionTitle: "OK", completion: nil)
            return
        }
        
        if password.characters.count < 6 {
            self.showMessage("Password should have at least 6 characters.", message: "", actionTitle: "OK", completion: nil)
            return
        }
        
        submitButton.enabled = false
        
        var parameters = [String: String]()
        
        if isSignUpSelected { //sigup up api
            parameters = [
                "nickname": nickNameTextField.text!,
                "email": email,
                "password": password
            ]
        } else { //login api
            parameters = [
                "attempt_login":"1",
                "email": email,
                "password": password
            ]
        }
        
        signUpLoginRequest(parameters, afterRetrievingUser: {
            id, email, authToken, nickname, avatarUrlMedium, avatarUrlThumbnail in
            
            CoreDataManager.initializeUser(id, email: email, authToken: authToken, nickname: nickname, avatarUrl: avatarUrlMedium, thumbnailUrl: avatarUrlThumbnail)            
        })
    }
    //used for facebook button too
    private func signUpLoginRequest(parameters: [String: String],  afterRetrievingUser: (( id: Int, email: String, authToken: String, nickname: String, avatarUrlMedium: String, avatarUrlThumbnail: String) -> Void)) {
        
        Alamofire.request(.POST, jamBaseURL + "/users", parameters: parameters, encoding: .JSON).responseJSON
            {
                response in
                self.submitButton.enabled = true
                switch response.result {
                case .Success:
                    print(response)
                    
                    if let data = response.result.value {
                        let json = JSON(data)
                        
                        let user = json["user_initialization"]
                        
                        if user != nil {

                            afterRetrievingUser(id: user["id"].int!, email: user["email"].string!, authToken: user["auth_token"].string!, nickname: user["nickname"].string!, avatarUrlMedium: user["avatar_url_medium"].string!, avatarUrlThumbnail: user["avatar_url_thumbnail"].string!)
                            
                            //go back to user profile view
                            if self.showCloseButton {
                                self.dismissViewControllerAnimated(false, completion: {
                                    completed in
                                    if(self.songViewController != nil){
                                        if(self.isGoToTabEditor){
                                            if CoreDataManager.getCurrentUser() != nil {
                                                self.songViewController!.showTabsEditor()
                                                self.songViewController!.speed = 1
                                                self.songViewController!.speedLabel.text = "Speed: 1.0x"
                                                self.songViewController!.speedStepper.value = 1.0
                                            }
                                        }else if(self.isGoToLyricEditor){
                                            if CoreDataManager.getCurrentUser() != nil {
                                                self.songViewController!.showLyricsEditor()
                                                self.songViewController!.speed = 1
                                                self.songViewController!.speedLabel.text = "Speed: 1.0x"
                                                self.songViewController!.speedStepper.value = 1.0
                                            }
                                        }
                                    }
                                })
                            } else {
                              self.navigationController?.popViewControllerAnimated(false)
                            }
                            
                            if let userProfileVC = self.userProfileViewController {
                                userProfileVC.refreshUserImage()
                            }

                            print("from core data we have \(CoreDataManager.getCurrentUser()?.email)")
                            CoreDataManager.downloadUsersAllTabsLyricsSetToCoreData((CoreDataManager.getCurrentUser()?.id)!)
                            
                        } else { //we have an error
                            var errorMessage = ""
                            
                            if let erroMessages = json["error"].array {//it might be an array
                                for msg in erroMessages {
                                    
                                    errorMessage += msg.string!
                                }
                                self.showMessage(errorMessage, message: "", actionTitle: "OK", completion: nil)
                            } else { //or just a single value
                                self.showMessage(json["error"].string!, message: "", actionTitle: "OK", completion: nil)
                            }
                        }
                    }
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    //facebook button
    func pressFacebookButton(sender: UIButton) {
        let permissons: [AnyObject] = ["public_profile", "email", "user_friends"] as [AnyObject]
        
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.Web
        fbLoginManager.defaultAudience = FBSDKDefaultAudience.Friends
        
        fbLoginManager.logInWithReadPermissions(permissons, handler: {
            (result, error) -> Void in
            if error != nil {
                print("Error connecting with facebook: \(error)")
            } else if result.isCancelled {
                print("Facebook login request is cancelled")
            } else {
                self.getFBUserData()
                
            }
        })
    }
    
    func getFBUserData(){
        if let fbToken = FBSDKAccessToken.currentAccessToken().tokenString
        {
            self.suspended = KGLOBAL_init_queue.suspended
            KGLOBAL_queue.suspended = true
            KGLOBAL_init_queue.suspended = true
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({
                (connection, result, error) -> Void in
                if error == nil {
                
                    print(result)
                    let facebookEmail = result.valueForKey("email") as! String
                    let facebookName  = result.valueForKey("name") as! String
                    
                    let userId = result.valueForKey("id") as! String
                    let facebookAvatarUrl = "https://graph.facebook.com/\(userId)/picture?height=320&width=320"
                    
                    
                    let originImage = UIImage(data: NSData(contentsOfURL: NSURL(string: facebookAvatarUrl)!)!)!
                    let thumbnailImage = originImage.resize(35)
                    // add request to upload array
                    let thumbnailUrl = self.awsS3.addUploadRequestToArray(thumbnailImage, style: "thumbnail", email: facebookEmail)
                    
                    //sending the cropped image to s3 in here
                    for item in self.awsS3.uploadRequests {
                        self.awsS3.upload(item!)
                    }
                    self.awsS3.uploadRequests.removeAll()
                    

                    let parameters = [
                        "attempt_login":"facebook",
                        "email": facebookEmail,
                        "avatar_url_thumbnail": thumbnailUrl,
                        "avatar_url_medium": facebookAvatarUrl,
                        "password": (facebookEmail + facebookLoginSalt).md5() //IMPORTANT: DO NOT MODIFY THIS SALT
                    ]
                    
                    self.signUpLoginRequest(parameters, afterRetrievingUser: {
                         id, email, authToken, nickname, avatarUrlMedium, avatarUrlThumbnail in
                        
                        CoreDataManager.initializeUser(id, email: email, authToken: authToken, nickname: (nickname.isEmpty ? facebookName : nickname), avatarUrl: (avatarUrlMedium.isEmpty ? facebookAvatarUrl : avatarUrlMedium), thumbnailUrl: (thumbnailUrl.isEmpty ? thumbnailUrl : avatarUrlThumbnail), fbToken: fbToken)
                        
                        
                        KGLOBAL_queue.suspended = false
                        KGLOBAL_init_queue.suspended = self.suspended
                    })
                }
            })
        }
    }
}


extension MeLoginOrSignupViewController: UIScrollViewDelegate,UITextFieldDelegate{
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.nickNameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            }, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField.tag == 0){
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                }, completion: nil)
        }else if (textField.tag == 1){
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.scrollView.contentOffset = CGPoint(x: 0, y: 42)
                }, completion: nil)
        }else if (textField.tag == 2){
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.scrollView.contentOffset = CGPoint(x: 0, y: 94)
                }, completion: nil)
        }
    }
    
    // MARK: Fix to portrait orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
}
