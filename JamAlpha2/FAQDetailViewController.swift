//
//  FAQDetailViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/25/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import UIKit

class FAQDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.title = "Detail"
        setUpMainView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var tableView: UITableView!
    var question: String!
    var answer: String!
    
}

extension FAQDetailViewController {
    func setUpMainView() {
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        let titleLabel: UILabel = UILabel()
        titleLabel.frame = CGRectMake(12, 11, self.view.frame.size.width - 24, 44)
        titleLabel.textAlignment = .Justified
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = .ByWordWrapping
        titleLabel.font = UIFont.boldSystemFontOfSize(13)
        titleLabel.text = question
        self.view.addSubview(titleLabel)
        
        let textView: UITextView = UITextView()
        textView.frame = CGRectMake(10, 55, self.view.frame.size.width - 20, self.view.frame.size.height - 64)
        textView.textAlignment = .Left
        textView.font = UIFont.systemFontOfSize(14)
        textView.textAlignment = .Justified
        textView.text = answer
        textView.sizeToFit()
        textView.backgroundColor = UIColor.clearColor()
        textView.userInteractionEnabled = false
        self.view.addSubview(textView)
    }
}
