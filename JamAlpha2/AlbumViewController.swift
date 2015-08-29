

import UIKit
import MediaPlayer

class AlbumViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var theAlbum:Album!
    var createdNewPage:Bool = true
    var player: MPMusicPlayerController!
    var musicViewController: MusicViewController?
    var animator: CustomTransitionAnimation?
    var songsInTheAlbum: [MPMediaItem]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        songsInTheAlbum = [MPMediaItem]()
        songsInTheAlbum = theAlbum.songsIntheAlbum
        self.createTransitionAnimation()
        //setCollectionToPlayer()
        //MusicManager.sharedInstance.setPlayerQueue(songsInTheAlbum)
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func viewWillAppear(animated: Bool) {
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
    }
    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theAlbum.numberOfTracks
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("albumtrackcell", forIndexPath: indexPath) as! AlbumTrackCell
        let song = theAlbum.songsIntheAlbum[indexPath.row]

        let trackNumber = song.albumTrackNumber
        let title = song.title
        
        if trackNumber < 1 {
            cell.trackNumberLabel.hidden = true
        } else {
            cell.trackNumberLabel.text = "\(trackNumber)"
        }
        cell.titleLabel.text = title
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       // setUpSongVC(songsInTheAlbum, selectedSong: indexPath.row, selectedFromTable: true)
        
        //MusicManager.sharedInstance.setCurrentSongInTheQueue(songsInTheAlbum, selectedIndex: indexPath.row)
        MusicManager.sharedInstance.setPlayerQueue(songsInTheAlbum)
        MusicManager.sharedInstance.setIndexInTheQueue(indexPath.row)
        
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        songVC.musicViewController = self.musicViewController
        songVC.player = self.player
        songVC.selectedFromTable = true
        
        songVC.transitioningDelegate = self.animator
        self.animator!.attachToViewController(songVC)
        self.presentViewController(songVC, animated: true, completion: nil)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
//    func setCollectionToPlayer(){
//        var collection: MPMediaItemCollection!
//        collection = MPMediaItemCollection(items: songsInTheAlbum)
//        player.setQueueWithItemCollection(collection)
//
//    }
//    func setUpSongVC(collection: [MPMediaItem],selectedSong:Int,selectedFromTable:Bool){
//        if(selectedFromTable){
//            if(createdNewPage){
//                println("createdNewPage")
//                let repeatMode = player.repeatMode
//                let shuffle = player.shuffleMode
//                MPMusicPlayerController.systemMusicPlayer().stop()
//                player.repeatMode = repeatMode
//                player.shuffleMode = shuffle
//                createdNewPage = false
//            }
//            
//            if(player.repeatMode == .One && player.shuffleMode == .Off){
//                player.repeatMode = .All
//                if(player.nowPlayingItem != collection[selectedSong]||player.nowPlayingItem == nil){
//                    
//                    player.nowPlayingItem = collection[selectedSong]
//                }
//                player.repeatMode = .One
//            }else{
//                if(player.nowPlayingItem != collection[selectedSong]||player.nowPlayingItem == nil){
//                    player.nowPlayingItem = collection[selectedSong]
//                }
//            }
//        }
//        
//        
//        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
//        songVC.musicViewController = self.musicViewController
//        songVC.player = self.player
//        songVC.selectedFromTable = selectedFromTable
//        
//        songVC.transitioningDelegate = self.animator
//        self.animator!.attachToViewController(songVC)
//        self.presentViewController(songVC, animated: true, completion: nil)
//    }

    

}
