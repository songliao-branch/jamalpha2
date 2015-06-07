

// Display all songs in all albums of a particular artist
// each section is an album


import UIKit
import MediaPlayer
class ArtistViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UISearchResultsUpdating {
    
    
    var musicPlayer:MPMusicPlayerController!
    
    
    @IBOutlet weak var artistTable: UITableView!
   
    var resultSearchController:UISearchController!
    
    var ed:Artist!
    
    var filterdAlbums = [Album]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false//align tableview to top
        loadArtistData()
        setUpSearchBar()
        self.artistTable.reloadData()
        
    }
    
    
    func loadArtistData(){
        ed = MusicAPI.sharedIntance.getArtist()[0]
    }
    
    func setUpSearchBar(){
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = true;
        //self.searchController.searchBar.delegate = self
        self.resultSearchController.searchBar.sizeToFit()
        //        self.searchController.searchBar.barStyle = UIBarStyle.
        //        self.searchController.searchBar.barTintColor = UIColor.whiteColor()
        //        self.searchController.searchBar.backgroundColor = UIColor.clearColor()
        self.artistTable.tableHeaderView = resultSearchController.searchBar

    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.resultSearchController.active{
             return self.filterdAlbums.count
        } else{
            return ed.albums.count
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.resultSearchController.active {
            return self.filterdAlbums[section].name
        }else{
            return ed.albums[section].name
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active {
            return self.filterdAlbums[section].songs.count
        }
        else {
         return ed.albums[section].songs.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        let title:String
        
        if self.resultSearchController.active {
            title = filterdAlbums[indexPath.section].songs[indexPath.row].title
        }
        else{
            title = ed.albums[indexPath.section].songs[indexPath.row].title
        }

        cell.textLabel?.text = title
        
        return cell
    }
    
    // MARK: Search
    func filterSongs(searchText:String)
    {
        self.filterdAlbums = [Album]()
        
        for i in 0...self.ed.albums.count-1{
            var songs = self.ed.albums[i].songs as [Song]
            var tempSongs:[Song]
            tempSongs = songs.filter({(song:Song)->Bool in
                let stringMatch = song.title.lowercaseString.rangeOfString(searchText.lowercaseString)
                return (stringMatch != nil)
            })
            if tempSongs.count > 0 {
                var tempAlbum = Album(name: self.ed.albums[i].name, songs: tempSongs)
                self.filterdAlbums.append(tempAlbum)
            }
        }
    }
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterSongs(searchController.searchBar.text)
        self.artistTable.reloadData()
    }
}
