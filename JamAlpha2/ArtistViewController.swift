

// Display all songs in all albums of a particular artist
// each section is an album

//THis is twistjam team saying
//July 7, 2015
import UIKit
import MediaPlayer
class ArtistViewController: SuspendThreadViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    var theArtist:Artist!
    var artistAllSongs:[MPMediaItem]!
    private var isReloadTable:Bool = false
    
    @IBOutlet weak var artistTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistAllSongs = theArtist.getSongs()
        
        //MusicManager.sharedInstance.setPlayerQueue(artistAllSongs)
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
                self.artistTable.reloadData()
            }
        }
    }

    
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("albumsectioncell") as! AlbumSectionCell
        let image = theArtist.getAlbums()[section].coverImage.imageWithSize(CGSize(width: 85, height: 85))
        cell.albumImageView.image = image
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
    
    // We want to put the entire artist collection in the player queue, however the tableView only
    // returns a section and its row, this is different from a single index in the collection
    // so we mock out a single index based on all previous album tracks
    // e.g. album 0 (section 0 ) has songs a b c, album 1 has songs d e, album 2 has songs f g
    // when selecting section 2 2nd song, we iterate through all previous albums tracks
    // so we have 3 + 2 plus current selected indexPath.row which returns a single index of 3 + 2 + 1 = 6
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
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
        

        SongViewController.sharedInstance.reloadSongVC(selectedFromTable: true)
        
        //reload table to show loudspeaker icon on current selected row
        self.isReloadTable = true
        
        self.presentViewController(SongViewController.sharedInstance, animated: true, completion: nil)
        
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if(isReloadTable){
            self.artistTable.reloadData()
            isReloadTable = false
        }
    }
 }

