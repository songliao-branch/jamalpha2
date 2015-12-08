//
//  UserProfileEditViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/3/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import AWSS3
import RSKImageCropper

class UserProfileEditViewController: UIViewController {
    
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()


    var tableView: UITableView!
    
    var awsS3: AWSS3Manager = AWSS3Manager()
    
    var userEmail: String!
    
    var originFileName: String!
    var croppedFileName: String!
    var originImageData: NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        
        setUpNavigationBar()
        setUpTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.title = "Profile"
    }
    
    func tapOnUserImageView(sender: UITapGestureRecognizer) {
        //TODO: see the image fullscreen
          print("tap on image")
        if let originImageData: NSData = CoreDataManager.getCurrentUser()?.profileImage {
            let originImage: UIImage = UIImage(data: originImageData)!
            
        }
      
    }

}

// table view
extension UserProfileEditViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTableView() {
        self.tableView = UITableView(frame: CGRectMake(0, 0, self.viewWidth, self.viewHeight), style: UITableViewStyle.Grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(MeUserProfileTableViewCell.self, forCellReuseIdentifier: "userProfileCell")
        self.tableView.registerClass(MeContentProfileTableViewCell.self, forCellReuseIdentifier: "contentProfileCell")
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.view.addSubview(self.tableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let userProfileCell: MeUserProfileTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("userProfileCell") as! MeUserProfileTableViewCell
            userProfileCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            userProfileCell.selectionStyle = UITableViewCellSelectionStyle.None
            userProfileCell.initialTableViewCell(self.viewWidth, height: 88)
            userProfileCell.titleLabel.text = "Profile Image"
            if let user = CoreDataManager.getCurrentUser() {
                self.userEmail = user.email
                if let profileData = user.profileImage {
                    userProfileCell.userImageView.image = UIImage(data: profileData)
                    userProfileCell.userImageView.userInteractionEnabled = true
                    let tapOnUserImageView: UITapGestureRecognizer = UITapGestureRecognizer()
                    tapOnUserImageView.addTarget(self, action: "tapOnUserImageView:")
                    userProfileCell.userImageView.addGestureRecognizer(tapOnUserImageView)
                }
            }
            return userProfileCell
        } else {
            let contentProfileCell: MeContentProfileTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("contentProfileCell") as! MeContentProfileTableViewCell
            contentProfileCell.initialTableViewCell(self.viewWidth, height: 44)
            contentProfileCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            contentProfileCell.titleLabel.text = "Display name"
            contentProfileCell.selectionStyle = UITableViewCellSelectionStyle.None
            if let name = CoreDataManager.getCurrentUser()?.nickname {
                contentProfileCell.contentLabel.text = name
            }
            return contentProfileCell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40
        }
        return 22
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 88
        }
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.pressUploadImageButton()
        } else {
            if indexPath.item == 0 {
                let updateNickNameVC: UpdateNickNameViewController = self.storyboard?.instantiateViewControllerWithIdentifier("updatenicknameVC") as! UpdateNickNameViewController
                self.navigationController?.pushViewController(updateNickNameVC, animated: true)
            }
        }
    }
}

// upload user profile image
extension UserProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pressUploadImageButton() {
        let refreshAlert = UIAlertController(title: "Add Photo", message: "Camera or Photo Library", preferredStyle: UIAlertControllerStyle.Alert)
        let photoPicker = UIImagePickerController()
        photoPicker.setEditing(true, animated: true)
        
        photoPicker.delegate = self
        photoPicker.preferredContentSize = CGSize(width: 54, height: 54)
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
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.dismissViewControllerAnimated(false, completion: nil)
        }))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        cropImage(image)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

// crop the user profile image
extension UserProfileEditViewController: RSKImageCropViewControllerDelegate {
    
    func cropImage(sender: UIImage) {
        let imageCropVC: RSKImageCropViewController = RSKImageCropViewController(image: sender, cropMode: RSKImageCropMode.Circle)
        imageCropVC.delegate = self
        self.navigationController?.pushViewController(imageCropVC, animated: true)
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        // resize image, add request to upload array
        let originImage: UIImage = croppedImage.resize(250)
        self.originFileName = awsS3.addUploadRequestToArray(originImage, style: "origin", email: self.userEmail)
        self.originImageData = UIImagePNGRepresentation(originImage)
        
        // resize image
        let thumbnailImage: UIImage = croppedImage.resize(80)
        let thumbnailImageData: NSData = UIImagePNGRepresentation(thumbnailImage)!
        
        // add request to upload array
        self.croppedFileName = awsS3.addUploadRequestToArray(thumbnailImage, style: "thumbnail", email: self.userEmail)
        
        //sending the cropped image to s3 in here
        for item in awsS3.uploadRequests {
            awsS3.upload(item!)
        }
        awsS3.uploadRequests.removeAll()
        
        
        APIManager.updateUserAvatar(self.originFileName, avatarUrlThumbnail: self.croppedFileName, completion: {
            completed in
            if completed {
                print("uploaded newest avatar")
            }
        })
        
        CoreDataManager.saveUserProfileImage(self.originFileName, thumbnailUrl: self.croppedFileName, profileImageData: self.originImageData, thumbnailData: thumbnailImageData)
        
        self.tableView.reloadData()
        
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}


