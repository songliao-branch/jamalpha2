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
    func setUpTutorial() {
        tutorialOverlay = UIView(frame: CGRect(x: 0, y: 0, width: trueWidth, height: trueHeight))
        tutorialOverlay.backgroundColor = UIColor.tutorialBackgroundGray()
        self.view.addSubview(tutorialOverlay)
        
        let playTutorialButton = UIButton(frame: CGRect(x: 0, y: 0, width: 223, height: 86))
        playTutorialButton.setImage(UIImage(named: "play_tutorial"), forState: .Normal)
        playTutorialButton.addTarget(self, action: "playTutorial", forControlEvents: .TouchUpInside)
        playTutorialButton.center = CGPoint(x: trueWidth/2, y: trueHeight/2 )
        tutorialOverlay.addSubview(playTutorialButton)
        
        let skipTutorialButton = UIButton(frame: CGRect(x: 0, y: CGRectGetMaxY(playTutorialButton.frame), width: 70, height: 38))
        skipTutorialButton.setImage(UIImage(named: "skip"), forState: .Normal)
        skipTutorialButton.addTarget(self, action: "skipTutorial", forControlEvents: .TouchUpInside)
        skipTutorialButton.center.x = trueWidth/2
        tutorialOverlay.addSubview(skipTutorialButton)
    }
    
    func playTutorial() {
        videoPlayerView = YouTubePlayerView(frame: CGRect(x: 20, y: 20, width: trueWidth-40, height: trueHeight-40))
        videoPlayerView.delegate = self
        let url = NSURL(string: "https://www.youtube.com/watch?v=5ZDLU4ruk-M")!
        videoPlayerView.loadVideoURL(url)
        self.view.addSubview(videoPlayerView)
    }
    
    func skipTutorial() {
        tutorialOverlay.hidden = true
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kShowTabsEditorTutorial)
    }
    
    //MARK: YouTubePlayerView delegate methods
    func playerReady(videoPlayer: YouTubePlayerView) {
        
    }
    
    func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState == .Ended || playerState == .Paused {
            tutorialOverlay.hidden = true
            videoPlayerView.hidden = true
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: kShowTabsEditorTutorial)
        }
    }
    
    func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }
}