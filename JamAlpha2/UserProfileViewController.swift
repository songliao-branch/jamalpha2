//
//  UserProfileViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/19/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import Haneke

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userTable: UITableView!
    
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    
    var settingsVC: SettingsViewController!
    
    var isCalledViewDidLoad:Bool = false
    
    var cellTitles = ["My chords", "My lyrics", "Favorites"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        isCalledViewDidLoad = true
        refreshUserImage()
    }

    
    //called after sign in or sign up
    func refreshUserImage() {
        guard let currentUser = CoreDataManager.getCurrentUser() else {
            self.isCalledViewDidLoad = false
            return
        }
        if currentUser.profileImage != nil {
            self.userTable.reloadData()
            self.isCalledViewDidLoad = false
            return
        }
        
        //if not facebook user, means image is stored at s3
        if let avatarUrl = currentUser.avatarUrl where currentUser.avatarUrl?.characters.count > 5 {
            if avatarUrl.containsString("facebook") { // if this is stored at facebook and not changed by user
                let profileImageData = NSData(contentsOfURL: NSURL(string: avatarUrl)!)!
                CoreDataManager.saveUserProfileImage(profileImageData: profileImageData)
                self.userTable.reloadData()
                self.isCalledViewDidLoad = false
            } else {
                print(avatarUrl)
                AWSS3Manager.downloadImage(avatarUrl, isProfileBucket: true, completion: {
                    image in
                    dispatch_async(dispatch_get_main_queue()) {
                        CoreDataManager.saveUserProfileImage(profileImageData: UIImagePNGRepresentation(image))
                        self.userTable.reloadData()
                        self.isCalledViewDidLoad = false
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
        
        self.title = "Profile"
        showSignUpLoginScreen()
        userTable.reloadData()
    }
    
    func showSignUpLoginScreen() {
        //check if there is a user, if not show signup/login screen
        if CoreDataManager.getCurrentUser() == nil {
            let signUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("meloginVC") as! MeLoginOrSignupViewController
            self.navigationController?.pushViewController(signUpVC, animated: false)
            signUpVC.userProfileViewController = self
        } else {
            //means we are signed in here, refresh the table
            if(!isCalledViewDidLoad){
                refreshUserImage()
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 35
        }
        return 20
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
                if let name = user.nickname {
                    cell.titleLabel.text = name
                }
                cell.subtitleLabel.text = user.email
                if let profileData = user.profileImage {
                    let imageLayer: CALayer = cell.avatarImageView.layer
                    imageLayer.cornerRadius = 0.5 * cell.avatarImageView.frame.size.width
                    imageLayer.masksToBounds = true
                    cell.avatarImageView.image = UIImage(data: profileData)
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
            // navigation to user profile edit vc
            let userProfileVC: UserProfileEditViewController = self.storyboard?.instantiateViewControllerWithIdentifier("userprofileeditVC") as! UserProfileEditViewController
            self.navigationController?.pushViewController(userProfileVC, animated: true)
            
        } else if indexPath.section == 1{
            // my tabs, my lyrics, favorites
            if indexPath.item == 0 {
                let myTabsVC = self.storyboard?.instantiateViewControllerWithIdentifier("mytabsandlyricsVC") as! MyTabsAndLyricsViewController
                myTabsVC.isViewingTabs = true
                self.navigationController?.pushViewController(myTabsVC, animated: true)
            } else if indexPath.item == 1{
                let myLyricsVC = self.storyboard?.instantiateViewControllerWithIdentifier("mytabsandlyricsVC") as! MyTabsAndLyricsViewController
                myLyricsVC.isViewingTabs = false
                self.navigationController?.pushViewController(myLyricsVC, animated: true)
            } else if indexPath.item == 2 {
                let favoritesVC = self.storyboard?.instantiateViewControllerWithIdentifier("MyFavoritesViewController") as! MyFavoritesViewController
                
                self.navigationController?.pushViewController(favoritesVC, animated: true)
            }
        } else if indexPath.section == 2 { //settings section
            self.settingsVC = self.storyboard?.instantiateViewControllerWithIdentifier("settingsviewcontroller") as! SettingsViewController
            self.showViewController(settingsVC, sender: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}


