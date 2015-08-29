

import UIKit
import MediaPlayer

class AlbumViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var theAlbum:Album!
    var musicViewController: MusicViewController?
    var animator: CustomTransitionAnimation?
    var songsInTheAlbum: [MPMediaItem]!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        songsInTheAlbum = [MPMediaItem]()
        songsInTheAlbum = theAlbum.songsIntheAlbum
        self.createTransitionAnimation()

        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func viewWillAppear(animated: Bool) {
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
    }
    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theAlbum.numberOfTracks
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("albumtrackcell", forIndexPath: indexPath) as! AlbumTrackCell
        let song = theAlbum.songsIntheAlbum[indexPath.row]

        let trackNumber = song.albumTrackNumber
        let title = song.title
        
        if trackNumber < 1 {
            cell.trackNumberLabel.hidden = true
        } else {
            cell.trackNumberLabel.text = "\(trackNumber)"
        }
        cell.titleLabel.text = title
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        MusicManager.sharedInstance.setPlayerQueue(songsInTheAlbum)
        MusicManager.sharedInstance.setIndexInTheQueue(indexPath.row)
        
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        songVC.musicViewController = self.musicViewController
        
        songVC.selectedFromTable = true
        
        songVC.transitioningDelegate = self.animator
        self.animator!.attachToViewController(songVC)
        self.presentViewController(songVC, animated: true, completion: nil)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
