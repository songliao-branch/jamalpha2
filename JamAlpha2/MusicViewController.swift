import UIKit
import MediaPlayer

class MusicViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    private var uniqueSongs = [MPMediaItem]()
    private var uniqueArtists = [Artist]()
    private var uniqueAlbums = [Album]()
    
    var pageIndex = 0
    
    @IBOutlet weak var musicTable: UITableView!
    
    //for transition view animator
    var animator: CustomTransitionAnimation?
    var nowView: VisualizerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        uniqueSongs = MusicManager.sharedInstance.uniqueSongs
        uniqueArtists = MusicManager.sharedInstance.uniqueArtists
        uniqueAlbums = MusicManager.sharedInstance.uniqueAlbums
        
        createTransitionAnimation()
        registerMusicPlayerNotificationForSongChanged()
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

                self.musicTable.reloadData()
            }
        }
    }

    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
    func popToCurrentSong(){
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        songVC.selectedFromTable = false
        songVC.musicViewController = self
        songVC.transitioningDelegate = self.animator
        self.animator!.attachToViewController(songVC)
        self.navigationController!.presentViewController(songVC, animated: true, completion: nil)
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pageIndex == 0  {
                return uniqueSongs.count
        }
        else if pageIndex == 1 {
            return uniqueArtists.count
        }
        else
        {
            return uniqueAlbums.count
        }
    }
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("musiccell", forIndexPath: indexPath) as! MusicCell

        if pageIndex == 0 {
            
            let song = uniqueSongs[indexPath.row]
            
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
            
            let image = song.artwork!.imageWithSize(CGSize(width: 54, height: 54))
            cell.coverImage.image = image
            cell.mainTitle.text = song.title
            cell.subtitle.text = song.artist
            
        } else if pageIndex == 1  {
            
            let theArtist = uniqueArtists[indexPath.row]
            
            let image = theArtist.getAlbums()[0].coverImage.imageWithSize(CGSize(width: 80, height: 80))
            cell.loudspeakerImage.hidden = true
            cell.imageWidth.constant = 80
            cell.imageHeight.constant = 80
            cell.coverImage.image = image
            
            
            let numberOfAlbums = theArtist.getAlbums().count
            let albumPrompt = "album".addPluralSubscript(numberOfAlbums)
            
            let numberOfTracks = theArtist.numberOfTracks
            let trackPrompt = "track".addPluralSubscript(numberOfTracks)
            cell.mainTitle.text = theArtist.artistName
            cell.subtitle.text = "\(numberOfTracks) \(albumPrompt), \(numberOfTracks) \(trackPrompt)"
            
        } else if pageIndex == 2 {
            
            let theAlbum = uniqueAlbums[indexPath.row]
            
            let image = theAlbum.coverImage.imageWithSize(CGSize(width: 80, height: 80))
            cell.imageWidth.constant = 80
            cell.imageHeight.constant = 80
            cell.coverImage.image = image
            cell.loudspeakerImage.hidden = true
            
            let numberOfTracks = theAlbum.numberOfTracks
            let trackPrompt = "track".addPluralSubscript(numberOfTracks)
            
            cell.mainTitle.text = theAlbum.albumTitle
            cell.subtitle.text = "\(numberOfTracks) \(trackPrompt)"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if pageIndex == 0 {
        
            return 60
        }
        else if pageIndex == 1 {
        
            return 100
        }
        else if pageIndex == 2 {
            return 100
        }
        //will never get here
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if pageIndex == 0 {
            
            MusicManager.sharedInstance.setPlayerQueue(uniqueSongs)
            MusicManager.sharedInstance.setIndexInTheQueue(indexPath.row)
  
            let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
            songVC.selectedFromTable = true
            
            songVC.transitioningDelegate = self.animator
            self.animator!.attachToViewController(songVC)
            songVC.musicViewController = self //for goToArtist and goToAlbum from here
            songVC.nowView = self.nowView
             //reload table to show loudspeaker icon on current selected row
            tableView.reloadData()
            self.presentViewController(songVC, animated: true, completion: nil)
        }
        else if pageIndex == 1 {

            let artistVC = self.storyboard?.instantiateViewControllerWithIdentifier("artistviewstoryboard") as! ArtistViewController
            artistVC.musicViewController = self
            artistVC.nowView = self.nowView
            artistVC.theArtist = uniqueArtists[indexPath.row]
            
            self.showViewController(artistVC, sender: self)
            
        }
        else if pageIndex == 2 {
            
            let albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("albumviewstoryboard") as! AlbumViewController
            albumVC.musicViewController = self
            albumVC.nowView = self.nowView
            albumVC.theAlbum = uniqueAlbums[indexPath.row]
            self.showViewController(albumVC, sender: self)
            
        }
        self.musicTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: called from SongViewController action sheets
    func goToArtist(theArtist: String) {
        print("we want to go to \(theArtist)")
        for artist in MusicManager.sharedInstance.uniqueArtists {
            if theArtist == artist.artistName {
                let artistVC = self.storyboard?.instantiateViewControllerWithIdentifier("artistviewstoryboard") as! ArtistViewController
                artistVC.musicViewController = self
                artistVC.nowView = self.nowView
                artistVC.theArtist = artist
                self.showViewController(artistVC, sender: self)
                print("jumping to artist \(theArtist)")
                break
            }
        }
    }
    
    func goToAlbum(theAlbum: String) {
        for album in MusicManager.sharedInstance.uniqueAlbums {
            if theAlbum == album.albumTitle {
                let albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("albumviewstoryboard") as! AlbumViewController
                albumVC.musicViewController = self
                albumVC.nowView = self.nowView
                albumVC.theAlbum = album
                self.showViewController(albumVC, sender: self)
                print("jumping to album \(theAlbum)")
                break
            }
        }
    }
}