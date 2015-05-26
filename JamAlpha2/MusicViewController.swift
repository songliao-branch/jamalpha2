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
    var demoTitles = ["彩虹", "Thinking out loud", "海阔天空","Sugar"]
    var demoArtist = ["周杰伦","Ed","Beyond","Maroon 5"]
   
    @IBOutlet weak var musicTypeSegment: UISegmentedControl!
    
    
    @IBAction func musicSelectionChanged(sender: UISegmentedControl) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.musicTable.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoTitles.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("musiccell", forIndexPath: indexPath) as! MusicCell
        
        cell.titleLabel.text = demoTitles[indexPath.row]
        cell.subtitleLabel.text = demoArtist[indexPath.row]
        //being working on this for entire past 5 hours now gota stuck on this crap
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if musicTypeSegment.selectedSegmentIndex == 0 {
            println("\(indexPath.row) selected")
            self.musicTable.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gosong" {
            var detailVC = segue.destinationViewController as! DetailViewController
            let index = self.musicTable.indexPathForSelectedRow()!.row
            detailVC.demoString = demoArtist[index]
            
        }
    }
    
    
    
    
    

}

