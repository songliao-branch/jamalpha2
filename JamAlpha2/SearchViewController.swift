
//TODO: implement Search results in tableview with sections with sources from Spotify API
import UIKit
import MediaPlayer

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    var resultSearchController = UISearchController()
    var uniqueSongs: [MPMediaItem] = [MPMediaItem]()
    var filteredSongs: [MPMediaItem] = [MPMediaItem]()
    
    @IBOutlet weak var searchResultTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocalSongs()
        setUpLocalSearchBar()
    }
    
    func setUpLocalSearchBar(){
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        
        self.resultSearchController.dimsBackgroundDuringPresentation = true
        self.resultSearchController.searchBar.sizeToFit()
        self.searchResultTableView.tableHeaderView = self.resultSearchController.searchBar
        
        let searchBar = resultSearchController.searchBar
        searchBar.scopeButtonTitles = ["Cloud Music","Local Music"]
        searchBar.placeholder = "Search your songs, artists albums.."
        
    }
    
    func loadLocalSongs(){
        var songCollection = MPMediaQuery.songsQuery()
        uniqueSongs = (songCollection.items as! [MPMediaItem]).filter({song in song.playbackDuration > 30 })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.active {
            return filteredSongs.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! LocalSearchResultCell
        
        if resultSearchController.active {
            cell.titleLabel.text = filteredSongs[indexPath.row].title
            cell.subtitleLabel.text = filteredSongs[indexPath.row].artist
        }
        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterSongs(searchController.searchBar.text)
        self.searchResultTableView.reloadData()
    }
    
    func filterSongs(searchText: String) {
        //self.filteredSongs = [MPMediaItem]()
        if resultSearchController.searchBar.selectedScopeButtonIndex == 0 {
            //TODO: search cloud music 
            
        }
        else if resultSearchController.searchBar.selectedScopeButtonIndex == 1 {
            self.filteredSongs = uniqueSongs.filter({
                (song: MPMediaItem) -> Bool in
                return song.title.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || song.albumArtist.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || song.albumTitle.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
            })
        }

    }
}

