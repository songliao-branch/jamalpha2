//
//  MyFavoritesViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/11/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import MediaPlayer

class MyFavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var uniqueSongs = [MPMediaItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension MyFavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uniqueSongs.count
    }
}
