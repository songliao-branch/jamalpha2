//
//  SuspendThreadViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/3/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer


class SuspendThreadViewController: UIViewController, UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //1
        KGLOBAL_init_queue.suspended = true
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2
        if !decelerate {
            KGLOBAL_init_queue.suspended = false
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        KGLOBAL_init_queue.suspended = false
    }
    
    func reloadSongVC(allSongsSorted allSongsSorted:[MPMediaItem],indexToBePlayed:Int){
        let lastSelectedIndex = MusicManager.sharedInstance.lastSelectedIndex
        let lastPlayerQueue = MusicManager.sharedInstance.lastPlayerQueue
        
        MusicManager.sharedInstance.setPlayerQueue(allSongsSorted)
        MusicManager.sharedInstance.setIndexInTheQueue(indexToBePlayed)
        
        if(lastSelectedIndex != -1 ){
            if(MusicManager.sharedInstance.player.nowPlayingItem != lastPlayerQueue[lastSelectedIndex]){
                SongViewController.sharedInstance.reloadSongVC(selectedFromTable: true)
            }
        }else{
            SongViewController.sharedInstance.reloadSongVC(selectedFromTable: true)
        }
    }
}