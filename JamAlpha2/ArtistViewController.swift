//
//  ArtistViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 5/27/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    let edDiscography:NSDictionary = [
        "+" : ["Grade 8","The A Team", "Sunburn", "Give me Love"],
        "X" : ["Thinking out loud", "Don't", "Sing"]
    ]
    
    let dictIndex = ["+","X"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false//align tableview to top
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return edDiscography.count as Int
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return dictIndex[section]
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var eachLine = edDiscography[dictIndex[section]] as! [String]
        
        return eachLine.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        
        var eachLine = edDiscography[dictIndex[indexPath.section]] as! [String]
        var song = eachLine[indexPath.row]


        cell.textLabel!.text = song
        
        return cell
    }
}
