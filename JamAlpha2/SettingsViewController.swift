//
//  SettingsViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/19/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import MessageUI


class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let firstSectionContent = ["About", "Like us on Facebook", "Rate Twistjam","Contact Us", "Demo", "Tutorial"]
    
    let contentsNotLoggedIn = ["About", "Like us on Facebook", "Rate Twistjam", "Demo Mode", "Tutorial"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
    }
    
    func setUpNavigationBar() {
        self.navigationItem.title = "Setting"
        tableView.registerClass(SettingFBCell.self, forCellReuseIdentifier: "fbcell")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if CoreDataManager.getCurrentUser() == nil {
            return 1
        }
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if CoreDataManager.getCurrentUser() == nil {
            return contentsNotLoggedIn.count
        }
        if section == 0 {
            return firstSectionContent.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
        if indexPath.section == 0 {
            if indexPath.item == 1 {
                let cell: SettingFBCell = self.tableView.dequeueReusableCellWithIdentifier("fbcell") as! SettingFBCell
                cell.initialCell(self.view.frame.size.width)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.titleLabel.text = "Like us on facebook"
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("settingscell", forIndexPath:
                    indexPath)
                
                var contents = CoreDataManager.getCurrentUser() == nil ? contentsNotLoggedIn : firstSectionContent
                cell.textLabel?.text = contents[indexPath.item]
    
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("settingscell", forIndexPath: indexPath)
            cell.textLabel?.text = "Log out"
            cell.textLabel!.textAlignment = .Center
            cell.accessoryType = .None
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
            let indexofDemoMode = CoreDataManager.getCurrentUser() == nil ? 3 : 4
            let indexOfTutorialMode = CoreDataManager.getCurrentUser() == nil ? 4 : 5
            if indexPath.item == 0 {
                let aboutVC: AboutViewController = self.storyboard?.instantiateViewControllerWithIdentifier("aboutVC") as! AboutViewController
                self.navigationController?.pushViewController(aboutVC, animated: true)
            } else if indexPath.item == 2 {
                self.rateTwistjam()
            } else if indexPath.item == 3 && CoreDataManager.getCurrentUser() != nil {
                self.contactUs()
            } else if indexPath.item == indexofDemoMode {
                let demoVC: DemoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("demoVC") as! DemoViewController
                self.navigationController?.pushViewController(demoVC, animated: true)
            } else if indexPath.item == indexOfTutorialMode {
                let demoVC: DemoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("demoVC") as! DemoViewController
                demoVC.isDemo = false
                self.navigationController?.pushViewController(demoVC, animated: true)
            }
        } else {
            
            let refreshAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to Log Out?", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                self.dismissViewControllerAnimated(false, completion: nil)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                CoreDataManager.logoutUser()
                self.navigationController?.popViewControllerAnimated(false)
            }))
            self.presentViewController(refreshAlert, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func contactUs() {
        let emailTitle = "[\(CoreDataManager.getCurrentUser()!.email)]'s feed back"
        let messageBody = ""
        let toRecipents = ["jun@twistjam.com"]
        
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.navigationBar.tintColor = UIColor.mainPinkColor()
        
        if MFMailComposeViewController.canSendMail() {
            mc.title = "Feed Back"
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody(messageBody, isHTML: false)
            mc.setToRecipients(toRecipents)
            
            
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(mc, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Mail saved")
        case MFMailComposeResultSent.rawValue:
            print("Mail sent")
        case MFMailComposeResultFailed.rawValue:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        UIApplication.sharedApplication().keyWindow?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    func rateTwistjam() {
//        let url = "itms-apps://itunes.apple.com/app/id\(APP_STORE_ID)"
//        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
}
