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

class MeLoginOrSignupViewController: UIViewController {

    
    var email: String = String()
    var fullName: String!
    var userId: String!
    var profileImageData: NSData!
    var thumbnailData: NSData!
    
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
    
    var scrollView: UIScrollView!
    //sign up screen
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
    var userEmail: String!
    var originFileName: String = String()
    var croppedFileName: String = String()
    
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
    }
    
    func setUpViews() {
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: CGRectGetMaxY(topView.frame), width: viewWidth, height: viewHeight))
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize.height = self.scrollView.frame.size.height + 15
        let scrollViewTapGesture = UITapGestureRecognizer(target: self, action: "scrollViewTapGesture:")
        scrollView.addGestureRecognizer(scrollViewTapGesture)
        self.view.addSubview(self.scrollView)
        
        //sign in screen
        let verticalMargin: CGFloat = 10
        emailTextField = UITextField(frame: CGRect(x: 0, y: verticalMargin, width: viewWidth-20, height: 44))
        emailTextField.placeholder = "Email"
        emailTextField.textAlignment = .Center
        emailTextField.center.x = self.view.center.x
        emailTextField.tintColor = UIColor.mainPinkColor()
        emailTextField.clearButtonMode = .WhileEditing
        emailTextField.autocapitalizationType = .None
        emailTextField.autocorrectionType = .No
        scrollView.addSubview(emailTextField)
        
        let credentialTextFieldUnderline = UIView(frame: CGRect(x: emailTextField.frame.origin.x, y: CGRectGetMaxY(emailTextField.frame), width: emailTextField.frame.width, height: 1))
        credentialTextFieldUnderline.backgroundColor = UIColor.lightGrayColor()
        scrollView.addSubview(credentialTextFieldUnderline)
        
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
        
        //log in screen
        passwordTextField = UITextField(frame: CGRect(x: 0, y: CGRectGetMaxY(credentialTextFieldUnderline.frame)+verticalMargin, width: emailTextField.frame.width, height: emailTextField.frame.height))
        passwordTextField.secureTextEntry = true
        passwordTextField.placeholder = "Password (Mininum 6 characters)"
        passwordTextField.textAlignment = .Center
        passwordTextField.clearButtonMode = .WhileEditing
        passwordTextField.tintColor = UIColor.mainPinkColor()
        scrollView.addSubview(passwordTextField)
        
        let passwordTextFieldUnderline = UITextField(frame: CGRect(x: credentialTextFieldUnderline.frame.origin.x, y: CGRectGetMaxY(passwordTextField.frame), width: credentialTextFieldUnderline.frame.width, height: 1))
        passwordTextFieldUnderline.backgroundColor = UIColor.lightGrayColor()
        scrollView.addSubview(passwordTextFieldUnderline)
        
        submitButton = UIButton(frame: CGRect(x: 0, y: CGRectGetMaxY(passwordTextField.frame)+verticalMargin, width: viewWidth, height: 44))
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
        isSignUpSelected = true
        
        self.passwordTextField.placeholder = "Password (Mininum 6 characters)"
        self.submitButton.setTitle("Sign up", forState: .Normal)
    }
    
    func loginTabPressed() {
        self.indicatorTriangleView.center.x = self.loginTabButton.center.x
        self.subtitleLabel.text = "Log in to upload tabs and save your favorite songs"
        isSignUpSelected = false
        
        self.submitButton.setTitle("Log in", forState: .Normal)
        self.passwordTextField.placeholder = "Password"
    }
    
    func topViewTapGesture(sender: UITapGestureRecognizer) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    func scrollViewTapGesture(sender: UITapGestureRecognizer) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }

    
    func submitPressed() {

        //validate email is not empty
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
 
        let thumbnailImageData: NSData = UIImagePNGRepresentation(UIImage(named: "kitten_profile")!)!
        let profileImageData: NSData = UIImagePNGRepresentation(UIImage(named: "kitten_origin")!)!
        
        
        
        self.originFileName = awsS3.addUploadRequestToArray(UIImage(named: "kitten_origin")!, style: "origin", email: email)
        self.croppedFileName = awsS3.addUploadRequestToArray(UIImage(named: "kitten_profile")!, style: "thumbnail", email: email)
        
        for item in awsS3.uploadRequests {
            awsS3.upload(item!)
        }
        
        
        signUpLoginRequest(parameters, afterRetrievingUser: {
            id, email, authToken in
            
            CoreDataManager.initializeUser(id, email: email, authToken: authToken, username: self.fullName, avatarUrl: self.originFileName, thumbnailUrl: self.croppedFileName, profileImage: profileImageData, thumbnail: thumbnailImageData)
            
        })
    }
    //used for facebook button too
    private func signUpLoginRequest(parameters: [String: String],  afterRetrievingUser: (( id: Int, email: String, authToken: String) -> Void)) {

        Alamofire.request(.POST, jamBaseURL + "/users", parameters: parameters, encoding: .JSON).responseJSON
            {
                response in
                self.submitButton.enabled = true
                switch response.result {
                case .Success:
                    print(response)
                    
                    if let data = response.result.value {
                        let json = JSON(data)
                        
                        let userInitialization = json["user_initialization"]
                        
                        if userInitialization != nil {
                            
                            afterRetrievingUser(id: userInitialization["id"].int!, email: userInitialization["email"].string!, authToken: userInitialization["auth_token"].string!)
                            //go back to user profile view
                            self.navigationController?.popViewControllerAnimated(false)
                            
                            print("from core data we have \(CoreDataManager.getCurrentUser()?.email)")
                            
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
        
        fbLoginManager.logInWithReadPermissions(permissons, fromViewController: self, handler: {
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
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({
                (connection, result, error) -> Void in
                if error == nil {
                
                    print(result)
                    
                    self.email = result.valueForKey("email") as! String
                    self.fullName  = result.valueForKey("name") as! String
                    self.userId = result.valueForKey("id") as! String
                    let avatarUrl = "https://graph.facebook.com/\(self.userId)/picture?height=320&width=320"
                    self.profileImageData = NSData(contentsOfURL: NSURL(string: avatarUrl)!)!
                    
                    let originImage = UIImage(data: NSData(contentsOfURL: NSURL(string: avatarUrl)!)!)!
                    
                    // add upload request
                    self.originFileName = self.awsS3.addUploadRequestToArray(originImage, style: "origin", email: self.email)
                    
                    // crop image to circle
                    self.cropImage(originImage)
                }
            })
        }
    }
    

    
    
}

// crop the user profile image
extension MeLoginOrSignupViewController: RSKImageCropViewControllerDelegate {
  
    func cropImage(sender: UIImage) {
        let imageCropVC: RSKImageCropViewController = RSKImageCropViewController(image: sender, cropMode: RSKImageCropMode.Circle)
        imageCropVC.delegate = self
        self.navigationController?.pushViewController(imageCropVC, animated: true)
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
        
        //tempImage = downSizeCroppedImage
        
        self.thumbnailData = UIImagePNGRepresentation(croppedImage)
        
        // add request to upload array
        self.croppedFileName = awsS3.addUploadRequestToArray(croppedImage, style: "thumbnail", email: self.email)
        
        //sending the cropped image to s3 in here
        for item in awsS3.uploadRequests {
            awsS3.upload(item!)
        }
        awsS3.uploadRequests.removeAll()
        
        let parameters = [
            "attempt_login":"facebook",
            "email": self.email,
            "thumbnail": self.croppedFileName,
            "profileImage": self.originFileName,
            "password": (self.email + facebookLoginSalt).md5()//IMPORTANT: DO NOT MODIFY THIS SALT
        ]
        
        self.signUpLoginRequest(parameters, afterRetrievingUser: {
            id, email, authToken in
            
            CoreDataManager.initializeUser(id, email: email, authToken: authToken, username: self.fullName, avatarUrl: self.originFileName, thumbnailUrl: self.croppedFileName, profileImage: self.profileImageData, thumbnail: self.thumbnailData)
        })
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}



