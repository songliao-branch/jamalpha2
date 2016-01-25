//
//  TabsEditorCapo.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/25/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit

extension TabsEditorViewController {
    func generateFretNumberOnFullStringView(sender: Int) {
        let count = 25
        fretNumberOnFullStringView = UIView()
        for item in fretNumberOnFullStringView.subviews {
            item.removeFromSuperview()
        }
        fretNumberOnFullStringView.frame = CGRectMake(0, 14 / 20 * self.trueHeight, self.trueWidth / 5 * CGFloat(count - sender), 1 / 20 * self.trueHeight)
        fretNumberOnFullStringView.backgroundColor = UIColor.clearColor()
        let labelWidth: CGFloat = 1 / 20 * self.trueHeight
        for var i = 0; i < count - sender; i++ {
            let tempLabel: UILabel = UILabel()
            let positionX = (self.string6FretPosition[i] + self.string6FretPosition[i + 1]) / 2
            tempLabel.frame = CGRectMake(positionX - labelWidth / 2, 0, labelWidth, labelWidth)
            tempLabel.text = "\(sender + i)"
            tempLabel.backgroundColor = UIColor.clearColor()
            tempLabel.textAlignment = .Center
            tempLabel.font = UIFont.systemFontOfSize(10)
            fretNumberOnFullStringView.addSubview(tempLabel)
        }
        self.completeImageView.addSubview(fretNumberOnFullStringView)
    }
    
    func cropFullStringImageView(sender: Int) {
        let count = 25
        let croppedLength: CGFloat = self.trueWidth / 5 * CGFloat(count - sender)
        let cropRect: CGRect = CGRectMake(0, 0, croppedLength, self.completeStringView.frame.size.height)
        self.completeImageView.image = UIImage(named: "iPhone5_fullFretboard")
        let image = self.completeImageView.cropViewWithRect(cropRect)
        
        self.completeStringView.contentSize = CGSizeMake(croppedLength, 15 / 20 * self.trueHeight)
        self.completeImageView.frame = CGRectMake(0, 0, croppedLength, 15 / 20 * self.trueHeight)
        self.completeImageView.image = image
    }
    
    func updateCollectionView(sender: Int) {
        let count = self.mainViewDataArray.count
        if 25 - sender == count + 1 {
            let maxFretNumber = count - 1
            for var i = 0; i < count; i++ {
                if self.mainViewDataArray[i].fretNumber == maxFretNumber {
                    let temp: mainViewData = mainViewData()
                    temp.fretNumber = maxFretNumber + 1
                    let tempButton: [noteButtonWithTab] = [noteButtonWithTab]()
                    temp.noteButtonsWithTab = tempButton
                    self.mainViewDataArray.insert(temp, atIndex: i + 1)
                    self.string3BackgroundImage.insert("iPhone5_fret", atIndex: i + 1)
                    self.fretsNumber.insert(maxFretNumber + 1, atIndex: i + 1)
                    break
                }
            }
        } else if 25 - sender == count - 1 {
            let maxFretNumber = count - 1
            for var i = 0; i < count; i++ {
                if self.mainViewDataArray[i].fretNumber == maxFretNumber {
                    self.mainViewDataArray.removeAtIndex(i)
                    self.string3BackgroundImage.removeAtIndex(i)
                    self.fretsNumber.removeAtIndex(i)
                    break
                }
            }
        }
        self.collectionView.reloadData()
    }
}


