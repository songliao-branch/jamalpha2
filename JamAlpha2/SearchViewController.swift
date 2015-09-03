
//TODO: implement Search results in tableview with sections with sources from Spotify API
import UIKit
import MediaPlayer
import Alamofire

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    var resultSearchController = UISearchController()
    
    var uniqueSongs: [MPMediaItem] = [MPMediaItem]()
    var filteredSongs: [MPMediaItem] = [MPMediaItem]()
    
    var searchResults: [SearchResult]!
    
    @IBOutlet weak var searchResultTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResults = [SearchResult]()
        loadLocalSongs()
        setUpLocalSearchBar()
    }
    

    func setUpLocalSearchBar(){
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        self.searchResultTableView.tableHeaderView = self.resultSearchController.searchBar
        
        let searchBar = resultSearchController.searchBar
        
        searchBar.translucent = true
       // searchBar.backgroundImage = UIImage(named: "KP_bg")
        searchBar.tintColor = UIColor.mainPinkColor()
        searchBar.placeholder = "What do you want to play?"
        
    }
    
    func loadLocalSongs(){
        var songCollection = MPMediaQuery.songsQuery()
        uniqueSongs = (songCollection.items as! [MPMediaItem]).filter({song in song.playbackDuration > 30 })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.active {
            return searchResults.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! LocalSearchResultCell
        
        if resultSearchController.active {
            
            if let track = searchResults[indexPath.row].trackName {
                cell.titleLabel.text = track
            }
            if let artist = searchResults[indexPath.row].artistName {
                cell.subtitleLabel.text = artist
            }
            
            if let imageURL = searchResults[indexPath.row].artworkUrl100 {
                cell.request?.cancel()
                cell.albumCover.image = nil
                
                cell.request = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
                    (request, _, image, error) in
                    
                    if error == nil && image != nil {
                        cell.albumCover.image = image
                    } else {
                        println("download image error \(error)")
                    }
                }
            }
            
        }
        return cell
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        resultSearchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchSong(searchController.searchBar.text)
    }
    
    var musicRequest: Request?
    
    func searchSong(searchText: String) {
        musicRequest?.cancel()
        musicRequest = Alamofire.request(API.Router.Term(searchText)).responseJSON() {
            (_, _, data, error) in
            if error == nil {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                     self.addDataToResults(JSON(data!))
                }
            }
        }
    }
    
    func addDataToResults(data: JSON){
        searchResults = [SearchResult]()
        for item in data["results"].array! {
            
            let searchResponse = SearchResult(wrapperType: item["wrapperType"].string!, kind: item["kind"].string!)
            
            if let trackName = item["trackName"].string {
                searchResponse.trackName = trackName
            }
            if let artistName = item["artistName"].string {
                searchResponse.artistName = artistName
            }
            if let collectionName = item["collectionName"].string {
                searchResponse.collectionName = collectionName
            }
            if let artwork = item["artworkUrl100"].string {
                searchResponse.artworkUrl100 = artwork
            }
            if let preview = item["previewUrl"].string {
                searchResponse.previewUrl = preview
            }
            searchResults!.append(searchResponse)
        }

        dispatch_async(dispatch_get_main_queue()) {
            self.searchResultTableView.reloadData()
        }
    }
    
    func filterSongs(searchText: String) {

        self.filteredSongs = uniqueSongs.filter({
            (song: MPMediaItem) -> Bool in
            return song.title.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || song.albumArtist.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || song.albumTitle.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
        
    }
}

