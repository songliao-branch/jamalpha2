//
//  SecondViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 5/26/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import UIKit

class MusicViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var musicTable: UITableView!
    var fakedata = ["彩虹", "Thinking out loud", "海阔天空"]
    var items: NSMutableArray! = NSMutableArray()
    
    @IBOutlet weak var musicTypeSegment: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.items.addObject("Apple watch")
        self.items.addObject("Apple car")
        self.items.addObject("Apple tea")
        
        self.musicTable.reloadData()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fakedata.count
        
    }
//    @IBAction func listChanged(sender: UISegmentedControl) {
//        if sender.selectedSegmentIndex == 0 {
//            //tracks
//        }
//        else if sender.selectedSegmentIndex == 1{
//            //artist
//        }
//        else if sender.selectedSegmentIndex == 2 {
//            //album
//        }
//    }
//    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("musiccell", forIndexPath: indexPath) as! MusicCell
        
        cell.titleLabel.text = fakedata[indexPath.row]
        cell.subtitleLabel.text = fakedata[indexPath.row]
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if musicTypeSegment.selectedSegmentIndex == 0 {
           
            
            
        }
    }
    

}

