//
//  AboutViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/4/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        setUpNavigationBar()
        setUpVersionView()
        setUpCopyrightView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavigationBar() {
        self.navigationItem.title = "About"
    }
    
    func setUpVersionView() {
        let imageWidth: CGFloat = 100
        let logoImageView: UIImageView = UIImageView(frame: CGRectMake((self.viewWidth - imageWidth) / 2, 20, imageWidth, imageWidth))
        logoImageView.image = UIImage(named: "splash_logo")
        self.view.addSubview(logoImageView)
    }
    
    func setUpCopyrightView() {
        
    }
}
