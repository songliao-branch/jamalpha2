//
//  SongTutorialPageItemViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 12/21/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class SongTutorialPageItemViewController: UIViewController {
    
    var pageIndex = 0
    var parent: SongTutorialPageViewController!
    
    var label: UILabel!
    var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        label = UILabel(frame: CGRect(x: 200, y: 200, width: 100, height: 100))
        label.text = "\(pageIndex) index"
        self.view.addSubview(label)
        
        dismissButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        dismissButton.center = self.view.center
        dismissButton.setTitle("Dismiss", forState: .Normal)
        dismissButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        self.view.addSubview(dismissButton)
    }
    
    func dismiss() {
        
        parent.dismissViewControllerAnimated(true, completion: nil)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kShowTutorial)
    }
}

