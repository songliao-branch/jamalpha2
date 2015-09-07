
//TODO: implement Search results in tableview with sections with sources from Spotify API
import UIKit
import MediaPlayer
import Alamofire

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    var resultSearchController = UISearchController()
    
    var uniqueSongs: [MPMediaItem] = [MPMediaItem]()
    var filteredSongs: [MPMediaItem] = [MPMediaItem]()
    
    var searchResults: [SearchResult]!
    var musicRequest: Request?
    var animator: CustomTransitionAnimation!
    
    
    @IBOutlet weak var searchResultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uniqueSongs = MusicManager.sharedInstance.uniqueSongs
        createTransitionAnimation()
        self.automaticallyAdjustsScrollViewInsets = false
        searchResults = [SearchResult]()
        setUpSearchBar()
        
    }
    


    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }

    func setUpSearchBar(){
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.searchResultTableView.tableHeaderView = self.resultSearchController.searchBar
        
        
        let searchBar = resultSearchController.searchBar
        navigationItem.titleView = searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        definesPresentationContext = true
        searchBar.tintColor = UIColor.mainPinkColor()
        searchBar.placeholder = "What do you want to play?"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if filteredSongs.count == 0 {
                return 0
            }
            return 30
        } else if section == 1 {
            if searchResults.count == 0 {
                return 0
            }
            return 30
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if filteredSongs.count == 0 {
                return nil
            }
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
            view.backgroundColor = UIColor.backGray()
            let label = UILabel(frame: CGRectMake(15, 0, self.view.frame.width, 20))
            label.center.y = view.center.y
            label.textColor = UIColor.mainPinkColor()
            label.text = "My Music"
            view.addSubview(label)
            
            return view
            
        } else if section == 1 {
            if searchResults.count == 0 {
                return nil
            }
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
            view.backgroundColor = UIColor.backGray()
            
            let label = UILabel(frame: CGRectMake(15, 0, self.view.frame.width, 20))
            label.center.y = view.center.y
            label.text = "Cloud Music"
            label.textColor = UIColor.mainPinkColor()
            view.addSubview(label)
            return view
        }
        return nil
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.active {
            if section == 0 {
                return filteredSongs.count
            } else if section == 1 {
              return searchResults.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchresultcell", forIndexPath: indexPath) as! SearchResultCell
        
        if resultSearchController.active {
            
            if indexPath.section == 0 { //local search in section 0
                cell.titleLabel.text = filteredSongs[indexPath.row].title
                cell.subtitleLabel.text = filteredSongs[indexPath.row].artist
                cell.albumCover.image = filteredSongs[indexPath.row].artwork.imageWithSize(CGSize(width: 54, height: 54))
                
            } else { //web search in section 1
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
            
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
            let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
            
            songVC.selectedFromTable = true
            
            MusicManager.sharedInstance.setPlayerQueue(filteredSongs)
            MusicManager.sharedInstance.setIndexInTheQueue(indexPath.row)
            
            songVC.transitioningDelegate = self.animator
            self.animator!.attachToViewController(songVC)
            
            self.presentViewController(songVC, animated: true, completion: nil)
            reloadMusicTable()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    // hide keyboard when scroll table view
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        resultSearchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterLocalSongs(searchController.searchBar.text)
        webSearchSong(searchController.searchBar.text)
    }
    

    func webSearchSong(searchText: String) {
        musicRequest?.cancel()
        searchResults = [SearchResult]()
        self.searchResultTableView.reloadData()
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
            if let trackViewUrl = item["trackViewUrl"].string {
                searchResponse.trackViewUrl = trackViewUrl
            }
            searchResults.append(searchResponse)
        }

        dispatch_async(dispatch_get_main_queue()) {
            self.searchResultTableView.reloadData()
        }
    }
    
    func filterLocalSongs(searchText: String) {

        self.filteredSongs = uniqueSongs.filter({
            (song: MPMediaItem) -> Bool in
            return song.title.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || song.albumArtist.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || song.albumTitle.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
        self.searchResultTableView.reloadData()
        
    }
    // MARK: to refresh now playing loudspeaker icon in musicviewcontroller
    func reloadMusicTable(){
        for tabItemController in self.tabBarController?.viewControllers as! [UIViewController]{
            if tabItemController.isKindOfClass(UINavigationController){
                for childVC in tabItemController.childViewControllers as! [UIViewController] {
                    if childVC.isKindOfClass(BaseViewController) {
                        let baseVC = childVC as! BaseViewController
                        for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                            musicVC.musicTable.reloadData()
                        }
                    }
                }
            }
        }
    }
}

