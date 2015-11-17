//
//  SettingsViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/16/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var logoutButton: UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        logoutButton.frame = CGRectMake(50, 100, 20, 20)
        logoutButton.setTitle("logout", forState: UIControlState.Normal)
        logoutButton.addTarget(self, action: "pressLogoutButton", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(logoutButton)
    }
    

    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        // hide the navigation bar
        self.navigationController?.navigationBar.hidden = false
        //
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        //
        self.navigationItem.title = "Settings"
        
        
        self.view.backgroundColor = UIColor(red: 0.918, green: 0.918, blue: 0.918, alpha: 1)
    }
    
    func pressLogoutButton(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    
    
}
