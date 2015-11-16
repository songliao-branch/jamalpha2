//
//  MyLyricsViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/16/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class MyLyricsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        // hide the navigation bar
        self.navigationController?.navigationBar.hidden = false
        //
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        //
        self.navigationItem.title = "My Lyrics"
        
        
        self.view.backgroundColor = UIColor(red: 0.918, green: 0.918, blue: 0.918, alpha: 1)
    }

}
