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
    
    let tableViewContent: [String] = ["Like us on Facebook", "Rate Twistjam","Contact Us"]
    let tableViewContent2: [String] = ["About","Logout"]
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
    }
    
    func setUpNavigationBar() {
        self.navigationItem.title = "Setting"
        tableView.registerClass(SettingFBCell.self, forCellReuseIdentifier: "fbcell")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tableViewContent.count
        } else {
            return tableViewContent2.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                let cell: SettingFBCell = self.tableView.dequeueReusableCellWithIdentifier("fbcell") as! SettingFBCell
                cell.initialCell(self.view.frame.size.width)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.titleLabel.text = tableViewContent[indexPath.item]
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("settingscell", forIndexPath: indexPath)
                cell.textLabel?.text = tableViewContent[indexPath.item]
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("settingscell", forIndexPath: indexPath)
            cell.textLabel?.text = tableViewContent2[indexPath.item]
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                
            } else if indexPath.item == 1 {
                self.rateTwistjam()
            } else if indexPath.item == 2 {
                self.contactUs()
            }
        } else {
            if indexPath.item == 0 {
                let aboutVC: AboutViewController = self.storyboard?.instantiateViewControllerWithIdentifier("aboutVC") as! AboutViewController
                self.navigationController?.pushViewController(aboutVC, animated: true)
            } else if indexPath.item == 4 {
                let refreshAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to Log Out?", preferredStyle: UIAlertControllerStyle.Alert)
                refreshAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    self.dismissViewControllerAnimated(false, completion: nil)
                }))
                refreshAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    CoreDataManager.logoutUser()
                    self.navigationController?.popViewControllerAnimated(false)
                }))
                presentViewController(refreshAlert, animated: true, completion: nil)
            }
        }
    }
    
    func contactUs() {
        let emailTitle = "[\(CoreDataManager.getCurrentUser()!.email)]'s feed back"
        let messageBody = ""
        let toRecipents = ["jun@twistjam.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
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
