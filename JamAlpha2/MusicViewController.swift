import UIKit
import MediaPlayer

class MusicViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
//    enum MUSIC_SELECTION_TYPE: Int {
//        case TRACKS = 0
//        case ARTIST = 1
//        case ALBUM = 2
//    }

    var uniqueSongs :[MPMediaItem]!
    
    //not used
    var uniqueArtists:[MPMediaItem]!
    
    var theAlbums = [Album]()
    var theArtists = [Artist]()
    
    var pageIndex = 0
    
    @IBOutlet weak var musicTable: UITableView!
    
//    @IBOutlet weak var musicTypeSegment: UISegmentedControl!
//                            
//    @IBAction func musicSelectionChanged(sender: UISegmentedControl) {
//        musicTable.reloadData()
//    }
    
    var hello:[String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        loadLocalSongs()
        loadLocalAlbums()
        loadLocalArtist()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.TRACKS.rawValue {
//            return uniqueSongs.count
//        }else if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ARTIST.rawValue{
//            return theArtists.count
//        }
//        else
//        {
//            return theAlbums.count
//        }
//        
                if pageIndex == 0  {
                    return uniqueSongs.count
                }else if pageIndex == 1 {
                    return theArtists.count
                }
                else
                {
                    return theAlbums.count
                }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("musiccell", forIndexPath: indexPath) as! MusicCell
//        
//        if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.TRACKS.rawValue {
//            cell.titleLabel.text = uniqueSongs[indexPath.row].title
//            cell.subtitleLabel.text = uniqueSongs[indexPath.row].artist
//        } else if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ARTIST.rawValue {
//            cell.titleLabel.text = theArtists[indexPath.row].artistName
//            cell.subtitleLabel.text = "\(theArtists[indexPath.row].numberOfTracks) tracks"
//        } else if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ALBUM.rawValue {
//            cell.titleLabel.text = theAlbums[indexPath.row].albumTitle
//            cell.subtitleLabel.text = "\(theAlbums[indexPath.row].numberOfTracks) tracks"
//        }
        
        if pageIndex == 0 {
            cell.titleLabel.text = uniqueSongs[indexPath.row].title
            cell.subtitleLabel.text = uniqueSongs[indexPath.row].artist
        } else if pageIndex == 1  {
            cell.titleLabel.text = theArtists[indexPath.row].artistName
            cell.subtitleLabel.text = "\(theArtists[indexPath.row].numberOfTracks) tracks"
        } else if pageIndex == 2 {
            cell.titleLabel.text = theAlbums[indexPath.row].albumTitle
            cell.subtitleLabel.text = "\(theAlbums[indexPath.row].numberOfTracks) tracks"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if  pageIndex == 0 {
           // println("song \(indexPath.row) selected")
            
            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailviewstoryboard") as! DetailViewController
            detailVC.theSong = uniqueSongs[indexPath.row]
            self.showViewController(detailVC, sender: self)
            
        }
        else if pageIndex == 1 {
          //  println("artist \(indexPath.row) selected")
            let artistVC = self.storyboard?.instantiateViewControllerWithIdentifier("artistviewstoryboard") as! ArtistViewController
            
            artistVC.theArtist = theArtists[indexPath.row]
            
            self.showViewController(artistVC, sender: self)
            
        }
        else if pageIndex == 2 {
            
            let albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("albumviewstoryboard") as! AlbumViewController
      
            albumVC.theAlbum = theAlbums[indexPath.row]
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
            for album in theAlbums {
                if representativeItem.artistPersistentID == album.artistPersistantId {
                    artist.addAlbum(album)
                }
            }
            theArtists.append(artist)
        }
    }
}