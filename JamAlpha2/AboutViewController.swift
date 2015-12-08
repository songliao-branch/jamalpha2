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
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        setUpNavigationBar()
        setUpVersionView()
        setUpCopyrightView()
    }
    func setUpNavigationBar() {
        self.navigationItem.title = "About"
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    func setUpVersionView() {
        let imageWidth: CGFloat = 100
        let logoImageView: UIImageView = UIImageView(frame: CGRectMake((self.viewWidth - imageWidth) / 2, 40, imageWidth, imageWidth))
        logoImageView.image = UIImage(named: "splash_logo")
        self.view.addSubview(logoImageView)
        
        let versionLabel: UILabel = UILabel()
        versionLabel.frame = CGRectMake((self.viewWidth - imageWidth) / 2, 40 + imageWidth, imageWidth, 44)
        versionLabel.textAlignment = NSTextAlignment.Center
        versionLabel.text = "Version " + VERSION_NUMBER
        self.view.addSubview(versionLabel)
    }
    
    func setUpCopyrightView() {
        let imageWidth: CGFloat = 200
        let copyrightLabel: UILabel = UILabel()
        copyrightLabel.frame = CGRectMake((self.viewWidth - imageWidth) / 2, 80 + imageWidth, imageWidth, 88)
        copyrightLabel.textAlignment = NSTextAlignment.Center
        copyrightLabel.numberOfLines = 2
        copyrightLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        copyrightLabel.text = "Copyright \(COPYRIGHTYEAR) Twistjam. All Rights Reserved"
        self.view.addSubview(copyrightLabel)
    }
}
