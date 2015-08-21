

import UIKit
import MediaPlayer

class AlbumViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var theAlbum:Album!
    var createdNewPage:Bool = true
    var player:MPMusicPlayerController!
    var lastSelectedIndex = -1
    var mc:MusicViewController?
    var animator: CustomTransitionAnimation?
    var uniqueAlbums:[MPMediaItem]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpSong()
        self.createTransitionAnimation()
        self.automaticallyAdjustsScrollViewInsets = false
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel!.text = theAlbum.songsIntheAlbum[indexPath.row].title
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        uniqueAlbums = theAlbum.songsIntheAlbum
        setUpSongVC(uniqueAlbums, selectedSong: indexPath.row,selectedFromTable: true)
    }
    
    func setUpSongVC(colloectForSongs:[MPMediaItem],selectedSong:Int,selectedFromTable:Bool){
        if(selectedFromTable){
            if(createdNewPage){
                println("createdNewPage")
                let repeatMode = player.repeatMode
                let shuffle = player.shuffleMode
                NSNotificationCenter.defaultCenter().removeObserver(MPMusicPlayerController.systemMusicPlayer())
                MPMusicPlayerController.systemMusicPlayer().stop()
                player.repeatMode = repeatMode
                player.shuffleMode = shuffle
                createdNewPage = false
                mc?.createdNewPage = false
            }
            
            if(player.repeatMode == .One && player.shuffleMode == .Off){
                player.repeatMode = .All
                if(lastSelectedIndex != selectedSong){
                    player.nowPlayingItem = colloectForSongs[selectedSong]
                }
                player.repeatMode = .One
            }else{
                if(lastSelectedIndex != selectedSong){
                    player.nowPlayingItem = colloectForSongs[selectedSong]
                }
            }
        }
        
        lastSelectedIndex = selectedSong
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        songVC.mc = self.mc
        // songVC.songCollection = colloectForSongs
        //songVC.songIndex = selectedSong
        songVC.player = self.player
        songVC.selectedFromTable = selectedFromTable
        
        songVC.transitioningDelegate = self.animator
        self.animator!.attachToViewController(songVC)
        self.presentViewController(songVC, animated: true, completion: nil)
    }
    
    func setUpSong(){
        //but we are playing an item with a selected index for example index 2,i.e. item:C
        var collection: MPMediaItemCollection!
        collection = MPMediaItemCollection(items: uniqueAlbums)
        player.setQueueWithItemCollection(collection)
    }
    

}
