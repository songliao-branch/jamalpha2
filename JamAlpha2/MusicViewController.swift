import UIKit
import MediaPlayer


class MusicViewController: SuspendThreadViewController, UITableViewDataSource, UITableViewDelegate  {

    private var uniqueSongs = [MPMediaItem]()
    private var uniqueArtists = [Artist]()
    private var uniqueAlbums = [Album]()
    
    private var songsByFirstAlphabet = [(String, [MPMediaItem])]()
    private var artistsByFirstAlphabet = [(String, [Artist])]()
    private var albumsByFirstAlphabet = [(String, [Album])]()
    
    private var musicDataManager = MusicDataManager()
    private var rwLock = pthread_rwlock_t()
    
    private var isReloadTable:Bool = false
    
    
    var pageIndex = 0
    
    @IBOutlet weak var musicTable: UITableView!
    

    var nowView: VisualizerView!
    
    private  var songCount: Int64 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        pthread_rwlock_init(&rwLock, nil)
        
        uniqueSongs = MusicManager.sharedInstance.uniqueSongs
        uniqueArtists = MusicManager.sharedInstance.uniqueArtists
        uniqueAlbums = MusicManager.sharedInstance.uniqueAlbums
        
        songsByFirstAlphabet = sort(uniqueSongs)
        artistsByFirstAlphabet = sort(uniqueArtists)
        albumsByFirstAlphabet = sort(uniqueAlbums)

        registerMusicPlayerNotificationForSongChanged()
        UITableView.appearance().sectionIndexColor = UIColor.mainPinkColor()
        
        if(!KEY_isSoundWaveFormInBackgroundChecked){
            generateWaveFormInBackEnd(uniqueSongs[Int(songCount)])
            KEY_isSoundWaveFormInBackgroundChecked = true
        }
        
        SongViewController.sharedInstance.musicViewController = self
        SongViewController.sharedInstance.nowView = self.nowView
    }
    
    deinit{
        pthread_rwlock_destroy(&rwLock)
    }

    func registerMusicPlayerNotificationForSongChanged(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("currentSongChanged:"), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: MusicManager.sharedInstance.player)
    }
    
    func synced(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    func currentSongChanged(notification: NSNotification){
        synced(self) {
            let player = MusicManager.sharedInstance.player
            if player.repeatMode == .One {
                print("\(player.nowPlayingItem!.title) is repeating")
                return
            }
            
            if player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex {
                self.musicTable.reloadData()
            }
        }
    }

    
    func popToCurrentSong(){

        SongViewController.sharedInstance.reloadSongVC(selectedFromTable: false)
        self.navigationController!.presentViewController(SongViewController.sharedInstance, animated: true, completion: nil)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if pageIndex == 0  {
            return songsByFirstAlphabet.count
        }
        else if pageIndex == 1 {
            return artistsByFirstAlphabet.count
        }
        else {
            return albumsByFirstAlphabet.count
        }
    }
    
    // populate the index titles on the right side of screen
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var titles = [String]()
        if pageIndex == 0 {
            for (firstAlphabet, _) in songsByFirstAlphabet {
                titles.append(firstAlphabet)
            }
            return titles
        } else if pageIndex == 1 {
            for (firstAlphabet, _) in artistsByFirstAlphabet {
                titles.append(firstAlphabet)
            }
            return titles
        } else {
            for (firstAlphabet, _) in albumsByFirstAlphabet {
                titles.append(firstAlphabet)
            }
            return titles
        }
    }
    
    // scroll to the current section
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if pageIndex == 0 {
            for i in 0..<songsByFirstAlphabet.count {
                if title == songsByFirstAlphabet[i].0 {
                    return i
                }
            }
        } else if pageIndex == 1 {
            for i in 0..<artistsByFirstAlphabet.count {
                if title == artistsByFirstAlphabet[i].0 {
                    return i
                }
            }
        } else {
            for i in 0..<albumsByFirstAlphabet.count {
                if title == albumsByFirstAlphabet[i].0 {
                    return i
                }
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pageIndex == 0  {
            return songsByFirstAlphabet[section].1.count
        }
        else if pageIndex == 1 {
            return artistsByFirstAlphabet[section].1.count
        }
        else
        {
            return albumsByFirstAlphabet[section].1.count
        }
    }
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("musiccell", forIndexPath: indexPath) as! MusicCell

        if pageIndex == 0 {
            
            let song = songsByFirstAlphabet[indexPath.section].1[indexPath.row]
            if MusicManager.sharedInstance.player.nowPlayingItem != nil {
                if song == MusicManager.sharedInstance.player.nowPlayingItem {
                    
                    // TODO: change asset icon to pink
                    cell.loudspeakerImage.hidden = false
                }
                else {
                    cell.loudspeakerImage.hidden = true
                }
            } else {
                cell.loudspeakerImage.hidden = true
            }
            
            let image = song.artwork!.imageWithSize(CGSize(width: 54, height: 54))
            cell.coverImage.image = image
            cell.mainTitle.text = song.title
            cell.subtitle.text = song.artist
            
            
        } else if pageIndex == 1  {
            
            let theArtist = artistsByFirstAlphabet[indexPath.section].1[indexPath.row]
            let image = theArtist.getAlbums()[0].coverImage.imageWithSize(CGSize(width: 80, height: 80))
            cell.loudspeakerImage.hidden = true
            cell.imageWidth.constant = 80
            cell.imageHeight.constant = 80
            cell.coverImage.image = image
            
            
            let numberOfAlbums = theArtist.getAlbums().count
            let albumPrompt = "album".addPluralSubscript(numberOfAlbums)
            
            let numberOfTracks = theArtist.numberOfTracks
            let trackPrompt = "track".addPluralSubscript(numberOfTracks)
            cell.mainTitle.text = theArtist.artistName
            cell.subtitle.text = "\(numberOfTracks) \(albumPrompt), \(numberOfTracks) \(trackPrompt)"
            
        } else if pageIndex == 2 {

            let theAlbum = albumsByFirstAlphabet[indexPath.section].1[indexPath.row]
            let image = theAlbum.coverImage.imageWithSize(CGSize(width: 80, height: 80))
            cell.imageWidth.constant = 80
            cell.imageHeight.constant = 80
            cell.coverImage.image = image
            cell.loudspeakerImage.hidden = true
            
            let numberOfTracks = theAlbum.numberOfTracks
            let trackPrompt = "track".addPluralSubscript(numberOfTracks)
            
            cell.mainTitle.text = theAlbum.albumTitle
            cell.subtitle.text = "\(numberOfTracks) \(trackPrompt)"
        }
        if (!tableView.dragging && !tableView.decelerating) {
            KGLOBAL_init_queue.suspended = false
        }else{
            KGLOBAL_init_queue.suspended = true
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
        if pageIndex == 0 {
            KGLOBAL_init_queue.suspended = true
            
            let allSongsSorted = getAllSortedItems(songsByFirstAlphabet)
            MusicManager.sharedInstance.setPlayerQueue(allSongsSorted)
            
            let indexToBePlayed = findIndexToBePlayed(songsByFirstAlphabet, section: indexPath.section, currentRow: indexPath.row)
            MusicManager.sharedInstance.setIndexInTheQueue(indexToBePlayed)

            SongViewController.sharedInstance.reloadSongVC(selectedFromTable: true)
            
             //reload table to show loudspeaker icon on current selected row
            self.isReloadTable = true
            self.presentViewController(SongViewController.sharedInstance, animated: true, completion: nil)
        }
        else if pageIndex == 1 {

            let allArtistsSorted = getAllSortedItems(artistsByFirstAlphabet)
            let indexToBePlayed = findIndexToBePlayed(artistsByFirstAlphabet, section: indexPath.section, currentRow: indexPath.row)
            let artistVC = self.storyboard?.instantiateViewControllerWithIdentifier("artistviewstoryboard") as! ArtistViewController
            artistVC.theArtist = allArtistsSorted[indexToBePlayed]
            
            self.showViewController(artistVC, sender: self)
            
        }
        else if pageIndex == 2 {
            
            let allAlbumsSorted = getAllSortedItems(albumsByFirstAlphabet)
            let indexToBePlayed = findIndexToBePlayed(albumsByFirstAlphabet, section: indexPath.section, currentRow: indexPath.row)
            
            let albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("albumviewstoryboard") as! AlbumViewController
            albumVC.theAlbum = allAlbumsSorted[indexToBePlayed]
            
            self.showViewController(albumVC, sender: self)
            
        }
        self.musicTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: called from SongViewController action sheets
    func goToArtist(theArtist: String) {
        print("we want to go to \(theArtist)")
        for artist in MusicManager.sharedInstance.uniqueArtists {
            if theArtist == artist.artistName {
                let artistVC = self.storyboard?.instantiateViewControllerWithIdentifier("artistviewstoryboard") as! ArtistViewController
                artistVC.theArtist = artist
                self.showViewController(artistVC, sender: self)
                print("jumping to artist \(theArtist)")
                break
            }
        }
    }
    
    func goToAlbum(theAlbum: String) {
        for album in MusicManager.sharedInstance.uniqueAlbums {
            if theAlbum == album.albumTitle {
                let albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("albumviewstoryboard") as! AlbumViewController
                albumVC.theAlbum = album
                self.showViewController(albumVC, sender: self)
                print("jumping to album \(theAlbum)")
                break
            }
        }
    }
    
    
    // MARK: functions using generics to sort the array into sections sorted by first alphabet
    let characters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    
    func sort<T: Sortable >(collection: [T]) -> [(String,[T])] {
        var itemsDictionary = [String: [T]]()
        for item in collection {
            var firstAlphabet = item.getSortableName()[0..<1] //get first letter
            var isLetter = false
            //We put every non-alphabet items into a section called "#"
            for character in characters {
                if firstAlphabet.lowercaseString == character {
                    isLetter = true
                    break
                }
            }
            if !isLetter {
                firstAlphabet = "#"
            } else {
                firstAlphabet = firstAlphabet.uppercaseString
            }
            
            if itemsDictionary[firstAlphabet] == nil {
                itemsDictionary[firstAlphabet] = []
            }
            itemsDictionary[firstAlphabet]?.append(item)
        }
        return itemsDictionary.sort{
            (left, right) in
            if left.0 == "#" { //put # at last
                return false
            } else if right.0 == "#" {
                return true
            }
            return left.0 < right.0
        }
    }
    
    // Used in didSelectForRow
    // return sorted items in a single array
    func getAllSortedItems<T: Sortable> (collectionTuples: [(String, [T])]) -> [T] {
        var allItemsSorted = [T]()
        for itemSectionByAlphabet in collectionTuples {
            for item in itemSectionByAlphabet.1 {
                allItemsSorted.append(item)
            }
        }
        return allItemsSorted
    }
    
    // For songs, because we need to use the whole collection for the player queue instead an alphabet section, 
    // but indexPath.section and indexPath.row is only return the index of the alphabet section, so to find the
    // actual index in the entire collection, we need to iterate items in previous sections and aggregate together
    func findIndexToBePlayed<T: Sortable> (collectionTuples: [(String, [T])], section: Int, currentRow: Int) -> Int{
        var itemsInPreviousSections = 0
        if section > 0 {
            for i in 1...section {
                itemsInPreviousSections += collectionTuples[i-1].1.count
            }
        }
        return itemsInPreviousSections + currentRow
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if(isReloadTable){
            self.musicTable.reloadData()
            isReloadTable = false
        }
    }
    
}

extension MusicViewController {
    
    func generateWaveFormInBackEnd(nowPlayingItem:MPMediaItem){
        
        self.musicDataManager.initializeSongToDatabase(nowPlayingItem)
        
        if let _ = self.musicDataManager.getSongWaveFormImage(nowPlayingItem) {
            pthread_rwlock_wrlock(&self.rwLock)
            if(Int(self.songCount) < self.uniqueSongs.count-1){
                self.generateWaveFormInBackEnd(self.uniqueSongs[Int(OSAtomicIncrement64(&self.songCount))])
            }
             pthread_rwlock_unlock(&self.rwLock)
        } else {
            dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))) {
                guard let assetURL = nowPlayingItem.valueForProperty(MPMediaItemPropertyAssetURL) else {
                    print("sound url not available")
                    return
                }
            
                var op:NSBlockOperation?
                op = KGLOBAL_init_operationCache[assetURL as! NSURL]
                if(op == nil){
                    // have to use the temp value to do the nsoperation, cannot use (self.) do that.
                    let tempNowPlayingItem = nowPlayingItem
                    var progressBarWidth:CGFloat!
                    progressBarWidth = CGFloat(nowPlayingItem.playbackDuration) * progressWidthMultiplier
                    let tempProgressBlock = SoundWaveView(frame: CGRect(x: 0, y: 0, width: progressBarWidth, height: 161))
                    
                    let tempMusicDataManager = self.musicDataManager
                    op = NSBlockOperation(block: {
                        
                        if(op!.cancelled){
                            return
                        }
                        tempProgressBlock.SetSoundURL(assetURL as! NSURL, isForTabsEditor: false)

                        let data = UIImagePNGRepresentation(tempProgressBlock.generatedNormalImage)
                        tempMusicDataManager.saveSoundWave(tempNowPlayingItem, soundwaveData: tempProgressBlock.averageSampleBuffer!, soundwaveImage: data!)
                        print("Background wave finished for \(nowPlayingItem.title)")
                        
                        KGLOBAL_init_operationCache.removeValueForKey(assetURL as! NSURL)
                        
                        // make the
                        pthread_rwlock_wrlock(&self.rwLock)
                        if(Int(self.songCount) < self.uniqueSongs.count-1){
                            self.generateWaveFormInBackEnd(self.uniqueSongs[Int(OSAtomicIncrement64(&(self.songCount)))])
                        }
                        pthread_rwlock_unlock(&self.rwLock)
                    })
                    KGLOBAL_init_operationCache[assetURL as! NSURL] = op
                    KGLOBAL_init_queue.addOperation(op!)
                }
            }
        }
    }
}


