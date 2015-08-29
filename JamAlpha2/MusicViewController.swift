import UIKit
import MediaPlayer

class MusicViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    //var uniqueSongs :[MPMediaItem]!
    
    var player:MPMusicPlayerController!
    var createdNewPage:Bool = true
    
   
    private var uniqueSongs = [MPMediaItem]()
    private var uniqueArtists = [Artist]()
    private var uniqueAlbums = [Album]()
    
    var pageIndex = 0
    
    @IBOutlet weak var musicTable: UITableView!
    
    var hello:[String]!
    var tableOriginY:CGFloat = 0
    
    //for transition view animator
    var animator: CustomTransitionAnimation?
    var nowView: VisualizerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uniqueSongs = MusicManager.sharedInstance.uniqueSongs
        uniqueArtists = MusicManager.sharedInstance.uniqueArtists
        uniqueAlbums = MusicManager.sharedInstance.uniqueAlbums
        
        createTransitionAnimation()
    }
    
    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
    func popUpSong(){
        setUpNowSongVC()
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
            
            let image = song.artwork.imageWithSize(CGSize(width: 54, height: 54))
            
            cell.coverImage.image = image
            
            cell.mainTitle.text = song.title
            cell.subtitle.text = song.artist
            
        } else if pageIndex == 1  {
            
            let theArtist = uniqueArtists[indexPath.row]
            
            let image = theArtist.getAlbums()[0].coverImage.imageWithSize(CGSize(width: 80, height: 80))
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
        if  pageIndex == 0 {
            setUpSongVC(SongManager.sharedInstance.getAllMediaItems(), selectedSong: indexPath.row,selectedFromTable: true)
        }
        else if pageIndex == 1 {
          //  println("artist \(indexPath.row) selected")
            let artistVC = self.storyboard?.instantiateViewControllerWithIdentifier("artistviewstoryboard") as! ArtistViewController
        
            artistVC.theArtist = uniqueArtists[indexPath.row]
            artistVC.player = self.player
            artistVC.musicViewController = self
            
            self.showViewController(artistVC, sender: self)
            
        }
        else if pageIndex == 2 {
            
            let albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("albumviewstoryboard") as! AlbumViewController
      
            albumVC.theAlbum = uniqueAlbums[indexPath.row]
            albumVC.player = self.player
            albumVC.musicViewController = self
            
            self.showViewController(albumVC, sender: self)
            
        }
        self.musicTable.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    func setCollectionToPlayer(){
            //but we are playing an item with a selected index for example index 2,i.e. item:C
            var collection: MPMediaItemCollection!
            collection = MPMediaItemCollection(items: SongManager.sharedInstance.getAllMediaItems())
            player.setQueueWithItemCollection(collection)
    }
    
    func setUpSongVC(colloectForSongs:[MPMediaItem],selectedSong:Int, selectedFromTable:Bool){
        if(selectedFromTable){
            if(createdNewPage){
                let repeatMode = player.repeatMode
                let shuffle = player.shuffleMode
                MPMusicPlayerController.systemMusicPlayer().stop()
                player.repeatMode = repeatMode
                player.shuffleMode = shuffle
                createdNewPage = false
            }
            
            if(player.repeatMode == .One && player.shuffleMode == .Off){
                player.repeatMode = .All
                if(player.nowPlayingItem != colloectForSongs[selectedSong]||player.nowPlayingItem == nil){
                    player.nowPlayingItem = colloectForSongs[selectedSong]
                }
                player.repeatMode = .One
            }else{
                if(player.nowPlayingItem != colloectForSongs[selectedSong]||player.nowPlayingItem == nil){
                    player.nowPlayingItem = colloectForSongs[selectedSong]
                }
            }
        }
        
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        songVC.musicViewController = self
        songVC.player = self.player
        songVC.selectedFromTable = selectedFromTable
        
        songVC.transitioningDelegate = self.animator
        self.animator!.attachToViewController(songVC)
        self.presentViewController(songVC, animated: true, completion: nil)
    }
    
    func setUpNowSongVC(){
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        songVC.musicViewController = self
        songVC.player = self.player
        songVC.selectedFromTable = false
        
        songVC.transitioningDelegate = self.animator
        self.animator!.attachToViewController(songVC)
        self.navigationController!.presentViewController(songVC, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
}