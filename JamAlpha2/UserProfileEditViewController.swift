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
    
    let tableViewContent: [String] = ["Nick Name"]
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                if let url = UIImage(data: user.thumbnail!) {
                    userProfileCell.userImageView.image = url
                }
            }
            return userProfileCell
        } else {
            let contentProfileCell: MeContentProfileTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("contentProfileCell") as! MeContentProfileTableViewCell
            contentProfileCell.initialTableViewCell(self.viewWidth, height: 44)
            contentProfileCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            contentProfileCell.titleLabel.text = tableViewContent[indexPath.item]
            contentProfileCell.selectionStyle = UITableViewCellSelectionStyle.None
            if let nickName = CoreDataManager.getCurrentUser()?.nickName {
                contentProfileCell.contentLabel.text = nickName
            }
            return contentProfileCell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return tableViewContent.count
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
        
        CoreDataManager.updateUserProfileImage(self.userEmail, avatarUrl: self.originFileName, thumbnailUrl: self.croppedFileName, profileImage: self.originImageData, thumbnail: thumbnailImageData)
        
        self.tableView.reloadData()
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}


