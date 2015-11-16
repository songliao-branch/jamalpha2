//
//  MeLoggedInViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/4/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class MeViewController: UIViewController {
    
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    
    var statusAndNavigationBarHeight: CGFloat = CGFloat()
    
    //profile view
    var profileEditView: UIView = UIView()
    var profileTableView: UITableView!
    let profileArray: [String] = ["My Tabs", "My Lyrics"]
    
    //
    var username: String = "Mike Johnson"
    var userImage: UIImage = UIImage(named: "user")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        self.statusAndNavigationBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height + (self.navigationController?.navigationBar.height)!
        
        // Do any additional setup after loading the view.
        setUpNavigationBar()
        initialProfileView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        // hide the navigation bar
        self.navigationController?.navigationBar.hidden = false
        //
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        // 
        self.navigationItem.title = "Me"
        
        
        self.view.backgroundColor = UIColor(red: 0.918, green: 0.918, blue: 0.918, alpha: 1)
    }
    
    func initialProfileView() {
        self.setUpProfileEditView()
        self.setUpProfileTableView()
    }
    
    func setUpProfileEditView() {
        self.profileEditView.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight - (self.tabBarController?.tabBar.frame.size.height)!)
        self.profileEditView.backgroundColor = UIColor(red: 0.918, green: 0.918, blue: 0.918, alpha: 1)
        self.view.addSubview(self.profileEditView)
    }
}

extension MeViewController: UITableViewDataSource, UITableViewDelegate {
    func setUpProfileTableView() {
        self.profileTableView = UITableView(frame: CGRectMake(0, 0, self.viewWidth, self.profileEditView.frame.size.height), style: UITableViewStyle.Grouped)
        self.profileTableView.delegate = self
        self.profileTableView.dataSource = self
        self.profileTableView.bounces = true
        self.profileTableView.backgroundColor = UIColor(red: 0.918, green: 0.918, blue: 0.918, alpha: 1)
        self.profileTableView.registerClass(MeContentProfileTableViewCell.self, forCellReuseIdentifier: "contentcell")
        self.profileTableView.registerClass(MeUserProfileTableViewCell.self, forCellReuseIdentifier: "usercell")
        self.profileEditView.addSubview(self.profileTableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: MeUserProfileTableViewCell = self.profileTableView.dequeueReusableCellWithIdentifier("usercell") as! MeUserProfileTableViewCell
            cell.initialTableViewCell(self.viewWidth, height: 0.1 * self.viewHeight)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.userImage.image = self.userImage
            cell.userNameLabel.text = self.username
            return cell
        } else {
            let cell: MeContentProfileTableViewCell = self.profileTableView.dequeueReusableCellWithIdentifier("contentcell") as! MeContentProfileTableViewCell
            cell.initialTableViewCell(self.viewWidth, height: 0.1 * self.viewHeight)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.separatorInset = UIEdgeInsetsZero
            cell.titleImage.image = UIImage(named: "me_music")
            if indexPath.section == 1 {
                cell.titleLabel.text = self.profileArray[indexPath.item]
            } else if indexPath.section == 2 {
                cell.titleLabel.text = "Settings"
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.profileArray.count
        } else if section == 2 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView: UIView = UIView()
        headView.frame = CGRectMake(0, 0, self.viewWidth, 0.06 * self.viewHeight)
        headView.backgroundColor = UIColor(red: 0.918, green: 0.918, blue: 0.918, alpha: 1)
        return headView
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footView: UIView = UIView()
        footView.frame = CGRectMake(0, 0, self.viewWidth, 0.01 * self.viewHeight)
        footView.backgroundColor = UIColor(red: 0.918, green: 0.918, blue: 0.918, alpha: 1)
        return footView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.04 * self.viewHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0.1 * self.viewHeight
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.02 * self.viewHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let meProfileVC: MeProfileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("meprofileVC") as! MeProfileViewController
            self.navigationController?.pushViewController(meProfileVC, animated: true)
        } else if indexPath.section == 1 {
            if indexPath.item == 0 {
                let myTabsVC: MyTabsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("mytabsVC") as! MyTabsViewController
                self.navigationController?.pushViewController(myTabsVC, animated: true)
            } else {
                let mylyricsVC: MyLyricsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("mylyricsVC") as! MyLyricsViewController
                self.navigationController?.pushViewController(mylyricsVC, animated: true)
            }
        } else if indexPath.section == 2 {
            let settingsVC: SettingsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("settingsVC") as! SettingsViewController
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
}

