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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderView()
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
    
    @IBAction func playPause(sender: UIButton) {
        println("play button pressed")
        let player = MPMusicPlayerController.applicationMusicPlayer()
        var items = [MPMediaItem]()
        items.append(theSong)
        var collection = MPMediaItemCollection(items: items)
        player.setQueueWithItemCollection(collection)
        player.play()
        
        
    }
}
