//
//  HeadViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 5/26/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import UIKit

class HeadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var demoSongs = ["Sing","Don't","I see fire", "I'm a mess"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoSongs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("onelinecell", forIndexPath: indexPath) as! OneLineCell
        cell.rowNumberLabel.text = "\(indexPath.row + 1)"
        cell.titleLabel.text = demoSongs[indexPath.row]
        
        return cell
    }
    
}
