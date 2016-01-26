//
//  FAQViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/25/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.title = "FAQ"

        setUpTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let faqs: [String] = [
        "How to hide the chord content or lyrics on music view?",
        "How to add the capo on fret  and change tuning when edit tabs?",
        "Can I keep my own tabs and lyrics privately?",
        "Will my tabs and lyrics be saved if I log in and out of Twistjam?",
        "Who has the right to use the tabs and lyrics I edited?",
        "How to hide the demo song?",
        "How to turn on the tutorial again?",
        "How to learn edit tabs and lyrics by Tabs Editor and Lyrics Editor?"
    ]
    
    let answer1: String = "At the music view, you will see four options on the bottom of the view. Touch the third button and you will open a action sheet. \n\nYou can choose different style for music view. You can hidden chord content or lyrics by turn off the switch. \n\nIf you turned off all three switch, the music view will be a pure music player with the song's cover image."
    
    let answer2: String = "At the Tabs Editor view, touch the the tuning button on the top menu, you will open an action sheet for all tuning functions. \n\nYou can change the music speed, add capo and change tuning for every single string."
    
    let answer3: String = "Yes. \n\nBefore you touch the save button on Tabs Editor, touch the earch icon and it will become a lock, which means this tabs will be uploaded to your personal cloud without shareing with other uses."
    
    let answer4: String = "Yes. \n\nIf you regitered an account successfully, all your personal information including your tabs and lyrics will be saved on your private cloud. When you login again, everything will be syncronized from cloud."
    
    let answer5: String = "You own the rights for tabs and lyrics you edited. If you make them public, other users can use them. \n\nTwistjam encourage you to make your tabs and lyrics public, so other users will have more high quality tabs and lyrics to use."
    
    let answer6: String = "Go to setting, and go to Demo Mode. Turn off the switch."
    
    let answer7: String = "If you want to watch the tutorial again, go to setting, and go to Tutorial. Turn on the switch."
    
    let answer8: String = "Please go to Twitjam Youtube official channel to watch more tutorials about how to edit tabs and lyrics by Tabs Editor and Lyrics Editor."
    
    let end: String = "\n\nIf you have any questions, go to setting, touch Contact Us. Send us your questions and we will reply as soon as possible."
    
    var answers: [String]!
    var tableView: UITableView!
}

extension FAQViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTableView() {
        answers = [answer1, answer2, answer3, answer4, answer5, answer6, answer7, answer8]
        let frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)
        tableView = UITableView(frame: frame, style: .Grouped)
        //tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(12)
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.lineBreakMode = .ByWordWrapping
        cell.selectionStyle = .None
        cell.accessoryType = .DisclosureIndicator
        cell.textLabel?.text = faqs[indexPath.item]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faqs.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let faqdetailVC: FAQDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("faqdetailVC") as! FAQDetailViewController
        faqdetailVC.question = faqs[indexPath.item]
        faqdetailVC.answer = answers[indexPath.item] + end
        self.navigationController?.pushViewController(faqdetailVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
