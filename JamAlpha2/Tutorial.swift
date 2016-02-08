//
//  TabsEditorYouTube.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/25/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit
import YouTubePlayer

extension TabsEditorViewController: YouTubePlayerDelegate {
    func showTutorial(first first: Bool) {
        tutorialImage = UIImageView(frame: CGRect(x: 0, y: 0, width: trueWidth, height: trueHeight))
        let tutorialIndex = first ? "1" : "2"
        
        let deviceModel = UIDevice.currentDevice().modelName == "iPhone 4s" ? "iPhone4s" :  "iPhone6"

        tutorialImage!.image = UIImage(named: "tabs_tutorial_\(tutorialIndex)_\(deviceModel)")
        tutorialImage!.tag = Int(tutorialIndex)!
        tutorialImage!.userInteractionEnabled = true
        self.view.addSubview(tutorialImage!)
        
        tutorialCloseButton = UIButton(frame: CGRect(x: 15, y: 5, width: 50, height: 50))
        tutorialCloseButton.setImage(UIImage(named: "closebutton"), forState: .Normal)
        tutorialCloseButton.addTarget(self, action: "hideTutorial", forControlEvents: .TouchUpInside)
        self.view.addSubview(tutorialCloseButton)
        
        watchTutorialButton = UIButton(frame: CGRect(x: trueWidth-127-15, y: trueHeight-40-15, width: 127, height: 40))
        watchTutorialButton.setImage(UIImage(named: "watch_tutorial_button"), forState: .Normal)
        watchTutorialButton.addTarget(self, action: "playTutorial", forControlEvents: .TouchUpInside)
        self.view.addSubview(watchTutorialButton)
    }
    
    func hideTutorial() {
        if let image = tutorialImage {
            image.hidden = true
            tutorialCloseButton.hidden = true
            watchTutorialButton.hidden = true
            
            if image.tag == 1 {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: kShowTabsEditorTutorialA)
            } else {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: kShowTabsEditorTutorialB)
            }
        }
    }
    

    func playTutorial() {
        videoPlayerView = YouTubePlayerView(frame: CGRect(x: 20, y: 20, width: trueWidth-40, height: trueHeight-40))
        videoPlayerView.delegate = self
        let url = NSURL(string: "https://www.youtube.com/watch?v=5ZDLU4ruk-M")!
        videoPlayerView.loadVideoURL(url)
        self.view.addSubview(videoPlayerView)
    }
    
    //MARK: YouTubePlayerView delegate methods
    func playerReady(videoPlayer: YouTubePlayerView) {
        
    }
    
    func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState == .Ended || playerState == .Paused {
            videoPlayerView.hidden = true
        }
    }
    
    func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }
}