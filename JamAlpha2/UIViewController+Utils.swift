//
//  UIViewController+Utils.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/19/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showMessage(title:String, message:String, actionTitle:String,completion: (() -> Void)? ){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertController, animated:true, completion: completion)
    }
   
    func showCellularEnablesStreaming(tableView: UITableView) {
        let alert = UIAlertController(title: "Connect to Wi-Fi to Play Music", message: "To play songs when you aren't connnected to Wi-Fi, turn on cellular playback in Music in the Settings app", preferredStyle: UIAlertControllerStyle.Alert)
        let url:NSURL! = NSURL(string : "prefs:root=MUSIC")
        let goToMusicSetting = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: {
            finished in
            UIApplication.sharedApplication().openURL(url)
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(goToMusicSetting)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: {
            completed in
            tableView.reloadData()
        })
    }
    
    func showConnectInternet(tableView: UITableView) {
        let alert = UIAlertController(title: "Connect to Wi-Fi or Cellular to Play Music", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let url:NSURL! = NSURL(string : "prefs:root=Cellular")
        let goToMusicSetting = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: {
            finished in
            UIApplication.sharedApplication().openURL(url)
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(goToMusicSetting)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: {
            completed in
            tableView.reloadData()
        })
    }
}