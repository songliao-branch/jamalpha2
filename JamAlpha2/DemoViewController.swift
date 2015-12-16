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
            cell.demoSwith.on = NSUserDefaults.standardUserDefaults().boolForKey(kShowDemoSong)
            cell.imfoLabel.text = "Show Demo"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
    }
    
    func switchChanged(uiswitch: UISwitch){
        NSUserDefaults.standardUserDefaults().setBool(uiswitch.on, forKey: kShowDemoSong)
        if(uiswitch.on){
            for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                musicVC.reloadDataAndTable()
            }
            //KGLOBAL_closeDemoButton.hidden = false
        }else{
            for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                musicVC.reloadDataAndTable()
            }
            //KGLOBAL_closeDemoButton.hidden = true
        }
    }
}