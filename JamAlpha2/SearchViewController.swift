
//TODO: implement Search results in tableview with sections with sources from Spotify API
import UIKit
import MediaPlayer
import Alamofire
import Haneke
import SwiftyJSON

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    var resultSearchController = UISearchController()
    
    var uniqueSongs: [MPMediaItem] = [MPMediaItem]()
    var filteredSongs: [MPMediaItem] = [MPMediaItem]()
    
    var searchResults: [SearchResult]!
    var musicRequest: Request?
    var animator: CustomTransitionAnimation?
    
    var searchHistoryManager =  SearchHistoryManager()

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
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        
        navigationItem.titleView = searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        definesPresentationContext = true
        
        
        if let searchTextField = searchBar.valueForKey("searchField") as? UITextField {
            
            searchTextField.textAlignment = NSTextAlignment.Left
            searchTextField.tintColor = UIColor.mainPinkColor()
            
            for view in searchTextField.subviews {
                //set inner text area background to white
                view.layer.backgroundColor = UIColor.whiteColor().CGColor
                view.layer.cornerRadius = 5
            }
        }
        
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if resultSearchController.active {
            return 70
        } else if !resultSearchController.active && indexPath.section == 0 {
            return 44
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
                tableView.hidden = false
                return filteredSongs.count
            } else if section == 1 {
                tableView.hidden = false
              return searchResults.count
            }
        } else if !resultSearchController.active && section == 0 && searchHistoryManager.getAllHistory().count > 0 {
            tableView.hidden = false
            return searchHistoryManager.getAllHistory().count + 1 // 1 for clear recent searches
        }
        tableView.hidden = true
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchresultcell", forIndexPath: indexPath) as! SearchResultCell
        
        if resultSearchController.active {
            cell.searchHistoryLabel.hidden = true
            cell.titleLabel.hidden = false
            cell.subtitleLabel.hidden = false
            if indexPath.section == 0 { //local search in section 0
                let song = filteredSongs[indexPath.row]
                cell.titleLabel.text = song.title!
                cell.subtitleLabel.text = song.artist!
                if let artwork = song.artwork {
                    cell.albumCover.image = artwork.imageWithSize(CGSize(width: 54, height: 54))
                }
            } else { //web search in section 1
                if let track = searchResults[indexPath.row].trackName {
                    cell.titleLabel.text = track
                }
                if let artist = searchResults[indexPath.row].artistName {
                    cell.subtitleLabel.text = artist
                }
                
                if let imageURL = searchResults[indexPath.row].artworkUrl100 {
                    cell.albumCover.image = nil
                    cell.albumCover.hnk_setImageFromURL(NSURL(string: imageURL)!)
                }
            
            }
        } else if !resultSearchController.active && indexPath.section == 0 {//if search is inactive
            // array of search history comes in time ascending order, we need descending order (newest on top)
            cell.titleLabel.hidden = true
            cell.subtitleLabel.hidden = true
            cell.searchHistoryLabel.hidden = false
            cell.albumCover.image = nil
            
            if indexPath.row < searchHistoryManager.getAllHistory().count {
                let searchHistory = Array(searchHistoryManager.getAllHistory().reverse())[indexPath.row]
                cell.searchHistoryLabel.text = searchHistory.term

            } else {
                cell.searchHistoryLabel.text = "Clear recent searches"
            }
            
        
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if resultSearchController.active {
            
            if indexPath.section == 0 {
                
                let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
                
                songVC.selectedFromTable = true
                
                MusicManager.sharedInstance.setPlayerQueue(filteredSongs)
                MusicManager.sharedInstance.setIndexInTheQueue(indexPath.row)
                
                songVC.transitioningDelegate = self.animator
                self.animator!.attachToViewController(songVC)
                reloadMusicTable()
                self.presentViewController(songVC, animated: true, completion: nil)
                
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            
            searchHistoryManager.addNewHistory(resultSearchController.searchBar.text!)
            
            for result in searchHistoryManager.getAllHistory() {
                print("now we have \(result.term)")
            }
            
        } else if !resultSearchController.active && indexPath.section == 0 {
             // select in search history
            if indexPath.row == searchHistoryManager.getAllHistory().count {
                searchHistoryManager.clearHistory()
                tableView.reloadData()
            }
        }

    }
    
    // hide keyboard when scroll table view
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        resultSearchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterLocalSongs(searchController.searchBar.text!)
        webSearchSong(searchController.searchBar.text!)
    }
    

    func webSearchSong(searchText: String) {
        if searchText.characters.count < 1 {
            return
        }
        musicRequest?.cancel()
        searchResults = [SearchResult]()
        self.searchResultTableView.reloadData()
        
        musicRequest = Alamofire.request(.GET, APIManager.searchBaseURL, parameters: APIManager.searchParameters(searchText)).responseJSON { response in
            if let data = response.result.value {
                print("JSON: \(data)")
                self.addDataToResults(JSON(data))
            } else {
                print("something went wrong with search \(response.result.error)")
            }
        }
    }
    
    
    func addDataToResults(data: SwiftyJSON.JSON){
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
            return song.title!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || song.albumArtist!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
        self.searchResultTableView.reloadData()
    }

    // MARK: to refresh now playing loudspeaker icon in musicviewcontroller
    func reloadMusicTable(){
        for tabItemController in (self.tabBarController?.viewControllers)! {
            if tabItemController.isKindOfClass(UINavigationController){
                for childVC in tabItemController.childViewControllers {
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

