

// Display all songs in all albums of a particular artist
// each section is an album

//THis is twistjam team saying
//July 7, 2015
import UIKit
import MediaPlayer
class ArtistViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var theArtist:Artist!
    
    @IBOutlet weak var artistTable: UITableView!
   
    //TODO: this search functionality will be used for all the Songs,Artist and Album
    var resultSearchController:UISearchController!
    var filterdAlbums = [Album]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        //setUpSearchBar()
        //self.artistTable.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = mainPinkColor
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
        return 50
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if self.resultSearchController.active {
//            return self.filterdAlbums[section].name
//        }else{
//            return ed.albums[section].name
//        }
        return theArtist.getAlbums()[section].albumTitle
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = theArtist.getAlbums()[indexPath.section].songsIntheAlbum[indexPath.row].title
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        
        songVC.theSong = theArtist.getAlbums()[indexPath.section].songsIntheAlbum[indexPath.row]
        self.showViewController(songVC, sender: self)
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
