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
    
    var fbLoginManager: FBSDKLoginManager!
    
    //profile view
    var profileEditView: UIView = UIView()
    var profileTableView: UITableView = UITableView()
    let profileArray: [String] = ["My Tabs", "My Lyrics", "My Followers", "Following"]
    
    //create account view
    var createAccountEditView: UIView = UIView()
    var createAccountEmailTextField: UITextField = UITextField()
    var createAccountPasswordTextField: UITextField = UITextField()
    var createAccountTopViewImage: UIImage = UIImage(named: "meVCTopBackground")!
    var userName: String!
    var userId: String!
    var userURL: String!
    
    //sign in view
    var signInEmailTextField: UITextField = UITextField()
    var signInPasswordTextField: UITextField = UITextField()
    var signInTopViewImage: UIImage = UIImage(named: "meVCTopBackground")!
    var signInEditView: UIView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        
        // Do any additional setup after loading the view.
        self.initialCreateAccountView()
        self.initialSignInView()
        self.initialProfileView()
        self.view.addSubview(self.createAccountEditView)
        self.view.addSubview(self.signInEditView)
        self.signInEditView.frame = CGRectMake(0, self.viewHeight, self.viewWidth, self.viewHeight - (self.tabBarController?.tabBar.frame.size.height)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addSecondView(sender: UIView) {
        sender.frame = CGRectMake(0, self.viewHeight, self.viewWidth, self.viewHeight - (self.tabBarController?.tabBar.frame.size.height)!)
        UIView.animateWithDuration(0.5, animations: {
            sender.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight - (self.tabBarController?.tabBar.frame.size.height)!)
        })
    }
    
    func dismissSecondView(sender: UIView) {
        sender.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight - (self.tabBarController?.tabBar.frame.size.height)!)
        UIView.animateWithDuration(0.5, animations: {
            sender.frame = CGRectMake(0, self.viewHeight, self.viewWidth, self.viewHeight - (self.tabBarController?.tabBar.frame.size.height)!)
        })
    }
}

extension MeViewController: UITableViewDataSource, UITableViewDelegate {
    func initialProfileView() {
        self.setUpProfileEditView()
        self.setUpProfileTopView()
        self.setUpProfileTableView()
    }
    
    func setUpProfileEditView() {
        self.profileEditView.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight - (self.tabBarController?.tabBar.frame.size.height)!)
        self.createAccountEditView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(self.profileEditView)
    }
    
    func setUpProfileTopView() {
        let topView: UIView = UIView()
        topView.frame = CGRectMake(0, 0, self.viewWidth, 0.1 * self.viewHeight)
        topView.backgroundColor = UIColor.mainPinkColor()
        self.profileEditView.addSubview(topView)
        
        let profileTitleLabel: UILabel = UILabel()
        profileTitleLabel.frame = CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height)
        profileTitleLabel.text = "Profile"
        profileTitleLabel.textAlignment = NSTextAlignment.Center
        topView.addSubview(profileTitleLabel)
        
        let backButton: UIButton = UIButton()
        backButton.frame = CGRectMake(0, 0, 0.1 * self.viewHeight, 0.1 * self.viewHeight)
        backButton.setTitle("B", forState: UIControlState.Normal)
        backButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "pressProfileBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        topView.addSubview(backButton)
    }
    
    func pressProfileBackButton(sender: UIButton) {
        self.addSecondView(self.createAccountEditView)
    }
    
    func setUpProfileTableView() {
        self.profileTableView.delegate = self
        self.profileTableView.dataSource = self
        self.profileTableView.bounces = false
        self.profileTableView.frame = CGRectMake(0, 0.1 * self.viewHeight, self.viewWidth, self.profileEditView.frame.size.height - 0.1 * self.viewHeight)
        self.profileTableView.registerClass(ProfileTableViewCell.self, forCellReuseIdentifier: "cell")
        self.profileEditView.addSubview(self.profileTableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ProfileTableViewCell = self.profileTableView.dequeueReusableCellWithIdentifier("cell") as! ProfileTableViewCell
        cell.initialTableViewCell(self.viewWidth, height: 0.1 * self.viewHeight)
        cell.arrowButton.addTarget(self, action: "pressArrowButton:", forControlEvents: UIControlEvents.TouchUpInside)
        if indexPath.section == 0 {
            cell.titleLabel.text = self.profileArray[indexPath.item]
        } else if indexPath.section == 1 {
            cell.titleLabel.text = "Settings"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.profileArray.count
        } else if section == 1{
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
        headView.backgroundColor = UIColor.grayColor()
        return headView
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footView: UIView = UIView()
        footView.frame = CGRectMake(0, 0, self.viewWidth, 0.02 * self.viewHeight)
        return footView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.06 * self.viewHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0.12 * self.viewHeight
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.02 * self.viewHeight
    }
}

