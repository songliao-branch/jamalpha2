//
//  DemoViewController.swift
//  JamAlpha2
//
//  Created by FangXin on 12/16/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit


class DemoViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var demoTable: UITableView!
    var cell:DemoCell!
    var baseVC:BaseViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        findMusicVC()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(cell != nil){
            cell.demoSwith.on = NSUserDefaults.standardUserDefaults().boolForKey(KPlayLocalSoundsKey)
            if(cell.demoSwith.on){
                cell.imfoLabel.text = "Demo Mode Opened"
            }else{
                cell.imfoLabel.text = "Demo Mode Closed"
            }
        }
    }
    
    func findMusicVC(){
        baseVC = self.parentViewController!.parentViewController?.childViewControllers[0].childViewControllers[0] as! BaseViewController
    }

    
    func setUpNavigationBar() {
        self.navigationItem.title = "Demo"
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
            cell.demoSwith.on = NSUserDefaults.standardUserDefaults().boolForKey(KPlayLocalSoundsKey)
            if(cell.demoSwith.on){
                cell.imfoLabel.text = "Demo Mode Opened"
            }else{
                cell.imfoLabel.text = "Demo Mode Closed"
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
    }
    
    func switchChanged(uiswitch: UISwitch){
        NSUserDefaults.standardUserDefaults().setBool(uiswitch.on, forKey: KPlayLocalSoundsKey)
        if(uiswitch.on){
            (uiswitch.superview!.superview as! DemoCell).imfoLabel.text = "Demo Mode Opened"
            for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                musicVC.reloadDataAndTable()
            }
            KGLOBAL_closeDemoButton.hidden = false
        }else{
            (uiswitch.superview!.superview as! DemoCell).imfoLabel.text = "Demo Mode Closed"
            for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                musicVC.reloadDataAndTable()
            }
            KGLOBAL_closeDemoButton.hidden = true
        }
        
        
    }
    
}