//
//  TunerViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/8/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import UIKit

class TunerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TunerManager.initialTuner()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
