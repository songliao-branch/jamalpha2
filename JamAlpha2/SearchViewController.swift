
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
    
    var searchResults = [SearchResult]()
    
    var searchAPI:SearchAPI = SearchAPI()
    var animator: CustomTransitionAnimation?
    
    
    var searchBackgroundIcon = UIImageView()
    var searchBackgroundLabel = UILabel()
    
    var searchHistoryManager =  SearchHistoryManager()

    @IBOutlet weak var searchResultTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        createTransitionAnimation()
        uniqueSongs = MusicManager.sharedInstance.uniqueSongs
        self.automaticallyAdjustsScrollViewInsets = false
        setUpSearchBar()
        setUpSearchPromptBackground()
    }
    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
    
    func setUpSearchPromptBackground() {
        searchBackgroundIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 222, height: 244))
        searchBackgroundIcon.image = UIImage(named: "big_search")
        searchBackgroundIcon.center = CGPoint(x: self.view.center.x, y: self.view.center.y-44-20)
        self.view.addSubview(searchBackgroundIcon)
        
        searchBackgroundLabel = UILabel(frame: CGRect(x: 0, y: CGRectGetMaxY(searchBackgroundIcon.frame)+20, width: 0.7*self.view.frame.width, height: 50))
        searchBackgroundLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 15)
        searchBackgroundLabel.numberOfLines = 0
        searchBackgroundLabel.text = "Find your favorite songs,\n artists, jams here"
        searchBackgroundLabel.textAlignment = .Center
        searchBackgroundLabel.textColor = UIColor.silverGray()
        searchBackgroundLabel.center.x = self.view.center.x
        self.view.addSubview(searchBackgroundLabel)
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
        self.navigationController?.navigationBar.translucent = false
        
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
            if searchResults.count == 0 || !resultSearchController.active {
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
            view.backgroundColor = UIColor.backgroundGray()
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
            view.backgroundColor = UIColor.backgroundGray()
            
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
            searchBackgroundLabel.hidden = true
            searchBackgroundIcon.hidden = true
            if section == 0 {
                tableView.hidden = false
                return filteredSongs.count
            } else if section == 1 {
                tableView.hidden = false
              return searchResults.count
            }
        } else if !resultSearchController.active && section == 0 && searchHistoryManager.getAllHistory().count > 0 {
            searchBackgroundLabel.hidden = true
            searchBackgroundIcon.hidden = true
            tableView.hidden = false
            return searchHistoryManager.getAllHistory().count + 1 // 1 for clear recent searches
        }
        
        searchBackgroundLabel.hidden = false
        searchBackgroundIcon.hidden = false
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
                if(song.artist != nil){
                    cell.subtitleLabel.text = song.artist!
                }else{
                    cell.subtitleLabel.text = "Unknow"
                }
                if let artwork = song.artwork {
                    cell.albumCover.image = artwork.imageWithSize(CGSize(width: 54, height: 54))
                }else{
                    cell.albumCover.image = UIImage(named: "liweng")
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
                    let url = NSURL(string: imageURL)!
                    let fetcher = NetworkFetcher<UIImage>(URL: url)
                    
                    let cache = Shared.imageCache
                    cache.fetch(fetcher: fetcher).onSuccess { image in
                        cell.albumCover.image = image
                        
                        if(indexPath.row < (self.searchResults.count)){
                            self.searchResults[indexPath.row].image = nil
                            self.searchResults[indexPath.row].image = image //used to pass to songviewcontroller
                        }
                    }
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
                var isSeekingPlayerState = true
                songVC.selectedFromTable = true
                songVC.selectedFromSearchTab = true
                
                MusicManager.sharedInstance.setPlayerQueue(filteredSongs)
                MusicManager.sharedInstance.setIndexInTheQueue(indexPath.row)
                
                if((filteredSongs[indexPath.row]).cloudItem && NetworkManager.sharedInstance.reachability.isReachableViaWWAN()) {
                    dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))) {
                        while (isSeekingPlayerState) {
                            if(MusicManager.sharedInstance.player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex){
                                MusicManager.sharedInstance.player.stop()
                                KGLOBAL_nowView.stop()
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.showCellularEnablesStreaming(tableView)
                                }
                                isSeekingPlayerState = false
                                
                                break
                            }
                            
                            if(MusicManager.sharedInstance.player.indexOfNowPlayingItem == MusicManager.sharedInstance.lastSelectedIndex && MusicManager.sharedInstance.player.playbackState != .SeekingForward){
                                if(MusicManager.sharedInstance.player.nowPlayingItem != nil){
                                    dispatch_async(dispatch_get_main_queue()) {
                                        songVC.selectedFromTable = true
                                        songVC.transitioningDelegate = self.animator
                                        self.animator!.attachToViewController(songVC)

                                        self.presentViewController(songVC, animated: true, completion: {
                                            completed in
                                            //reload table to show loudspeaker icon on current selected row
                                            self.reloadMusicTable(true)
                                        })
                                    }
                                    isSeekingPlayerState = false
                                    break
                                }
                            }
                        }
                    }
                }else if (NetworkManager.sharedInstance.reachability.isReachableViaWiFi() || !filteredSongs[indexPath.row].cloudItem){
                    isSeekingPlayerState = false
                    if(MusicManager.sharedInstance.player.nowPlayingItem == nil){
                        MusicManager.sharedInstance.player.play()
                    }
                    
                    songVC.selectedFromTable = true
                    songVC.transitioningDelegate = self.animator
                    self.animator!.attachToViewController(songVC)
                    self.presentViewController(songVC, animated: true, completion: {
                        completed in
                        //reload table to show loudspeaker icon on current selected row
                        self.reloadMusicTable(true)
                    })
                } else if ( !NetworkManager.sharedInstance.reachability.isReachable() && filteredSongs[indexPath.row].cloudItem) {
                    isSeekingPlayerState = false
                    MusicManager.sharedInstance.player.stop()
                    KGLOBAL_nowView.stop()
                    self.showConnectInternet(tableView)
                }
                
                
            }else {
                let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
                var isSeekingPlayerState = true
                songVC.selectedFromTable = true
                let searchSong = searchResults[indexPath.row]
                var isReload = true
                
                if let foundItem = MusicManager.sharedInstance.isNeedReloadCollections(searchSong.trackName!, artist: searchSong.artistName!, duration: searchSong.trackTimeMillis!){
                    MusicManager.sharedInstance.setPlayerQueue([foundItem])
                    MusicManager.sharedInstance.setIndexInTheQueue(0)
                    if(foundItem.cloudItem && NetworkManager.sharedInstance.reachability.isReachableViaWWAN()) {
                        dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))) {
                            while (isSeekingPlayerState) {
                                if(MusicManager.sharedInstance.player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex){
                                    MusicManager.sharedInstance.player.stop()
                                    KGLOBAL_nowView.stop()
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.showCellularEnablesStreaming(tableView)
                                    }
                                    isSeekingPlayerState = false
                                    
                                    break
                                }
                                
                                if(MusicManager.sharedInstance.player.indexOfNowPlayingItem == MusicManager.sharedInstance.lastSelectedIndex && MusicManager.sharedInstance.player.playbackState != .SeekingForward){
                                    if(MusicManager.sharedInstance.player.nowPlayingItem != nil){
                                        dispatch_async(dispatch_get_main_queue()) {
                                            songVC.selectedFromTable = true
                                            songVC.transitioningDelegate = self.animator
                                            self.animator!.attachToViewController(songVC)
                                            
                                            self.presentViewController(songVC, animated: true, completion: {
                                                completed in
                                                //reload table to show loudspeaker icon on current selected row
                                                self.reloadMusicTable(true)
                                            })
                                        }
                                        isSeekingPlayerState = false
                                        break
                                    }
                                }
                            }
                        }
                    } else if (NetworkManager.sharedInstance.reachability.isReachableViaWiFi() || !foundItem.cloudItem){
                        isSeekingPlayerState = false
                        if(MusicManager.sharedInstance.player.nowPlayingItem == nil){
                            MusicManager.sharedInstance.player.play()
                        }
                        
                        songVC.selectedFromTable = true
                        songVC.transitioningDelegate = self.animator
                        self.animator!.attachToViewController(songVC)
                        self.presentViewController(songVC, animated: true, completion: {
                            completed in
                            //reload table to show loudspeaker icon on current selected row
                            self.reloadMusicTable(true)
                        })
                    } else if ( !NetworkManager.sharedInstance.reachability.isReachable() && foundItem.cloudItem) {
                        isSeekingPlayerState = false
                        MusicManager.sharedInstance.player.stop()
                        KGLOBAL_nowView.stop()
                        self.showConnectInternet(tableView)
                    }
                }else{
                    isSeekingPlayerState = false
                    songVC.isSongNeedPurchase = true
                    songVC.songNeedPurchase = searchResults[indexPath.row]
                    if let img = searchResults[indexPath.row].image {
                        songVC.backgroundImage = img
                        songVC.blurredImage = img.applyLightEffect()
                    }
                    isReload = false
                    songVC.selectedFromSearchTab = true
                    songVC.transitioningDelegate = self.animator
                    self.animator!.attachToViewController(songVC)
                    self.presentViewController(songVC, animated: true, completion: {
                        completed in
                        self.reloadMusicTable(isReload)
                    })
                }
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            
            searchHistoryManager.addNewHistory(resultSearchController.searchBar.text!)
            
        } else if !resultSearchController.active { //&& indexPath.section == 0 {
            
             // select in search history
            if indexPath.row == searchHistoryManager.getAllHistory().count {
                searchHistoryManager.clearHistory()
                tableView.reloadData()
            } else {
            
                let historySearchTerm = searchHistoryManager.getAllHistory().reverse()[indexPath.row].term
                resultSearchController.searchBar.text = historySearchTerm
                resultSearchController.searchBar.becomeFirstResponder()
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
        self.searchResultTableView.reloadData()
        SearchAPI.searchSong(searchController.searchBar.text!, completion: {
            results in
            
            self.searchResults = results
            
            dispatch_async(dispatch_get_main_queue()) {
                self.searchResultTableView.reloadData()
            }
        })
    }
    
    
    func filterLocalSongs(searchText: String) {
        self.filteredSongs = uniqueSongs.filter({
            (song: MPMediaItem) -> Bool in
            if(song.albumArtist != nil){
               return song.title!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || song.albumArtist!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
            }else{
                return song.title!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil 
            }
            
        })
        self.searchResultTableView.reloadData()
    }

    // MARK: to refresh now playing loudspeaker icon in musicviewcontroller
    func reloadMusicTable(needStart:Bool){
        let baseVC:BaseViewController = (self.tabBarController?.childViewControllers[0].childViewControllers[0]) as! BaseViewController
        for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
            musicVC.musicTable.reloadData()
        }
    }
    
}


