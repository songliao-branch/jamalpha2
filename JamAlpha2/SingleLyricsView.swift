//
//  SingleLyricsView.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/26/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit

extension SongViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpLyricsArray(height: CGFloat) {
        numberOfLineInSingleLyricsView = Int(height / 66) / 2 + 1
        lyricsArray = [(str: String, time: NSTimeInterval, alpha: CGFloat, offSet: CGFloat)]()
        if lyric.lyric.count > 0 {
            for var i = 0; i < lyric.lyric.count + 2 * numberOfLineInSingleLyricsView; i++ {
                if i < numberOfLineInSingleLyricsView {
                    lyricsArray.append(("", 0, 0.5, CGFloat(i * 66) + 11))
                } else if i < lyric.lyric.count + numberOfLineInSingleLyricsView {
                    let temp: (str: String, time: NSTimeInterval, alpha: CGFloat, offSet: CGFloat) = (lyric.lyric[i - numberOfLineInSingleLyricsView].str, NSTimeInterval(lyric.lyric[i - numberOfLineInSingleLyricsView].time.toDecimalNumer()), 0.5, CGFloat(i * 66) + 11)
                    lyricsArray.append(temp)
                } else {
                    lyricsArray.append(("", 0, 0.5, CGFloat(i * 66) + 11))
                }
            }
        } else {
            for var i = 0; i < numberOfLineInSingleLyricsView; i++ {
                lyricsArray.append(("", 0, 0.5, CGFloat(i * 66) + 11))
            }
            lyricsArray.append(("You don't have any lyric for this song, please add it in Lyrics Editor or select one from others", 0, 0.5, CGFloat(numberOfLineInSingleLyricsView * 66) + 11))
        }
    }
    
    func updateSingleLyricsPosition() {
        self.lyricsArray[currentLyricsIndex + numberOfLineInSingleLyricsView - 2].alpha = 0.5
        self.lyricsArray[currentLyricsIndex + numberOfLineInSingleLyricsView - 1].alpha = 0.75
        self.lyricsArray[currentLyricsIndex + numberOfLineInSingleLyricsView].alpha = 1
        self.lyricsArray[currentLyricsIndex + numberOfLineInSingleLyricsView + 1].alpha = 0.75
        
        let tempIndexPath: [NSIndexPath] = [NSIndexPath(forItem: currentLyricsIndex + numberOfLineInSingleLyricsView - 2, inSection: 0), NSIndexPath(forItem: currentLyricsIndex + numberOfLineInSingleLyricsView - 1, inSection: 0), NSIndexPath(forItem: currentLyricsIndex + numberOfLineInSingleLyricsView, inSection: 0), NSIndexPath(forItem: currentLyricsIndex + numberOfLineInSingleLyricsView + 1, inSection: 0)]
        
        singleLyricsTableView.reloadRowsAtIndexPaths(tempIndexPath, withRowAnimation: .None)
        if currentLyricsIndex > 0{
            print("move")
            singleLyricsTableView.setContentOffset(CGPoint(x: 0, y: self.lyricsArray[currentLyricsIndex].offSet), animated: true)
        } else {
            singleLyricsTableView.setContentOffset(CGPoint(x: 0, y: self.lyricsArray[0].offSet), animated: true)
        }

    }
    
    func updateSingleLyricsArray() {
        if currentLyricsIndex > 0 {
            let topRowIndex: NSIndexPath = NSIndexPath(forItem: currentLyricsIndex, inSection: 0)
            let bottomRowIndex: NSIndexPath = NSIndexPath(forItem: currentLyricsIndex + numberOfLineInSingleLyricsView * 2 - 1, inSection: 0)
            
            for var i = 0; i < lyricsArray.count; i++ {
                self.lyricsArray[i].alpha = 0.5
            }
            
            self.lyricsArray[currentLyricsIndex + numberOfLineInSingleLyricsView].alpha = 1
            
            lyricsArray[topRowIndex.item].alpha = -singleLyricsTableView.rectForRowAtIndexPath(topRowIndex).origin.y / 66 * 0.5
            print("alpha: \(lyricsArray[topRowIndex.item].alpha)")
            lyricsArray[bottomRowIndex.item].alpha = (singleLyricsTableView.frame.size.height - singleLyricsTableView.rectForRowAtIndexPath(topRowIndex).origin.y) / 66 * 0.5
            
            singleLyricsTableView.reloadRowsAtIndexPaths([topRowIndex, bottomRowIndex], withRowAnimation: .None)
        }
    }
    
    func setUpSingleLyricsView() {
        if singleLyricsTableView == nil {
            
            let sideMargin: CGFloat = 20
            let marginToTopView: CGFloat = 0
            let frame: CGRect = CGRectMake(sideMargin, CGRectGetMaxY(topView.frame) + marginToTopView, self.view.frame.size.width - 2 * sideMargin, basesHeight + 20)
            
            let frame2: CGRect = CGRectMake(0, 0, frame.size.width, frame.size.height)
            let gradient = CAGradientLayer()
            gradient.frame = frame2
            gradient.colors = [UIColor.clearColor().CGColor, UIColor.baseColor().CGColor, UIColor.clearColor().CGColor]
            setUpLyricsArray(frame.size.height)
            singleLyricsTableView = UITableView(frame: frame, style: .Plain)
            singleLyricsTableView.backgroundColor = UIColor.clearColor()
            singleLyricsTableView.delegate = self
            singleLyricsTableView.dataSource = self
            singleLyricsTableView.registerClass(SingleLyricsTableViewCell.self, forCellReuseIdentifier: "cell")
            singleLyricsTableView.separatorStyle = .None
            singleLyricsTableView.showsHorizontalScrollIndicator = false
            singleLyricsTableView.showsVerticalScrollIndicator = false
            
            let tapOnTableView: UITapGestureRecognizer = UITapGestureRecognizer()
            tapOnTableView.addTarget(self, action: "tapOnTableView:")
            singleLyricsTableView.addGestureRecognizer(tapOnTableView)
            
            
            self.view.insertSubview(singleLyricsTableView, belowSubview: guitarActionView)
            
            for label in tuningLabels {
                label.hidden = true
            }
            
        }
        
    }
    
    func releaseSingleLyricsView() {
        if singleLyricsTableView != nil {
            print("release")
            self.singleLyricsTableView.removeFromSuperview()
            self.singleLyricsTableView = nil
            for label in self.tuningLabels {
                label.hidden = false
            }
            self.lyricsArray.removeAll()
            self.lyricsArray = nil
//            singleLyricsTableView.alpha = 1
//            UIView.animateWithDuration(0.2, animations: {
//                animate in
//                self.singleLyricsTableView.alpha = 0.1
//                }, completion: {
//                    complete in
//                    completion(complete: true)
//                    print("release")
//                    self.singleLyricsTableView.removeFromSuperview()
//                    self.singleLyricsTableView = nil                    
//                    for label in self.tuningLabels {
//                        label.hidden = false
//                    }
//                    self.lyricsArray.removeAll()
//                    self.lyricsArray = nil
//            })
        }
    }
    
    func tapOnTableView(sender: UITapGestureRecognizer) {
        dismissAction()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lyricsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SingleLyricsTableViewCell = self.singleLyricsTableView.dequeueReusableCellWithIdentifier("cell") as! SingleLyricsTableViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        cell.updateLyricsLabel(self.lyricsArray[indexPath.item].str, labelAlpha: self.lyricsArray[indexPath.item].alpha)
        let tempRowRect: CGRect = singleLyricsTableView.rectForRowAtIndexPath(indexPath)
        let temp : CGRect = singleLyricsTableView.convertRect(tempRowRect, toView: singleLyricsTableView.superview)
//        print(temp.origin.y)
//        print(singleLyricsTableView.frame.origin.y)
//        print(singleLyricsTableView.frame.origin.y + singleLyricsTableView.frame.size.height)
//        print("`````````````````````````````````")
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}