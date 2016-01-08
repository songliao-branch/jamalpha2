

import UIKit
import MediaPlayer

class AlbumViewController: SuspendThreadViewController, UITableViewDelegate, UITableViewDataSource{

    var musicViewController: MusicViewController! // for songviewcontroller to go to artist or album from musicviewcontroller
    var nowView: VisualizerView!
    
    var theAlbum:Album!
    var animator: CustomTransitionAnimation?
    var songsInTheAlbum: [MPMediaItem]!

    @IBOutlet weak var albumTable: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        songsInTheAlbum = [MPMediaItem]()
        songsInTheAlbum = theAlbum.songsIntheAlbum
        self.createTransitionAnimation()
        self.automaticallyAdjustsScrollViewInsets = false
        registerMusicPlayerNotificationForSongChanged()
    }

    override func viewWillAppear(animated: Bool) {
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
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
                print("\(player.nowPlayingItem!.title) is repeating")
                return
            }
            
            if player.nowPlayingItem != nil {
                if(MusicManager.sharedInstance.lastSelectedIndex >= 0){
                    if !MusicManager.sharedInstance.lastPlayerQueue[MusicManager.sharedInstance.lastSelectedIndex].cloudItem && player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex {
                        self.albumTable.reloadData()
                    }
                }else{
                    if player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex {
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
        return theAlbum.numberOfTracks
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("albumtrackcell", forIndexPath: indexPath) as! AlbumTrackCell
        let song = theAlbum.songsIntheAlbum[indexPath.row]

        if MusicManager.sharedInstance.player.nowPlayingItem != nil && MusicManager.sharedInstance.avPlayer.currentItem == nil {
            if song == MusicManager.sharedInstance.player.nowPlayingItem {
                
                cell.titleTrailingConstant.constant = 50
                cell.loudspeakerImage.hidden = false
            }
            else {
                cell.titleTrailingConstant.constant = 15
                cell.loudspeakerImage.hidden = true
            }
        } else {
            cell.titleTrailingConstant.constant = 15
            cell.loudspeakerImage.hidden = true
        }
        
        cell.titleLabel.text = song.title
        
        // assign empty string if no track number
        cell.trackNumberLabel.text = song.albumTrackNumber > 0 ? String(song.albumTrackNumber) : ""
        
        if(NetworkManager.sharedInstance.isReachableViaWWAN || !NetworkManager.sharedInstance.isReachable){
            if (song ).cloudItem{
                cell.titleLabel.textColor = cell.titleLabel.textColor.colorWithAlphaComponent(0.5)
                cell.trackNumberLabel.textColor = cell.trackNumberLabel.textColor.colorWithAlphaComponent(0.5)
            }else{
                cell.titleLabel.textColor = cell.titleLabel.textColor.colorWithAlphaComponent(1)
                cell.trackNumberLabel.textColor = cell.trackNumberLabel.textColor.colorWithAlphaComponent(1)
            }
        }else{
            cell.titleLabel.textColor = cell.titleLabel.textColor.colorWithAlphaComponent(1)
            cell.trackNumberLabel.textColor = cell.trackNumberLabel.textColor.colorWithAlphaComponent(1)
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var key = true
        KGLOBAL_init_queue.suspended = true
       
        MusicManager.sharedInstance.setPlayerQueue(songsInTheAlbum)
        MusicManager.sharedInstance.setIndexInTheQueue(indexPath.row)
        MusicManager.sharedInstance.avPlayer.pause()
        MusicManager.sharedInstance.avPlayer.seekToTime(kCMTimeZero)
        MusicManager.sharedInstance.avPlayer.removeAllItems()
        
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController

        ///////////////////////////////////////////
        if((songsInTheAlbum[indexPath.row]).cloudItem && NetworkManager.sharedInstance.isReachableViaWWAN){
            dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))) {
                while (key){
                    
                    if(MusicManager.sharedInstance.player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex){
                        MusicManager.sharedInstance.player.stop()
                        self.nowView.stop()
                        dispatch_async(dispatch_get_main_queue()) {
                            let alert = UIAlertController(title: "Connect to Wi-Fi to Play Music", message: "To play songs when you aren't connnected to Wi-Fi, turn on cellular playback in Music in the Settings app", preferredStyle: UIAlertControllerStyle.Alert)
                            let url:NSURL! = NSURL(string : "prefs:root=MUSIC")
                            let goToMusicSetting = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: {
                                finished in
                                UIApplication.sharedApplication().openURL(url)
                            })
                            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
                            alert.addAction(goToMusicSetting)
                            alert.addAction(cancel)
                            self.presentViewController(alert, animated: true, completion: {
                                completed in
                                self.albumTable.reloadData()
                            })
                        }
                        key = false
                        break
                    }
                    if(MusicManager.sharedInstance.player.indexOfNowPlayingItem == MusicManager.sharedInstance.lastSelectedIndex && MusicManager.sharedInstance.player.playbackState != .SeekingForward){
                        if(MusicManager.sharedInstance.player.nowPlayingItem != nil){
                            dispatch_async(dispatch_get_main_queue()) {
                                songVC.selectedFromTable = true
                                songVC.transitioningDelegate = self.animator
                                self.animator!.attachToViewController(songVC)
                                songVC.musicViewController = self.musicViewController //for goToArtist and goToAlbum from here
                                songVC.nowView = self.nowView
                                self.presentViewController(songVC, animated: true, completion: {
                                    completed in
                                    //reload table to show loudspeaker icon on current selected row
                                    tableView.reloadData()
                                })
                            }
                            key = false
                            break
                        }
                    }
                }
            }
        }else if (NetworkManager.sharedInstance.isReachableViaWiFi || !(songsInTheAlbum[indexPath.row]).cloudItem){
            key = false
            if(MusicManager.sharedInstance.player.nowPlayingItem == nil){
                MusicManager.sharedInstance.player.play()
            }
            songVC.selectedFromTable = true
            songVC.transitioningDelegate = self.animator
            self.animator!.attachToViewController(songVC)
            songVC.musicViewController = self.musicViewController //for goToArtist and goToAlbum from here
            songVC.nowView = self.nowView
            self.presentViewController(songVC, animated: true, completion: {
                completed in
                //reload table to show loudspeaker icon on current selected row
                tableView.reloadData()
            })
        } else if ( !NetworkManager.sharedInstance.isReachable && (songsInTheAlbum[indexPath.row]).cloudItem) {
            key = false
            MusicManager.sharedInstance.player.stop()
            let alert = UIAlertController(title: "Connect to Wi-Fi or Cellular to Play Music", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let url:NSURL! = NSURL(string : "prefs:root=Cellular")
            let goToMusicSetting = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: {
                finished in
                UIApplication.sharedApplication().openURL(url)
            })
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(goToMusicSetting)
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: {
                completed in
                self.albumTable.reloadData()
            })
        }
        //////////////////////////////////////////////////////////
    }
    
    
 }

