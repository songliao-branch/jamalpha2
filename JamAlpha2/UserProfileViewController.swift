//
//  UserProfileViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/19/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import Haneke
import AWSS3
import RSKImageCropper

//var tempImage: UIImage = UIImage()

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userTable: UITableView!
    
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    
    var userEmail: String!
    
    var originFileName: String!
    var croppedFileName: String!
    var profileImage: UIImage = UIImage()
    
    var cellTitles = ["My tabs", "My lyrics", "Favorites"]
    
    // request array
    var awsS3: AWSS3Manager = AWSS3Manager()
    var imageName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        
        let error = NSErrorPointer()
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(
                (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("upload"),
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating 'upload' directory failed. Error: \(error)")
        }
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(
                (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("download"),
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating 'download' directory failed. Error: \(error)")
        }
        
//        let imageView: UIImageView = UIImageView(frame: CGRectMake(50, 50, 100, 100))
//        imageView.image = tempImage
//        self.view.addSubview(imageView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        
        showSignUpLoginScreen()
        userTable.reloadData()
    }
    
    func showSignUpLoginScreen() {
        //check if there is a user, if not show signup/login screen
        if CoreDataManager.getCurrentUser() == nil {
            let signUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("meloginVC") as! MeLoginOrSignupViewController
            
            self.navigationController?.pushViewController(signUpVC, animated: false)
        } else {
            //means we are signed in here, refresh the table
            userTable.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3//one for avatar, one for (tabs,lyris, favoriates), other one for setting
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 88
        }
        return 44
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 2 {
            return 1
        }
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("avatarcell", forIndexPath: indexPath) as! AvatarCell
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height/2
            cell.avatarImageView.layer.borderWidth = 1
            cell.avatarImageView.layer.borderColor = UIColor.backgroundGray().CGColor
            
            if let user = CoreDataManager.getCurrentUser() {
                if let name = user.username {
                    cell.titleLabel.text = name
                }
                self.userEmail = user.email
                cell.subtitleLabel.text = user.email
                if let url = UIImage(data: user.thumbnail!) {//user.avatarUrl {
                    //cell.avatarImageView.hnk_setImageFromURL(NSURL(string: url)!)
                    //self.profileImage = url
                    let imageLayer: CALayer = cell.avatarImageView.layer
                    imageLayer.cornerRadius = 0.5 * cell.avatarImageView.frame.size.width
                    imageLayer.masksToBounds = true
                    cell.avatarImageView.image = self.profileImage
                }
            }
            
            return cell
            
        } else if indexPath.section == 1 {
         let cell = tableView.dequeueReusableCellWithIdentifier("usercell", forIndexPath: indexPath)
         cell.textLabel?.text = cellTitles[indexPath.row]
         return cell
            
        } else { //section 2
            let cell = tableView.dequeueReusableCellWithIdentifier("usercell", forIndexPath: indexPath)
            cell.textLabel?.text = "Settings"
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.pressUploadImageButton()
            
        } else if indexPath.section == 1{
            // my tabs, my lyrics, favorites
            if indexPath.item == 0 {
                awsS3.addDownloadRequestToArray(self.originFileName)
                awsS3.download(awsS3.downloadRequests[0]!)
            }
            else if indexPath.item == 1{
                if let downloadFileURL = awsS3.downloadFileURLs[0] {
                    if let data = NSData(contentsOfURL: downloadFileURL) {
                        print(downloadFileURL)
                    }
                }
            }
        } else if indexPath.section == 2 { //settings section
            let settingsVC = self.storyboard?.instantiateViewControllerWithIdentifier("settingsviewcontroller") as! SettingsViewController
            self.showViewController(settingsVC, sender: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// upload user profile image
extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func pressUploadImageButton() {
        let refreshAlert = UIAlertController(title: "Add Photo", message: "Camera or Photo Library", preferredStyle: UIAlertControllerStyle.Alert)
        let photoPicker = UIImagePickerController()
        photoPicker.setEditing(true, animated: true)
        
        photoPicker.delegate = self
        photoPicker.preferredContentSize = CGSize(width: 54, height: 54)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            refreshAlert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                photoPicker.sourceType = UIImagePickerControllerSourceType.Camera
                //Create camera overlay, make it square
                photoPicker.allowsEditing = true
                photoPicker.showsCameraControls = true
                
                self.presentViewController(photoPicker, animated: true, completion: nil)
            }))
        }
        refreshAlert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(photoPicker, animated: true, completion: nil)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.dismissViewControllerAnimated(false, completion: nil)
        }))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        // add request to upload array
        self.originFileName = awsS3.addUploadRequestToArray(image, style: "origin", email: self.userEmail)
        cropImage(image)

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // download the image
    func downloadImage() {
        awsS3.addDownloadRequestToArray(self.originFileName)
        awsS3.download(awsS3.downloadRequests[0]!)
    }
    
}

// crop the user profile image
extension UserProfileViewController: RSKImageCropViewControllerDelegate {
    
    func cropImage(sender: UIImage) {
        let imageCropVC: RSKImageCropViewController = RSKImageCropViewController(image: sender, cropMode: RSKImageCropMode.Circle)
        imageCropVC.delegate = self
        self.navigationController?.pushViewController(imageCropVC, animated: true)
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
        // add request to upload array
        self.croppedFileName = awsS3.addUploadRequestToArray(croppedImage, style: "cropped", email: self.userEmail)
        
        //sending the cropped image to s3 in here
        for item in awsS3.uploadRequests {
            awsS3.upload(item!)
        }
        awsS3.uploadRequests.removeAll()
        
        self.profileImage = croppedImage
        
        self.userTable.reloadData()
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}


