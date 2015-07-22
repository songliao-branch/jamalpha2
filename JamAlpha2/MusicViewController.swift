import UIKit
import MediaPlayer

class MusicViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    var uniqueSongs :[MPMediaItem]!
    
    //not used
    var uniqueArtists:[MPMediaItem]!
    
    var theAlbums = [Album]()
    var theArtists = [Artist]()
    
    var pageIndex = 0
    
    @IBOutlet weak var musicTable: UITableView!
    
    var hello:[String]!
    var tableOriginY:CGFloat = 0
    
    //for transition view animator
    var animator:CustomTransitionAnimation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTransitionAnimation()
        loadLocalSongs()
        loadLocalAlbums()
        loadLocalArtist()
    }
    
    func createTransitionAnimation(){
        if(animator == nil){
            println("animator created")
            self.animator = CustomTransitionAnimation()
        }
    }
    
    var lastSelectedIndex = 0
    func popUpSong(){
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailviewstoryboard") as! DetailViewController
        detailVC.theSong = uniqueSongs[lastSelectedIndex]
        detailVC.transitioningDelegate = self.animator
        self.animator!.attachToViewController(detailVC)
        self.presentViewController(detailVC, animated: true, completion: nil)
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
            
           // cell.imageView?.frame = CGRectMake(10, 10, 55, 55)
            
            //cell.imageView?.image = Toucan(image: image).maskWithRoundedRect(cornerRadius: 2).image
            cell.coverImage.image = image
            
            cell.mainTitle.text = uniqueSongs[indexPath.row].title
            cell.subtitle.text = uniqueSongs[indexPath.row].artist
        } else if pageIndex == 1  {
            
            cell.mainTitle.font = UIFont(name: cell.mainTitle.font.fontName, size: 20)
            
            let image = theArtists[indexPath.row].getAlbums()[0].coverImage.imageWithSize(CGSize(width: 80, height: 80))
            //this causes lagging when scrolling
            //let roundImage = Toucan(image: image).maskWithEllipse().image
            
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
            
//            let rectImage = Toucan(image: image).maskWithRoundedRect(cornerRadius: 30).image
            cell.coverImage.image = image
            
            var endingTracksString = ""
            
            if theAlbums[indexPath.row].numberOfTracks == 1 {
                endingTracksString = "track"
            }
            else {
                endingTracksString = "tracks"
            }
            
            cell.mainTitle.font = UIFont(name: cell.mainTitle.font.fontName, size: 20)
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
            
            //Check if we are going back to the song we just played
            //If so, save the state
            lastSelectedIndex = indexPath.row
            
            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailviewstoryboard") as! DetailViewController
            detailVC.theSong = uniqueSongs[indexPath.row]
            detailVC.transitioningDelegate = self.animator
            self.animator!.attachToViewController(detailVC)
            self.presentViewController(detailVC, animated: true, completion: nil)
            
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