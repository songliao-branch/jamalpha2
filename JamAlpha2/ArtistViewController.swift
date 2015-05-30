

// Display all songs in all albums of a particular artist
// each section is an album


import UIKit

class ArtistViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var artistTable: UITableView!
    
    var resultSearchController:UISearchController!
    
    var ed:Artist!
    
    var filterdAlbums = [Album]()
    
    let dictIndex = ["+","X"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false//align tableview to top
        loadArtistData()
        setUpSearchBar()
        self.artistTable.reloadData()
    }
    
    func loadArtistData(){
        let theATeam = Song(title: "The A Team")
        let drunk = Song(title: "Drunk")
        let UNI = Song(title: "UNI")
        let grade8 = Song(title: "Grade8")
        let smallBump = Song(title: "Small Bump")
        let this = Song(title: "This")
        let legoHouse = Song(title:"Lego House")
        let kissMe = Song(title: "Kiss Me")
        let giveMeLove = Song(title: "Give Me Love")
        let songs1 = [theATeam,drunk,UNI,grade8,smallBump,this,legoHouse,kissMe,giveMeLove]
        let plus = Album(name: "+", songs: songs1)
        
        let one = Song(title: "One")
        let mess = Song(title: "mess")
        let sing = Song(title: "Sing")
        let dont = Song(title: "Don't")
        let nina = Song(title: "Nina")
        let photograph = Song(title: "Photograph")
        let bloodstream = Song(title: "Bloodstream")
        let sea = Song(title:"Tenerife Sea")
        let runnaway = Song(title: "Runnaway")
        let theman = Song(title: "The Man")
        let songs2 = [one,mess,sing,dont,nina,photograph,bloodstream,sea,runnaway,theman]
        let multiply = Album(name: "X", songs: songs2)
        
        let albs = [plus,multiply]
        ed = Artist(name: "Ed Sheeran", albums: albs)
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
