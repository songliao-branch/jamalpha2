//
//  DetailViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 5/26/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var haha: UILabel!
    

    @IBOutlet weak var imageView: UIImageView!
    var demoString:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        haha.text = demoString
        println("detail view load and string is \(demoString)")
        
        //imageView.image = UIImage(named: demoString)
    }
    
}
