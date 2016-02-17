//
//  SettingsViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/19/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import MessageUI
import FBSDKCoreKit


class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  var emailStatus: String = "unemail"
  
  var isFromUnLoginVC: Bool = false
  var mc: MFMailComposeViewController!
  
  //for first release, we exclude rate twistjam, faq
  let settingTitles = ["About", "Like us on Facebook", "Rate Twistjam", "Contact Us","Demo", "Tutorial"]
    
  let settingTitlesNotSignedIn = ["About", "Like us on Facebook", "Rate Twistjam","Demo", "Tutorial"]

  //let settingTitles = ["About", "Like us on Facebook","Demo", "Tutorial"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if isFromUnLoginVC {
      presentViewAnimation()
    }
    setUpNavigationBar()
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Landscape
  }
  
  func presentViewAnimation() {
    let animationView: UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
    self.view.addSubview(animationView)
    animationView.backgroundColor = UIColor.whiteColor()
    self.view.userInteractionEnabled = false
    UIView.animateWithDuration(0.3, animations: {
      animated in
      animationView.backgroundColor = UIColor.clearColor()
      }, completion: {
        completed in
        animationView.removeFromSuperview()
        self.view.userInteractionEnabled = true
    })
  }
  
  func setUpNavigationBar() {
    self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
    self.navigationController?.navigationBar.translucent = false
    self.navigationItem.title = "Setting"
    tableView.registerClass(SettingFBCell.self, forCellReuseIdentifier: "fbcell")
    if isFromUnLoginVC {
      let leftButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "pressLeftButton:")
      self.navigationItem.setLeftBarButtonItem(leftButton, animated: false)
    }
  }
  
  func pressLeftButton(sender: UIBarButtonItem) {
    self.navigationController?.popToRootViewControllerAnimated(false)
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if CoreDataManager.getCurrentUser() == nil {
      return 1
    }
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
        if CoreDataManager.getCurrentUser() == nil {
            return settingTitlesNotSignedIn.count
        }
      return settingTitles.count
    }
    return 1 //for logout
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
        
        if CoreDataManager.getCurrentUser() == nil {
            cell.textLabel?.text = settingTitlesNotSignedIn[indexPath.item]
        } else {
            cell.textLabel?.text = settingTitles[indexPath.item]
        }
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
        
        if CoreDataManager.getCurrentUser() == nil {
        
            if indexPath.item == 0 {
                let aboutVC: AboutViewController = self.storyboard?.instantiateViewControllerWithIdentifier("aboutVC") as! AboutViewController
                self.navigationController?.pushViewController(aboutVC, animated: true)
            } else if indexPath.item == 2 {
                rateTwistjam()
            } else if indexPath.item == 3 {
                let demoVC: DemoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("demoVC") as! DemoViewController
                demoVC.isFromUnLoginVC = self.isFromUnLoginVC
                self.navigationController?.pushViewController(demoVC, animated: true)
            } else if indexPath.item == 4 {
                let demoVC: DemoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("demoVC") as! DemoViewController
                demoVC.isFromUnLoginVC = self.isFromUnLoginVC
                demoVC.isDemo = false
                self.navigationController?.pushViewController(demoVC, animated: true)
            }
        } else {//user is signed in,
            
            if indexPath.item == 0 {
                let aboutVC: AboutViewController = self.storyboard?.instantiateViewControllerWithIdentifier("aboutVC") as! AboutViewController
                self.navigationController?.pushViewController(aboutVC, animated: true)
            } else if indexPath.item == 2 {
                rateTwistjam()
            }
            else if indexPath.item == 3 {
                emailStatus = "email"
                contactUs()
            } else if indexPath.item == 4 {
                let demoVC: DemoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("demoVC") as! DemoViewController
                demoVC.isFromUnLoginVC = self.isFromUnLoginVC
                self.navigationController?.pushViewController(demoVC, animated: true)
            } else if indexPath.item == 5 {
                let demoVC: DemoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("demoVC") as! DemoViewController
                demoVC.isFromUnLoginVC = self.isFromUnLoginVC
                demoVC.isDemo = false
                self.navigationController?.pushViewController(demoVC, animated: true)
            }
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
    var emailTitle = "User's feedback"
    if CoreDataManager.getCurrentUser() != nil {
      emailTitle = "[\(CoreDataManager.getCurrentUser()!.email)]'s feedback"
    }
    let messageBody = ""
    let toRecipents = ["feedback@twistjam.com"]
    mc = MFMailComposeViewController()
    mc.navigationBar.tintColor = UIColor.mainPinkColor()
    
    if MFMailComposeViewController.canSendMail() {
      mc.title = "Feedback"
      mc.mailComposeDelegate = self
      mc.setSubject(emailTitle)
      mc.setMessageBody(messageBody, isHTML: false)
      mc.setToRecipients(toRecipents)
      self.presentViewController(mc, animated: true, completion: nil)
      //UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(mc, animated: true, completion: nil)
    }
  }
  
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    switch result.rawValue {
    case MFMailComposeResultCancelled.rawValue:
      print("cancel")
      emailStatus = "cancel"
    case MFMailComposeResultSaved.rawValue:
      print("saved")
      emailStatus = "saved"
    case MFMailComposeResultSent.rawValue:
      print("sent")
      emailStatus = "sent"
    case MFMailComposeResultFailed.rawValue:
      print("failed")
      emailStatus = "failed"
    default:
      break
    }
    self.mc.dismissViewControllerAnimated(true, completion: {
      complete in
      self.show()
    })
  }
  
  func show() {
    if emailStatus == "cancel" {
      let alertController = UIAlertController(title: nil, message: "The email has been canceled.", preferredStyle: UIAlertControllerStyle.Alert)
      alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
      self.presentViewController(alertController, animated: true, completion: nil)
    } else if emailStatus == "saved" {
      let alertController = UIAlertController(title: nil, message: "The email has been saved.", preferredStyle: UIAlertControllerStyle.Alert)
      alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
      self.presentViewController(alertController, animated: true, completion: nil)
    } else if emailStatus == "sent" {
      let alertController = UIAlertController(title: nil, message: "The email has been sent.", preferredStyle: UIAlertControllerStyle.Alert)
      alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
      self.presentViewController(alertController, animated: true, completion: nil)
    } else {
      let alertController = UIAlertController(title: nil, message: "Sorry, something goes wrong when you sent the email", preferredStyle: UIAlertControllerStyle.Alert)
      alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
      self.presentViewController(alertController, animated: true, completion: nil)
    }
  }
  
  func rateTwistjam() {
    let url = "itms-apps://itunes.apple.com/app/id\(APP_STORE_ID)"
    UIApplication.sharedApplication().openURL(NSURL(string: url)!)
  }
}
