//
//  DemoViewController.swift
//  JamAlpha2
//
//  Created by FangXin on 12/16/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import MediaPlayer

//This view controller is used for both demo and tutorials
class DemoViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var isDemo = true //false means we are showing tutorial
    
    @IBOutlet weak var demoTable: UITableView!
    var cell:DemoCell!
    var baseVC:BaseViewController!
    
    var showTutorial = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        findMusicVC()
    }
    
    func findMusicVC(){
        baseVC = self.parentViewController!.parentViewController?.childViewControllers[0].childViewControllers[0] as! BaseViewController
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //come back from MusicViewController to DemoViewController should refresh this variable
        if !isDemo {
            showTutorial = NSUserDefaults.standardUserDefaults().boolForKey(kShowTutorial)
            demoTable.reloadData()
        }
    }

    func setUpNavigationBar() {
        if isDemo {
            self.navigationItem.title = "Demo"
        } else {
            self.navigationItem.title = "Tutorial"
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            cell = tableView.dequeueReusableCellWithIdentifier("demoCell") as! DemoCell
            cell.demoSwith.tintColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            cell.demoSwith.onTintColor = UIColor.mainPinkColor()
            cell.demoSwith.addTarget(self, action: "switchChanged:", forControlEvents: .ValueChanged)
        
        
        if isDemo {
            cell.imfoLabel.text = "Show Demo"
            cell.demoSwith.on = NSUserDefaults.standardUserDefaults().boolForKey(kShowDemoSong)
        } else {
            cell.imfoLabel.text = "Show Tutorial"
            cell.demoSwith.on = showTutorial
        }

        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func switchChanged(uiswitch: UISwitch){
        if isDemo {
            NSUserDefaults.standardUserDefaults().setBool(uiswitch.on, forKey: kShowDemoSong)
            if(uiswitch.on){
                for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                    musicVC.reloadDataAndTable()
                }
            }else{
                for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                    musicVC.reloadDataAndTable()
                }
            }
            if(MusicManager.sharedInstance.avPlayer.currentItem != nil){
                MusicManager.sharedInstance.avPlayer.pause()
                MusicManager.sharedInstance.avPlayer.seekToTime(kCMTimeZero)
                MusicManager.sharedInstance.avPlayer.removeAllItems()
                self.baseVC.nowView.stop()
            }
        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: kShowTutorial)
        }

    }
}