

// Display all songs in all albums of a particular artist
// each section is an album

//THis is twistjam team saying
//July 7, 2015
import UIKit
import MediaPlayer
class ArtistViewController: SuspendThreadViewController, UITableViewDataSource, UITableViewDelegate{
    
    var musicViewController: MusicViewController! //for songviewcontroller to go to artist or album from musicviewcontroller
    var theArtist:Artist!
    var animator: CustomTransitionAnimation?
    var artistAllSongs:[MPMediaItem]!
    var isSeekingPlayerState = false
    
    @IBOutlet weak var artistTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistAllSongs = theArtist.getSongs()
        self.createTransitionAnimation()
        self.automaticallyAdjustsScrollViewInsets = false
        registerMusicPlayerNotificationForSongChanged()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        NetworkManager.sharedInstance.tableView = artistTable
    }
    
    func registerMusicPlayerNotificationForSongChanged(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("currentSongChanged:"), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: MusicManager.sharedInstance.player)
    }

    
    func synced(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }

    func currentSongChanged(notification: NSNotification){
        synced(self) {
            let player = MusicManager.sharedInstance.player
            if player.repeatMode == .One {
                return
            }
            
            if player.nowPlayingItem != nil {
                if player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex {
                    if !self.isSeekingPlayerState {
                        self.artistTable.reloadData()
                    }
                }
            }
        }
    }

    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("albumsectioncell") as! AlbumSectionCell
        
        cell.albumImageView.image = nil
        
        CoreDataManager.initializeSongToDatabase(theArtist.getAlbums()[section].songsIntheAlbum[0])
        
        if let coverimage = CoreDataManager.getCoverImage(theArtist.getAlbums()[section].songsIntheAlbum[0]){
            cell.albumImageView.image = coverimage
        }else{
            if let cover = theArtist.getAlbums()[section].coverImage {
                
                let image = cover.imageWithSize(CGSize(width: 85, height: 85))
                if let img = image {
                    cell.albumImageView.image = img
                } else { //this happens somewhow when songs load too fast
                    //TODO: load something else
                    cell.albumImageView.image = UIImage(named: "liweng")
                    loadAPISearchImageToCell(cell, song: theArtist.getAlbums()[section].songsIntheAlbum[0], imageSize: SearchAPI.ImageSize.Thumbnail)
                }
            }
            
            if(cell.albumImageView.image == nil){
                cell.albumImageView.image = UIImage(named: "liweng")
                loadAPISearchImageToCell(cell, song: theArtist.getAlbums()[section].songsIntheAlbum[0], imageSize: SearchAPI.ImageSize.Thumbnail)
            }
        }
        
        
        cell.albumNameLabel.text  = theArtist.getAlbums()[section].albumTitle
        
        if theArtist.getAlbums()[section].yearReleased > 1000 { //album year exist
            cell.albumYearLabel.hidden = false
            cell.albumYearLabel.text = "\(theArtist.getAlbums()[section].yearReleased)"
        } else {
            cell.albumYearLabel.hidden = true
        }
        return cell
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return theArtist.getAlbums().count
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return theArtist.getAlbums()[section].numberOfTracks
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("albumtrackcell", forIndexPath: indexPath) as! AlbumTrackCell
        
        let song = theArtist.getAlbums()[indexPath.section].songsIntheAlbum[indexPath.row]
        
        cell.titleTrailingConstant.constant = 15
        cell.loudspeakerImage.hidden = true
        if MusicManager.sharedInstance.player.nowPlayingItem != nil && MusicManager.sharedInstance.avPlayer.currentItem == nil {
            if song == MusicManager.sharedInstance.player.nowPlayingItem {
                cell.titleTrailingConstant.constant = 50
                cell.loudspeakerImage.hidden = false
            }
           
        }
        
        if let _ = song.getURL() {
            cell.cloudImage.hidden = true
            cell.titleLeadingConstraint.constant = 5
        } else {
            cell.cloudImage.hidden = false
            cell.titleLeadingConstraint.constant = 25
        }
        
        
        cell.titleLabel.text = song.title
        
        // assign empty string if no track number
        cell.trackNumberLabel.text = song.albumTrackNumber > 0 ? String(song.albumTrackNumber) : ""
        
        return cell
    }
    
    // We want to put the entire artist collection in the player queue, however the tableView only
    // returns a section and its row, this is different from a single index in the collection
    // so we mock out a single index based on all previous album tracks
    // e.g. album 0 (section 0 ) has songs a b c, album 1 has songs d e, album 2 has songs f g
    // when selecting section 2 2nd song, we iterate through all previous albums tracks
    // so we have 3 + 2 plus current selected indexPath.row which returns a single index of 3 + 2 + 1 = 6
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        isSeekingPlayerState = true
        KGLOBAL_init_queue.suspended = true
        
        let albumIndex = indexPath.section
        var songsInPreviousSections = 0
        if albumIndex > 0 {
            for i in 1...albumIndex {
               songsInPreviousSections += theArtist.getAlbums()[i-1].numberOfTracks
            }
        }
        let indexToBePlayed = songsInPreviousSections + indexPath.row
        
        MusicManager.sharedInstance.setPlayerQueue(artistAllSongs)
        MusicManager.sharedInstance.setIndexInTheQueue(indexToBePlayed)
        MusicManager.sharedInstance.avPlayer.pause()
        MusicManager.sharedInstance.avPlayer.seekToTime(kCMTimeZero)
        MusicManager.sharedInstance.avPlayer.removeAllItems()
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        ///////////////////////////////////////////
        if((artistAllSongs[indexToBePlayed]).cloudItem && NetworkManager.sharedInstance.reachability.isReachableViaWWAN() ){
            dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))) {
                while (self.isSeekingPlayerState){
                    
                    if(MusicManager.sharedInstance.player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex){
                        MusicManager.sharedInstance.player.stop()
                        KGLOBAL_nowView.stop()
                        dispatch_async(dispatch_get_main_queue()) {
                            self.showCellularEnablesStreaming(tableView)                        }
                        self.isSeekingPlayerState = false
                        break
                    }
                    if(MusicManager.sharedInstance.player.indexOfNowPlayingItem == MusicManager.sharedInstance.lastSelectedIndex && MusicManager.sharedInstance.player.playbackState != .SeekingForward){
                        if(MusicManager.sharedInstance.player.nowPlayingItem != nil){
                            dispatch_async(dispatch_get_main_queue()) {
                                songVC.selectedFromTable = true
                                songVC.transitioningDelegate = self.animator
                                self.animator!.attachToViewController(songVC)
                                songVC.musicViewController = self.musicViewController //for goToArtist and goToAlbum from here
                                self.presentViewController(songVC, animated: true, completion: {
                                    completed in
                                    //reload table to show loudspeaker icon on current selected row
                                    tableView.reloadData()
                                })
                            }
                            self.isSeekingPlayerState = false
                            break
                        }
                    }
                }
            }
        }else if (NetworkManager.sharedInstance.reachability.isReachableViaWiFi() || !artistAllSongs[indexToBePlayed].cloudItem){
            isSeekingPlayerState = false
            if(MusicManager.sharedInstance.player.nowPlayingItem == nil){
                MusicManager.sharedInstance.player.play()
            }
            songVC.selectedFromTable = true
            songVC.transitioningDelegate = self.animator
            self.animator!.attachToViewController(songVC)
            songVC.musicViewController = self.musicViewController //for goToArtist and goToAlbum from here
            self.presentViewController(songVC, animated: true, completion: {
                completed in
                //reload table to show loudspeaker icon on current selected row
                tableView.reloadData()
            })
        } else if ( !NetworkManager.sharedInstance.reachability.isReachable() && artistAllSongs[indexToBePlayed].cloudItem) {
            isSeekingPlayerState = false
            MusicManager.sharedInstance.player.stop()
            self.showConnectInternet(tableView)
        }
        //////////////////////////////////////////////////////////
    }
    
    func loadAPISearchImageToCell(cell: AlbumSectionCell, song: Findable, imageSize: SearchAPI.ImageSize) {
        dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0))) {
            SearchAPI.getBackgroundImageForSong(song.getArtist() + " " + song.getTitle(), imageSize: imageSize, completion: {
                image in
                dispatch_async(dispatch_get_main_queue()) {
                    cell.albumImageView.image = image
                    CoreDataManager.saveCoverImage(song, coverImage: image)
                }
            })
        }
    }
    
 }

