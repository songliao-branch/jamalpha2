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
        for i in 0..<(count - sender) {
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
        let croppedLength: CGFloat = 3409 * CGFloat(count - sender) / 25
        let cropRect: CGRect = CGRectMake(0, 0, croppedLength, 282)
        let croppedImage =  UIImage(named: "iPhone5_fullFretboard")?.cropImageWithRect(cropRect)
        
        let croppedViewLength: CGFloat = self.trueWidth / 5 * CGFloat(count - sender)
        self.completeStringView.contentSize = CGSizeMake(croppedViewLength, 15 / 20 * self.trueHeight)
        self.completeImageView.frame = CGRectMake(0, 0, croppedViewLength, 15 / 20 * self.trueHeight)
        self.completeImageView.image = croppedImage

        
    }
    
    func updateCollectionView(sender: Int) {
        let count = self.mainViewDataArray.count
        if 25 - sender == count + 1 {
            let maxFretNumber = count - 1
            for i in 0..<count {
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
            for i in 0..<count {
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


