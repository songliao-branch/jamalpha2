

// Display all songs in all albums of a particular artist
// each section is an album

//THis is twistjam team saying
//July 7, 2015
import UIKit
import MediaPlayer
class ArtistViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var theArtist:Artist!
    var createdNewPage:Bool = true
    var player:MPMusicPlayerController!
    var musicViewController: MusicViewController?
    var animator: CustomTransitionAnimation?
    var artistAllSongs:[MPMediaItem]!
    
    @IBOutlet weak var artistTable: UITableView!
   
    //TODO: this search functionality will be used for all the Songs,Artist and Album
    var resultSearchController:UISearchController!
    var filterdAlbums = [Album]()

    override func viewDidLoad() {
        super.viewDidLoad()
        artistAllSongs = theArtist.getSongs()
        setCollectionToPlayer()
        self.createTransitionAnimation()
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
    }
    
    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("albumsectioncell") as! AlbumSectionCell
        let image = theArtist.getAlbums()[section].coverImage.imageWithSize(CGSize(width: 85, height: 85))
        cell.albumImageView.image = image
        cell.albumNameLabel.text  = theArtist.getAlbums()[section].albumTitle
        
        if let date = theArtist.getAlbums()[section].releasedDate {
            let comps = NSCalendar.currentCalendar().components(.CalendarUnitYear, fromDate: date)
            cell.albumYearLabel.text = "\(comps.year)"
        } else {
            cell.albumYearLabel.hidden = true
        }
       
        return cell
    }
    

//    func setUpSearchBar(){
//        
//        self.resultSearchController = UISearchController(searchResultsController: nil)
//        self.resultSearchController.searchResultsUpdater = self
//        self.resultSearchController.dimsBackgroundDuringPresentation = true;
//        //self.searchController.searchBar.delegate = self
//        self.resultSearchController.searchBar.sizeToFit()
//        //        self.searchController.searchBar.barStyle = UIBarStyle.
//        //        self.searchController.searchBar.barTintColor = UIColor.whiteColor()
//        //        self.searchController.searchBar.backgroundColor = UIColor.clearColor()
//        self.artistTable.tableHeaderView = resultSearchController.searchBar
//
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        if self.resultSearchController.active{
//             return self.filterdAlbums.count
//        } else{
//            return ed.albums.count
//        }
        return theArtist.getAlbums().count
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if self.resultSearchController.active {
//            return self.filterdAlbums[section].songs.count
//        }
//        else {
//         return ed.albums[section].songs.count
//        }
        return theArtist.getAlbums()[section].numberOfTracks
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("albumtrackcell", forIndexPath: indexPath) as! AlbumTrackCell
        
        let song = theArtist.getAlbums()[indexPath.section].songsIntheAlbum[indexPath.row]
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
        var albumIndex = indexPath.section
        var songsInPreviousSections = 0
        if albumIndex > 0 {
            for i in 1...albumIndex {
               songsInPreviousSections += theArtist.getAlbums()[i-1].numberOfTracks
            }
        }
        var indexToBePlayed = songsInPreviousSections + indexPath.row
       
        
        setUpSongVC(artistAllSongs, selectedSong: indexToBePlayed, selectedFromTable: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func setCollectionToPlayer(){
        var collection: MPMediaItemCollection!
        collection = MPMediaItemCollection(items: artistAllSongs)
        player.setQueueWithItemCollection(collection)
    }
    func setUpSongVC(collection: [MPMediaItem],selectedSong:Int,selectedFromTable:Bool){
        if(selectedFromTable){
            if(createdNewPage){
                println("createdNewPage")
                let repeatMode = player.repeatMode
                let shuffle = player.shuffleMode
                MPMusicPlayerController.systemMusicPlayer().stop()
                player.repeatMode = repeatMode
                player.shuffleMode = shuffle
                createdNewPage = false
            }
            
            if(player.repeatMode == .One && player.shuffleMode == .Off){
                player.repeatMode = .All
                if(player.nowPlayingItem != collection[selectedSong]||player.nowPlayingItem == nil){
                    
                    player.nowPlayingItem = collection[selectedSong]
                }
                player.repeatMode = .One
            }else{
                if(player.nowPlayingItem != collection[selectedSong]||player.nowPlayingItem == nil){
                    player.nowPlayingItem = collection[selectedSong]
                }
            }
        }
        
       
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        songVC.musicViewController = self.musicViewController
        songVC.player = self.player
        songVC.selectedFromTable = selectedFromTable
        
        songVC.transitioningDelegate = self.animator
        self.animator!.attachToViewController(songVC)
        self.presentViewController(songVC, animated: true, completion: nil)
    }

    
    
//    MARK: Search
//    func filterSongs(searchText:String)
//    {
//        self.filterdAlbums = [Album]()
//        
//        for i in 0...self.ed.albums.count-1{
//            var songs = self.ed.albums[i].songs as [Song]
//            var tempSongs:[Song]
//            tempSongs = songs.filter({(song:Song)->Bool in
//                let stringMatch = song.title.lowercaseString.rangeOfString(searchText.lowercaseString)
//                return (stringMatch != nil)
//            })
//            if tempSongs.count > 0 {
//                var tempAlbum = Album(name: self.ed.albums[i].name, songs: tempSongs)
//                self.filterdAlbums.append(tempAlbum)
//            }
//        }
//    }
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        filterSongs(searchController.searchBar.text)
//        self.artistTable.reloadData()
//    }
}
