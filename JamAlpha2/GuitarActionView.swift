
//
//  GuitarActionView.swift
//  JamAlpha2
//
//  Created by Song Liao on 9/19/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import MediaPlayer

@IBDesignable
class GuitarActionView: UIView {
    
    var songViewController: SongViewController!
    
    var volumeView: MPVolumeView!
    var speedSlider: UISlider!
    
    var chordsSwitch: UISwitch!
    var tabsSwitch: UISwitch!
    var lyricsSwitch: UISwitch!
    var countdownSwitch: UISwitch!
    
    let rowHeight: CGFloat = 44
    
    //2 sliders, 3 buttons
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        //self.backgroundColor = UIColor.whiteColor()
        let width = rect.width
        
        var rowWrappers = [UIView]()
        
        for i in 0..<6 {
            
           let row = UIView(frame: CGRect(x: 0, y: rowHeight*CGFloat(i), width: width, height: rowHeight))
            rowWrappers.append(row)
            self.addSubview(row)
        }
        
        let sliderMargin: CGFloat = 35
        
        volumeView = MPVolumeView(frame: CGRect(x: sliderMargin, y: rowHeight/2, width: width-sliderMargin*2, height: rowHeight))
        
        rowWrappers[0].addSubview(volumeView)
        
        speedSlider = UISlider(frame: CGRect(x: sliderMargin, y: 0, width: width-sliderMargin*2, height: rowHeight))
        speedSlider.center.y = rowHeight/2
        rowWrappers[1].addSubview(speedSlider)
        
        let buttonsImageNames = ["previous", "next", "previous", "next"]
        let names = ["Chords", "Tabs", "Lyrics", "Countdown"]
        
        let sideMargin = 10
        var switchHolders = [UISwitch]()
        
        for i in 2..<6 {
            let switchImage = UIImageView(frame: CGRect(x: sideMargin, y: 0, width: 35, height: 35))
            switchImage.image = UIImage(named: buttonsImageNames[i-2])
            switchImage.center.y = rowHeight/2
            rowWrappers[i].addSubview(switchImage)
            
            let switchNameLabel = UILabel(frame: CGRect(x: CGRectGetMaxX(switchImage.frame)+10, y: 0, width: 200, height: 22))
            switchNameLabel.text = names[i-2]
            switchNameLabel.center.y = rowHeight/2
            rowWrappers[i].addSubview(switchNameLabel)
            
            //use UISwitch default frame (51,31)
            let actionSwitch = UISwitch(frame: CGRect(x: width-CGFloat(sideMargin)-51, y: 0, width: 51, height: 31))
            actionSwitch.onTintColor = UIColor.mainPinkColor()
            actionSwitch.center.y = rowHeight/2
            rowWrappers[i].addSubview(actionSwitch)
            switchHolders.append(actionSwitch)
        }
        
        chordsSwitch = switchHolders[0]
        tabsSwitch = switchHolders[1]
        lyricsSwitch = switchHolders[2]
        countdownSwitch = switchHolders[3]
    }
    

}
