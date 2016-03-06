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
    var tutorialTexts = ["Show music player tutorial", "Show tabs editor tutorial"]
    @IBOutlet weak var demoTable: UITableView!
    var cell:DemoCell!
    var baseVC:BaseViewController!
    
    var isFromUnLoginVC: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        findMusicVC()
    }
    
    func findMusicVC(){
        if isFromUnLoginVC {
            baseVC = (UIApplication.sharedApplication().delegate as! AppDelegate).rootViewController().childViewControllers[0].childViewControllers[0] as! BaseViewController
        } else {
            baseVC = self.parentViewController!.parentViewController?.childViewControllers[0].childViewControllers[0] as! BaseViewController
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //come back from MusicViewController to DemoViewController should refresh this variable
        if !isDemo {
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
        if isDemo {
            return 1
        }
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            cell = tableView.dequeueReusableCellWithIdentifier("demoCell") as! DemoCell
            cell.demoSwith.tintColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            cell.demoSwith.onTintColor = UIColor.mainPinkColor()
            cell.demoSwith.addTarget(self, action: "switchChanged:", forControlEvents: .ValueChanged)
            cell.demoSwith.tag = indexPath.row
        if isDemo {
            cell.imfoLabel.text = "Show Demo"
            cell.demoSwith.on = NSUserDefaults.standardUserDefaults().boolForKey(kShowDemoSong)
        } else {
            cell.imfoLabel.text = tutorialTexts[indexPath.row]
            
            if indexPath.row == 0 {
                cell.demoSwith.on = NSUserDefaults.standardUserDefaults().boolForKey(kShowTutorial)
                
            } else {
                cell.demoSwith.on =  NSUserDefaults.standardUserDefaults().boolForKey(kShowTabsEditorTutorialA)
            }
        }

        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func switchChanged(uiswitch: UISwitch){
        if isDemo {
            NSUserDefaults.standardUserDefaults().setBool(uiswitch.on, forKey: kShowDemoSong)
            if(uiswitch.on){
                for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                    musicVC.reloadData()
                }
            }else{
                for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                    musicVC.reloadData()
                }
            }
            if(MusicManager.sharedInstance.avPlayer.currentItem != nil){
                MusicManager.sharedInstance.avPlayer.pause()
                MusicManager.sharedInstance.avPlayer.seekToTime(kCMTimeZero)
                MusicManager.sharedInstance.avPlayer.removeAllItems()
                KGLOBAL_nowView.stop()
            }
        } else {
            if uiswitch.tag == 0 {
                NSUserDefaults.standardUserDefaults().setBool(uiswitch.on, forKey: kShowTutorial)
            } else {
                NSUserDefaults.standardUserDefaults().setBool(uiswitch.on, forKey: kShowTabsEditorTutorialA)
                NSUserDefaults.standardUserDefaults().setBool(uiswitch.on, forKey: kShowTabsEditorTutorialB)
            }
        }
        demoTable.reloadData()
    }
}