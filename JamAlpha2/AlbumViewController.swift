

import UIKit
import MediaPlayer

class AlbumViewController: SuspendThreadViewController, UITableViewDelegate, UITableViewDataSource{

    
    var theAlbum:Album!
    var songsInTheAlbum: [MPMediaItem]!
    private var isReloadTable:Bool = false
    
    @IBOutlet weak var albumTable: UITableView!
    

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        songsInTheAlbum = [MPMediaItem]()
        songsInTheAlbum = theAlbum.songsIntheAlbum

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
       
        KGLOBAL_init_queue.suspended = true
       
        self.reloadSongVC(allSongsSorted: songsInTheAlbum, indexToBePlayed: indexPath.row)
        
        //reload table to show loudspeaker icon on current selected row
        self.isReloadTable = true
        self.presentViewController(SongViewController.sharedInstance, animated: true, completion: nil)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if(isReloadTable){
            self.albumTable.reloadData()
            isReloadTable = false
        }
    }
    
 }

