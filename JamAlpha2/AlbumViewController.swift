

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
            
            if player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex {
                self.albumTable.reloadData()
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

        if MusicManager.sharedInstance.player.nowPlayingItem != nil {
            if song == MusicManager.sharedInstance.player.nowPlayingItem {
                
                // TODO: change asset icon to pink
                cell.loudspeakerImage.hidden = false
            }
            else {
                cell.loudspeakerImage.hidden = true
            }
        } else {
            cell.loudspeakerImage.hidden = true
        }
        
        cell.titleLabel.text = song.title
        
        // assign empty string if no track number
        cell.trackNumberLabel.text = song.albumTrackNumber > 0 ? String(song.albumTrackNumber) : ""
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        KGLOBAL_init_queue.suspended = true
       
        MusicManager.sharedInstance.setPlayerQueue(songsInTheAlbum)
        MusicManager.sharedInstance.setIndexInTheQueue(indexPath.row)
        
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController

        songVC.selectedFromTable = true
        songVC.musicViewController = self.musicViewController
        songVC.nowView = nowView
        songVC.transitioningDelegate = self.animator
        self.animator!.attachToViewController(songVC)
        
        self.presentViewController(songVC, animated: true, completion: {
            completed in
             //reload table to show loudspeaker icon on current selected row
            tableView.reloadData()
        })
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
 }

