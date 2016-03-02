

import UIKit
import MediaPlayer

class AlbumViewController: SuspendThreadViewController, UITableViewDelegate, UITableViewDataSource{

    var musicViewController: MusicViewController! // for songviewcontroller to go to artist or album from musicviewcontroller
    
    var theAlbum: SimpleAlbum!
    var animator: CustomTransitionAnimation?
    var songsInTheAlbum: [MPMediaItem]!
    var isSeekingPlayerState = false

    @IBOutlet weak var albumTable: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        songsInTheAlbum = [MPMediaItem]()
        songsInTheAlbum = theAlbum.songCollection.items
        
        self.createTransitionAnimation()
        self.automaticallyAdjustsScrollViewInsets = false
        registerMusicPlayerNotificationForSongChanged()
    }
    

    override func viewWillAppear(animated: Bool) {
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        NetworkManager.sharedInstance.tableView = self.albumTable
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
                        self.albumTable.reloadData()
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theAlbum.songCollection.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("albumtrackcell", forIndexPath: indexPath) as! AlbumTrackCell
        let song = theAlbum.songCollection.items[indexPath.row]

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
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        isSeekingPlayerState = true
        KGLOBAL_init_queue.suspended = true
       
        MusicManager.sharedInstance.setPlayerQueue(songsInTheAlbum)
        MusicManager.sharedInstance.setIndexInTheQueue(indexPath.row)
        MusicManager.sharedInstance.avPlayer.pause()
        MusicManager.sharedInstance.avPlayer.seekToTime(kCMTimeZero)
        MusicManager.sharedInstance.avPlayer.removeAllItems()
        
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController

        ///////////////////////////////////////////
        if((songsInTheAlbum[indexPath.row]).cloudItem && NetworkManager.sharedInstance.reachability.isReachableViaWWAN() ){
            dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))) {
                while (self.isSeekingPlayerState){
                    
                    if(MusicManager.sharedInstance.player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex){
                        MusicManager.sharedInstance.player.stop()
                        KGLOBAL_nowView.stop()
                        dispatch_async(dispatch_get_main_queue()) {
                            self.showCellularEnablesStreaming(tableView)
                        }
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
        }else if (NetworkManager.sharedInstance.reachability.isReachableViaWiFi() || !(songsInTheAlbum[indexPath.row]).cloudItem){
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
        } else if ( !NetworkManager.sharedInstance.reachability.isReachable() && (songsInTheAlbum[indexPath.row]).cloudItem) {
            isSeekingPlayerState = false
            MusicManager.sharedInstance.player.stop()
            self.showConnectInternet(tableView)
        }
        //////////////////////////////////////////////////////////
    }
    
 }

