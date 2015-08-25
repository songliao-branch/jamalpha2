import UIKit
import MediaPlayer

class MusicViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    var uniqueSongs :[MPMediaItem]!
    
    var player:MPMusicPlayerController!
    var createdNewPage:Bool = true
    
    //not used hello
    var uniqueArtists:[MPMediaItem]!
    
    var theAlbums = [Album]()
    var theArtists = [Artist]()
    
    var pageIndex = 0
    
    @IBOutlet weak var musicTable: UITableView!
    
    var hello:[String]!
    var tableOriginY:CGFloat = 0
    
    //for transition view animator
    var animator: CustomTransitionAnimation?
    var nowView: VisualizerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocalSongs()
        loadLocalAlbums()
        loadLocalArtist()
        createTransitionAnimation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //println("First song is \(uniqueSongs[0].title)")
        
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
            return theArtists.count
        }
        else
        {
            return theAlbums.count
        }
    }
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("musiccell", forIndexPath: indexPath) as! MusicCell

        if pageIndex == 0 {
            let image = uniqueSongs[indexPath.row].artwork.imageWithSize(CGSize(width: 54, height: 54))
            
            cell.coverImage.image = image
            
            cell.mainTitle.text = uniqueSongs[indexPath.row].title
            cell.subtitle.text = uniqueSongs[indexPath.row].artist
            
        } else if pageIndex == 1  {
            
            let image = theArtists[indexPath.row].getAlbums()[0].coverImage.imageWithSize(CGSize(width: 80, height: 80))
            
            cell.imageWidth.constant = 80
            cell.imageHeight.constant = 80
            
            cell.coverImage.image = image
            
            cell.mainTitle.text = theArtists[indexPath.row].artistName
            
            var endingAlbumString = ""

            if theArtists[indexPath.row].getAlbums().count == 1 {
                endingAlbumString = "album"
            }
            else {
                endingAlbumString = "albums"
            }
            
            var endingTracksString = ""
            
            if theArtists[indexPath.row].numberOfTracks == 1 {
                endingTracksString = "track"
            }
            else {
                endingTracksString = "tracks"
            }
            
            cell.subtitle.text = "\(theArtists[indexPath.row].getAlbums().count) \(endingAlbumString),  \(theArtists[indexPath.row].numberOfTracks) \(endingTracksString)"
            
        } else if pageIndex == 2 {
            
            let image = theAlbums[indexPath.row].coverImage.imageWithSize(CGSize(width: 80, height: 80))
            
            cell.imageWidth.constant = 80
            cell.imageHeight.constant = 80
            cell.coverImage.image = image
            
            var endingTracksString = ""
            
            if theAlbums[indexPath.row].numberOfTracks == 1 {
                endingTracksString = "track"
            }
            else {
                endingTracksString = "tracks"
            }

            cell.mainTitle.text = theAlbums[indexPath.row].albumTitle
            cell.subtitle.text = "\(theAlbums[indexPath.row].numberOfTracks) \(endingTracksString)"
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
            setUpSongVC(uniqueSongs,selectedSong: indexPath.row,selectedFromTable: true)
        }
        else if pageIndex == 1 {
          //  println("artist \(indexPath.row) selected")
            let artistVC = self.storyboard?.instantiateViewControllerWithIdentifier("artistviewstoryboard") as! ArtistViewController
        
            artistVC.theArtist = theArtists[indexPath.row]
            artistVC.player = self.player
            artistVC.musicViewController = self
            
            self.showViewController(artistVC, sender: self)
            
        }
        else if pageIndex == 2 {
            
            let albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("albumviewstoryboard") as! AlbumViewController
      
            albumVC.theAlbum = theAlbums[indexPath.row]
            albumVC.player = self.player
            albumVC.musicViewController = self
            
            self.showViewController(albumVC, sender: self)
            
        }
        self.musicTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    func loadLocalSongs(){
        var songCollection = MPMediaQuery.songsQuery()
        uniqueSongs = (songCollection.items as! [MPMediaItem]).filter({song in song.playbackDuration > 30 })
    }
    func loadLocalAlbums(){
        //start new albums fresh
        var uniqueAlbums = [MPMediaItem]()
        var albumQuery = MPMediaQuery()
        albumQuery.groupingType = MPMediaGrouping.Album;
        for album in albumQuery.collections{
            var representativeItem = album.representativeItem as MPMediaItem
            
            //there is no song shorter than 30 seconds
            if representativeItem.playbackDuration < 30 { continue }
            
            uniqueAlbums.append(representativeItem)
            var thisAlbum = Album(theItem: representativeItem)
            theAlbums.append(thisAlbum)
        }
    }
    
    //load artist must be called after getting all albums
    func loadLocalArtist(){
        uniqueArtists = [MPMediaItem]()
        var artistQuery = MPMediaQuery()
        artistQuery.groupingType = MPMediaGrouping.Artist
        for artist in artistQuery.collections {
            var representativeItem = artist.representativeItem as MPMediaItem
            if representativeItem.playbackDuration < 30 { continue }
            uniqueArtists.append(representativeItem)
            
            var artist = Artist(artist: representativeItem.artist)
            
            theAlbums.sort({ album1, album2 in
                if let album1date = album1.releasedDate, let album2date = album2.releasedDate {
                    return album1date.isGreaterThanDate(album2date)
                } else {
                    return false
                }
            })
            
            for album in theAlbums {
                if representativeItem.artistPersistentID == album.artistPersistantId {
                    artist.addAlbum(album)
                }
            }
            theArtists.append(artist)
        }
    }
    
    func setCollectionToPlayer(){
            //but we are playing an item with a selected index for example index 2,i.e. item:C
            var collection: MPMediaItemCollection!
            collection = MPMediaItemCollection(items: uniqueSongs)
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