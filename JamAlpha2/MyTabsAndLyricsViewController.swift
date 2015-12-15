//
//  MyTabsViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/10/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class MyTabsAndLyricsViewController: UIViewController {
    
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    
    var tableView: UITableView!
    
    var selectRow: [NSIndexPath] = [NSIndexPath]()
    
    var tabsOrLyrics: String!
    
    var myTitle: String!
    var myDataArray: [(String, String, String, String)]!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height

        // Do any additional setup after loading the view.
        loadData()
        setUpNavigationBar()
        setUpTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.title = self.myTitle
    }
    
    func loadData() {
        let currentUserId = CoreDataManager.getCurrentUser()?.id
        
        
        
        if tabsOrLyrics == "tabs" {
            self.myTitle = "My Tabs"
            // 0 means need to upload, 1 means already uploaded
            self.myDataArray = [("一里香", "Jay", "0", "unpressed"), ("二里香", "Jay", "1", "unpressed"), ("三里香", "Jay", "1", "unpressed"), ("四里香", "Jay", "0", "unpressed")] // tabs data
        } else {
            self.myTitle = "My Lyrics"
            // 0 means need to upload, 1 means already uploaded
            self.myDataArray = [("五里香", "Jay", "0", "unpressed"), ("六里香", "Jay", "1", "unpressed"), ("七里香", "Jay", "1", "unpressed"), ("八里香", "Jay", "0", "unpressed")] // lyrics data
        }
    }
    
    func pressOptionButton(sender: UIButton) {
        if myDataArray[sender.tag].3 == "unpressed" || myDataArray[sender.tag].3 == "" {
            let index: NSIndexPath = NSIndexPath(forItem: sender.tag, inSection: 0)
            deleteRow()
            insertRow(index)
            myDataArray[sender.tag].3 = "pressed"
        } else {
            deleteRow()
        }

    }
    
    func insertRow(indexPath: NSIndexPath) {
        let addIndexPath: NSIndexPath = NSIndexPath(forItem: indexPath.item + 1, inSection: 0)
        myDataArray.insert(("", "", "", ""), atIndex: indexPath.item + 1)
        self.selectRow.append(addIndexPath)
        self.tableView.insertRowsAtIndexPaths(self.selectRow, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func deleteRow() {
        if selectRow.count > 0 {
            myDataArray[selectRow[0].item - 1].3 = "unpressed"
            myDataArray.removeAtIndex(selectRow[0].item)
            self.tableView.deleteRowsAtIndexPaths(self.selectRow, withRowAnimation: UITableViewRowAnimation.Automatic)
            self.selectRow.removeAll()
        }
    }
    
    func pressEditButton(sender: UIButton) {
        // go to edit tab vc
    }
    
    func pressUploadButton(sender: UIButton) {
        // upload the tab
        changeUploadUnUpload()
    }
    
    func changeUploadUnUpload() {
        if selectRow.count > 0 {
            if myDataArray[selectRow[0].item - 1].2 == "0" {
                myDataArray[selectRow[0].item - 1].2 = "1"
            } else {
                myDataArray[selectRow[0].item - 1].2 = "0"
            }
            self.tableView.reloadData()
        }
    }
    
    

}

extension MyTabsAndLyricsViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTableView() {
        self.tableView = UITableView(frame: CGRectMake(0, 0, self.viewWidth, self.viewHeight), style: UITableViewStyle.Plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(MyTabsCell.self, forCellReuseIdentifier: "cell")
        self.tableView.registerClass(TableExtensionCell.self, forCellReuseIdentifier: "extensioncell")
        self.view.addSubview(self.tableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.selectRow.count > 0{
            if self.selectRow[0].item == indexPath.item {
                let cell: TableExtensionCell = self.tableView.dequeueReusableCellWithIdentifier("extensioncell", forIndexPath: self.selectRow[0]) as! TableExtensionCell
                cell.initialCell(self.viewWidth)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                if myDataArray[indexPath.item - 1].2 == "1" {
                    cell.uploadButton.setTitle("Remove Upload", forState: UIControlState.Normal)
                    cell.uploadButton.titleLabel?.font = UIFont.systemFontOfSize(12)
                } else {
                    cell.uploadButton.setTitle("Upload", forState: UIControlState.Normal)
                    cell.uploadButton.titleLabel?.font = UIFont.systemFontOfSize(18)
                }
                cell.editButton.addTarget(self, action: "pressEditButton:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.uploadButton.addTarget(self, action: "pressUploadButton:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            }
        }
        let cell: MyTabsCell = self.tableView.dequeueReusableCellWithIdentifier("cell",  forIndexPath: indexPath) as! MyTabsCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.initialCell(self.viewWidth)
        if self.selectRow.count > 0 {
            if indexPath.item > self.selectRow[0].item {
                cell.numberLabel.text = "\(indexPath.item - 1)"
                cell.optionButton.tag = indexPath.item - 1
            }
        } else {
            cell.numberLabel.text = "\(indexPath.item)"
            cell.optionButton.tag = indexPath.item
        }
        cell.songNameLabel.text = myDataArray[indexPath.item].0
        cell.singerNameLabel.text = myDataArray[indexPath.item].1
        cell.uploadedImageView.alpha = 0
        if myDataArray[indexPath.item].2 == "1" {
            cell.uploadedImageView.alpha = 1
        }
        cell.optionButton.addTarget(self, action: "pressOptionButton:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.optionButton.accessibilityIdentifier = myDataArray[indexPath.item].3
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myDataArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
}
