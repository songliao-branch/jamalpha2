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
        
        //println(API.Router.Term("edsheeran").URLRequest.URLString)
        //println(API.Router.TermAttribute("michael jackson", Attribute.artistTerm).URLRequest.URLString)
        
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
                println("\(player.nowPlayingItem.title) is repeating")
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
        songVC.musicViewController = self
        songVC.selectedFromTable = false
        
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
            
            let image = song.artwork.imageWithSize(CGSize(width: 54, height: 54))
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
            songVC.musicViewController = self
            songVC.selectedFromTable = true
            
            songVC.transitioningDelegate = self.animator
            self.animator!.attachToViewController(songVC)
            
             //reload table to show loudspeaker icon on current selected row
            tableView.reloadData()
            self.presentViewController(songVC, animated: true, completion: nil)
        }
        else if pageIndex == 1 {

            var artistVC = self.storyboard?.instantiateViewControllerWithIdentifier("artistviewstoryboard") as! ArtistViewController
        
            artistVC.theArtist = uniqueArtists[indexPath.row]
            artistVC.musicViewController = self
            
            self.showViewController(artistVC, sender: self)
            
        }
        else if pageIndex == 2 {
            
            var albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("albumviewstoryboard") as! AlbumViewController
            
            albumVC.theAlbum = uniqueAlbums[indexPath.row]
            albumVC.musicViewController = self
            self.showViewController(albumVC, sender: self)
            
        }
        self.musicTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
   }