//
//  DetailViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 5/26/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import UIKit
import MediaPlayer

class DetailViewController: UIViewController {

    var theSong:MPMediaItem!
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var albumLabel: UILabel!
    
    @IBOutlet weak var albumCoverImage: UIImageView!
    
    @IBOutlet weak var chordBase: UIView!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    var isPlaying = false
    
    let player = MPMusicPlayerController.applicationMusicPlayer()

    var chords = [Chord]()
    var current = 0
    var delcur = 0
    var labels = [UILabel]()
    var startTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderView()
        setUpSong()
        setUpDemoChords()
        
        initializeChordOnView()
      
    }
    
    
    
    func setUpDemoChords(){
        
        var chord1 = Chord(content: "C", time: 1)
        var chord2 = Chord(content: "G", time: 3)
        var chord3 = Chord(content: "Em", time: 6)
        var chord4 = Chord(content: "D", time: 10)
        
        
        var chord5 = Chord(content: "C", time: 13)
        var chord6 = Chord(content: "G", time: 14)
        var chord7 = Chord(content: "Em", time: 16)
        var chord8 = Chord(content: "D", time: 17)
        
        var chord9 = Chord(content: "C", time: 20)
        var chord10 = Chord(content: "G", time: 21)
        var chord11 = Chord(content: "Em", time: 22)
        var chord12 = Chord(content: "D", time: 24)
        
        var chord13 = Chord(content: "C", time: 29)
        var chord14 = Chord(content: "G", time: 33)
        var chord15 = Chord(content: "Em", time: 34)
        var chord16 = Chord(content: "D", time: 40)
        
        chords.append(chord1)
        chords.append(chord2)
        chords.append(chord3)
        chords.append(chord4)
        
        
        chords.append(chord5)
        chords.append(chord6)
        chords.append(chord7)
        chords.append(chord8)
        
        
        chords.append(chord9)
        chords.append(chord10)
        chords.append(chord11)
        chords.append(chord12)
        
        
        chords.append(chord13)
        chords.append(chord14)
        chords.append(chord15)
        chords.append(chord16)
        
    }
    
    func initializeChordOnView(){
        var isLessThan5 = true
        
        while isLessThan5 {
            if current < chords.count
            {
                var theChord = chords[current]
                if theChord.mTime <= 5 {
                    current++
                    
                    println(theChord.mTime)
                    //1
                    let widthOfLabel : CGFloat = 30
                    let heightOfLabel:CGFloat = 20
                    let segmentForOneSecond:CGFloat = chordBase.frame.height / 5
                    let yPosition : CGFloat = chordBase.frame.height - CGFloat(theChord.mTime * Int(segmentForOneSecond))
                    let label = UILabel(frame: CGRectMake(0, 0, widthOfLabel, heightOfLabel))
                    label.center = CGPointMake(self.chordBase.frame.width / 2, yPosition)
                    label.text = theChord.mContent
                    label.textAlignment = NSTextAlignment.Center
                    labels.append(label)
                    self.chordBase.addSubview(label)
                    
                }
                else {
                    isLessThan5 = false
                }
            }
            else {
                isLessThan5 = false
            }
        }
    }
    
    func startAnimate(){
        var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        //animate the initial labels first
        for i in 0...current-1{
            UIView.animateWithDuration( NSTimeInterval(chords[i].mTime), animations: {
                self.labels[i].center.y = self.chordBase.frame.height
            })
        }
    }
    
    func update(){
        startTime++
        
        if delcur+1 < chords.count && startTime == chords[delcur+1].mTime - 1
        {
            UIView.animateWithDuration( 0.6, animations: {
                self.labels[self.delcur].alpha = 0
                
            })
            delcur++
        }
        
        if current < chords.count && startTime == chords[current].mTime - 5 {
            var label = UILabel(frame: CGRectMake(0, 0, 30,20))
            label.text = chords[current].mContent
            label.textAlignment = NSTextAlignment.Center
            label.center = CGPointMake(self.chordBase.frame.width/2, 0 - 20/2)
            
            self.chordBase.addSubview(label)
            labels.append(label)
            
            UIView.animateWithDuration( NSTimeInterval(5), animations: {
                label.center.y = self.chordBase.frame.height
                
            })
            
            current++
        }
        
    }
    
    func renderView(){
        if let song = theSong {
            println("song title: \(song.title)")
            println("song artist: \(song.artist)")
            println("song album: \(song.albumTitle)")
            
      
            titleLabel.text = song.title
            
            artistLabel.text = song.artist
            albumLabel.text = song.albumTitle
            var artwork = song.artwork
            var bounds = artwork.bounds
            if let art = artwork {
                let uncroppedImage = art.imageWithSize(bounds.size)
                 albumCoverImage.image = Toucan(image: uncroppedImage).maskWithEllipse(borderWidth: 0, borderColor: UIColor.clearColor()).image
            }
        }
        else
        {
            println("song cannot be loaded")
        }
    }
    func setUpSong(){
        var items = [MPMediaItem]()
        items.append(theSong)
        var collection = MPMediaItemCollection(items: items)
        player.setQueueWithItemCollection(collection)
    }

    @IBAction func playPause(sender: UIButton) {
        println("play button pressed")
        //if not playing,starts
        if !isPlaying {
            player.play()
            playPauseButton.setTitle("Pause", forState: UIControlState.Normal)
            isPlaying = true
            
            
            startAnimate()
            
            
        } else {
            player.pause()
            playPauseButton.setTitle("Play", forState: UIControlState.Normal)
            isPlaying = false
        }
        
        
    }
}
