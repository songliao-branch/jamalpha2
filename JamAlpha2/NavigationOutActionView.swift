//
//  NavigationOutActionView.swift
//  JamAlpha2
//
//  Created by Song Liao on 9/20/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

@IBDesignable
class NavigationOutActionView: UIView {
    
    var songViewController: SongViewController!
    
    var titles = ["Add your tabs", "Add your lyrics", "Go to artist", "Go to album"]

    var addTabsButton: UIButton!
    var addLyricsButton: UIButton!
    var goToArtistButton: UIButton!
    var goToAlbumButton: UIButton!
    
    let rowHeight: CGFloat = 44
    //assume height is 44 * 4
    override func drawRect(rect: CGRect) {
        // Drawing code
        let width = rect.width
        addTabsButton = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: rowHeight))
        addTabsButton.setTitle("Add your tabs", forState: .Normal)
        addTabsButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.addSubview(addTabsButton)
        
        addLyricsButton = UIButton(frame: CGRect(x: 0, y: rowHeight, width: width, height: rowHeight))
        addLyricsButton.setTitle("Add your lyrics", forState: .Normal)
        addLyricsButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.addSubview(addLyricsButton)
        
        goToArtistButton = UIButton(frame: CGRect(x: 0, y: rowHeight*2, width: width, height: rowHeight))
        goToArtistButton.setTitle("Go to artist", forState: .Normal)
        goToArtistButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.addSubview(goToArtistButton)
        
        goToAlbumButton = UIButton(frame: CGRect(x: 0, y: rowHeight*3, width: width, height: rowHeight))
        goToAlbumButton.setTitle("Go to album", forState: .Normal)
        goToAlbumButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.addSubview(goToAlbumButton)
        
        addTabsButton.addTarget(self, action: "goToTabs:", forControlEvents: .TouchUpInside)
    }
    
    func goToTabs(button: UIButton) {
        songViewController.goToTabsEditor()
    }
    

}
