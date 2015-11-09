//
//  BrowseAllTabsViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/8/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import MediaPlayer
import UIKit

class BrowseAllTabsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tabsTableView: UITableView!
    
    var mediaItem: MPMediaItem!
    var songId = -1
    
    override func viewDidLoad() {
        setUpHeader()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        APIManager.downloadTabs(mediaItem)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func setUpHeader() {
        let statusBarLayer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        statusBarLayer.backgroundColor = UIColor.mainPinkColor()
        self.view.addSubview(statusBarLayer)
        
        let topView = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 44))
        topView.backgroundColor = UIColor.mainPinkColor()
        self.view.addSubview(topView)
        
        let buttonDimension: CGFloat = 50
        let pulldownButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonDimension, height: buttonDimension))
        
        pulldownButton.setImage(UIImage(named: "pullDown"), forState: UIControlState.Normal)
        pulldownButton.center = CGPoint(x: self.view.frame.width / 12, y: topView.height/2)
        pulldownButton.addTarget(self, action: "pullDownButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        topView.addSubview(pulldownButton)
        
        let songNameLabel = MarqueeLabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: 180, height: 20)))
        songNameLabel.type = .Continuous
        songNameLabel.scrollDuration = 15.0
        songNameLabel.fadeLength = 5.0
        songNameLabel.trailingBuffer = 30.0
        
        let artistNameLabel = UILabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: 180, height: 10)))
        artistNameLabel.textAlignment = NSTextAlignment.Center
        
        let title:String = mediaItem.title!
        let attributedString = NSMutableAttributedString(string:title)
        songNameLabel.attributedText = attributedString
        songNameLabel.textAlignment = NSTextAlignment.Center
        
        artistNameLabel.text = mediaItem.artist!
        
        
        songNameLabel.font = UIFont.systemFontOfSize(18)
        artistNameLabel.font = UIFont.systemFontOfSize(12)
        
        //increase edge width
        //TODO: set a max of width to avoid clashing with pulldown and tuning button
        songNameLabel.frame.size = CGSize(width: songNameLabel.frame.width + 20, height: 30)
        artistNameLabel.frame.size = CGSize(width: artistNameLabel.frame.width + 20, height: 30)
        songNameLabel.center.x = self.view.frame.width / 2
        songNameLabel.center.y = pulldownButton.center.y - 7
        
        artistNameLabel.center.x = self.view.frame.width / 2
        artistNameLabel.center.y = CGRectGetMaxY(songNameLabel.frame) + 3
        
        songNameLabel.textColor = UIColor.whiteColor()
        artistNameLabel.textColor =  UIColor.whiteColor()
        
        artistNameLabel.backgroundColor = UIColor.clearColor()
        
        topView.addSubview(songNameLabel)
        topView.addSubview(artistNameLabel)
    }
    
    func pullDownButtonPressed(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tabsCell = tableView.dequeueReusableCellWithIdentifier("browsetabscell", forIndexPath: indexPath) as! BrowseTabsCell
        return tabsCell
    }
}