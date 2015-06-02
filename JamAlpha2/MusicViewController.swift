//
//  SecondViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 5/26/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    enum MUSIC_SELECTION_TYPE: Int {
        case TRACKS = 0
        case ARTIST = 1
        case ALBUM = 2
    }
    
    @IBOutlet weak var musicTable: UITableView!
    @IBOutlet weak var musicTypeSegment: UISegmentedControl!

    @IBAction func musicSelectionChanged(sender: UISegmentedControl) {
         musicTable.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.TRACKS.rawValue {
            return MusicAPI.sharedIntance.getSongs().count
        }else if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ARTIST.rawValue{
            return MusicAPI.sharedIntance.getArtists().count
        }
        else
        {
            return MusicAPI.sharedIntance.getAlbums().count
        }
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("musiccell", forIndexPath: indexPath) as! MusicCell
        
        if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.TRACKS.rawValue {
            
            cell.titleLabel.text = MusicAPI.sharedIntance.getSongs()[indexPath.row].title
            cell.subtitleLabel.text = MusicAPI.sharedIntance.getSongs()[indexPath.row].albumArtist
            
        } else if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ARTIST.rawValue {
            
           cell.titleLabel.text = MusicAPI.sharedIntance.getArtists()[indexPath.row].albumArtist
           let albumTrackCount = MusicAPI.sharedIntance.getArtists()[indexPath.row].albumTrackCount
            var albumCountString = ""
            
            if albumTrackCount == 1 {
                 cell.subtitleLabel.text = "\(albumTrackCount) track"
            }else{
                cell.subtitleLabel.text = "\(albumTrackCount) tracks"
            }
            
        } else if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ALBUM.rawValue {
            
            cell.titleLabel.text = MusicAPI.sharedIntance.getAlbums()[indexPath.row].albumTitle
            cell.subtitleLabel.text = MusicAPI.sharedIntance.getAlbums()[indexPath.row].albumArtist
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.TRACKS.rawValue  {
            println("song \(indexPath.row) selected")
            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailviewstoryboard") as! DetailViewController
            
            self.showViewController(detailVC, sender: self)
            
            
        }
        else if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ARTIST.rawValue {
             println("album \(indexPath.row) selected")
            let artistVC = self.storyboard?.instantiateViewControllerWithIdentifier("artistviewstoryboard") as! ArtistViewController
            
            self.showViewController(artistVC, sender: self)
            
        }
        else if  musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ARTIST.rawValue {
            
        }
        self.musicTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    

}

