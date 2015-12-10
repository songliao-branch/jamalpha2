//
//  MyTabsViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/10/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class MyTabsViewController: UIViewController {
    
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    
    var tableView: UITableView!
    
    var selectRow: [NSIndexPath] = [NSIndexPath]()
    var extentionRow: NSIndexPath!
    
    var myTabsArray = [("一里香", "Jay", "0", "unpressed"), ("二里香", "Jay", "1", "unpressed"), ("三里香", "Jay", "1", "unpressed"), ("四里香", "Jay", "0", "unpressed")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height

        // Do any additional setup after loading the view.
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
        self.navigationItem.title = "My Tabs"
    }
    
    func pressOptionButton(sender: UIButton) {
        print(sender.accessibilityIdentifier)
        for item in myTabsArray {
            print(item.3)
        }
        if sender.accessibilityIdentifier == "unpressed" {
            let index: NSIndexPath = NSIndexPath(forItem: sender.tag, inSection: 0)
            deleteRow()
            insertRow(index)
            myTabsArray[sender.tag].3 = "pressed"
        } else {
            if let index = self.extentionRow {
                if index.item == sender.tag + 1 {
                    deleteRow()
                    self.extentionRow = nil
                }
            }
            myTabsArray[sender.tag].3 = "unpressed"
        }
    }
    
    func insertRow(indexPath: NSIndexPath) {
        let addIndexPath: NSIndexPath = NSIndexPath(forItem: indexPath.item + 1, inSection: 0)
        myTabsArray.insert(("", "", "", ""), atIndex: indexPath.item + 1)
        self.extentionRow = NSIndexPath(forItem: addIndexPath.item, inSection: addIndexPath.section)
        self.selectRow.append(addIndexPath)
        self.tableView.insertRowsAtIndexPaths(self.selectRow, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func deleteRow() {
        if selectRow.count > 0 {
            myTabsArray.removeAtIndex(selectRow[0].item)
            self.tableView.deleteRowsAtIndexPaths(self.selectRow, withRowAnimation: UITableViewRowAnimation.None)
            self.selectRow.removeAll()
        }
    }
    
    func pressEditButton(sender: UIButton) {
    
    }
    
    func pressUploadButton(sender: UIButton) {
    
    }
    

}

extension MyTabsViewController: UITableViewDelegate, UITableViewDataSource {
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
            let cell: TableExtensionCell = self.tableView.dequeueReusableCellWithIdentifier("extensioncell", forIndexPath: self.selectRow[0]) as! TableExtensionCell
            cell.initialCell(self.viewWidth)
            if myTabsArray[indexPath.item].2 == "1" {
                cell.uploadButton.setTitle("Unupload", forState: UIControlState.Normal)
            }
            cell.editButton.addTarget(self, action: "pressEditButton:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.uploadButton.addTarget(self, action: "pressUploadButton:", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }
        let cell: MyTabsCell = self.tableView.dequeueReusableCellWithIdentifier("cell",  forIndexPath: indexPath) as! MyTabsCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.initialCell(self.viewWidth)
        cell.numberLabel.text = "\(indexPath.item)"
        cell.songNameLabel.text = myTabsArray[indexPath.item].0
        cell.singerNameLabel.text = myTabsArray[indexPath.item].1
        cell.uploadedImageView.alpha = 0
        if myTabsArray[indexPath.item].2 == "1" {
            cell.uploadedImageView.alpha = 1
        }
        cell.optionButton.addTarget(self, action: "pressOptionButton:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.optionButton.accessibilityIdentifier = myTabsArray[indexPath.item].3
        cell.optionButton.tag = indexPath.item
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTabsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
}
