//
//  AboutViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/4/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavigationBar() {
        self.navigationItem.title = "About"
    }
    
    
}
