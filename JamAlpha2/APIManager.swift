//
//  API.swift
//  JamAlpha2
//  Created by Song Liao on 8/31/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//  iTunes search api

import UIKit
import Alamofire
import SwiftyJSON
import MediaPlayer

class SearchResult {
    
    var wrapperType: String!
    var kind: String!
    
    var trackName: String?
    var artistName: String?
    var collectionName: String?
    
    var artworkUrl100: String?//large 100
    var previewUrl: String?
    var trackViewUrl: String? // link to apple music or iTunes
    
    init(wrapperType: String, kind: String){
        self.wrapperType = wrapperType
        self.kind = kind
    }
}


class APIManager: NSObject {
    
    //MARK: iTunes search
    static let searchBaseURL = "https://itunes.apple.com/search"
    
    class func searchParameters(searchTerm: String) -> [String: String] {
        return ["term":"\(searchTerm)", "limit":"20", "media":"music"]
    }
    
    //MARK: heroku server codes
    static let jamBaseURL = "https://jamapi.herokuapp.com"
    
    static let tabsSetURL = jamBaseURL + "/tabs_sets"
    static let lyricsSetURL = jamBaseURL + "/lyrics_sets"
    
    //upload tabs
    class func uploadTabs(mediaItem: MPMediaItem) {
        let musicDataManager = MusicDataManager()
        
        var title = ""
        var artist = ""
        let duration = Float(mediaItem.playbackDuration)
        if let t = mediaItem.title {
            title = t
        }
        if let a = mediaItem.artist {
            artist = a
        }
        
        var chords = [Chord]() //([Chord], String, Int)
        var tuning = ""
        var capo = 0
        
        (chords, tuning, capo) = musicDataManager.getTabs(mediaItem)
        
        var timesData = [Float]()
        var chordsData = [String]()
        var tabsData = [String]()
        
        for i in 0..<chords.count {
            timesData.append((chords[i].time).toDecimalNumer())
            chordsData.append(chords[i].tab.name)
            tabsData.append(chords[i].tab.content)
        }
        
        let parameters = [
            "title": title,
            "artist": artist,
            "duration": duration,
            
            "tuning": tuning,
            "capo": capo,
            "times": timesData,
            "chords": chordsData,
            "tabs": tabsData,
            "user_id": 1 //TODO: change later
        ]
        
        Alamofire.request(.POST, tabsSetURL, parameters: parameters as? [String : AnyObject], encoding: .JSON).responseJSON
            {
                response in
                switch response.result {
                case .Success:
                    print("Tabs uploaded succesfully")
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    //upload lyrics
    class func uploadLyrics(mediaItem: MPMediaItem) {
        let musicDataManager = MusicDataManager()
        
        var title = ""
        var artist = ""
        let duration = Float(mediaItem.playbackDuration)
        if let t = mediaItem.title {
            title = t
        }
        if let a = mediaItem.artist {
            artist = a
        }
        
        var data = [(String, NSTimeInterval)]()
        data = musicDataManager.getLyrics(mediaItem)
        var times = [Float]()
        var lyrics = [String]()
        for i in 0..<data.count {
            times.append(Float(data[i].1))
            lyrics.append(data[i].0)
        }
        
        let parameters = [
            "title": title,
            "artist": artist,
            "duration": duration,
            
            "times": times,
            "lyrics": lyrics,
            "user_id": 1 //TODO: change later
        ]
    
        Alamofire.request(.POST, lyricsSetURL, parameters: parameters as? [String : AnyObject], encoding: .JSON).responseJSON
            {
                response in
                switch response.result {
                case .Success:
                    print("Lyrics uploaded succesfully")
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    //download all tabs sets for one song, the callback return the result
    class func downloadTabs(mediaItem: MPMediaItem, completion: ((downloads: [DownloadedTabsSet]) -> Void)) {
        
        var allDownloads = [DownloadedTabsSet]()
        
        //given a song's title, artist, and duration, we can find all its corresponding tabs
        let parameters = ["title": mediaItem.title!, "artist": mediaItem.artist!, "duration": mediaItem.playbackDuration]
        
        Alamofire.request(.GET, jamBaseURL + "/get_tabs_sets", parameters: parameters as? [String : AnyObject]).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    print(json)
                    for set in json["tabs_sets"].array! {
                        let t = DownloadedTabsSet(id: set["id"].int!, tuning: set["tuning"].string!, capo: set["capo"].int! , songId: set["song_id"].int!, upVotes: set["upvotes"].int!, downVotes: set["downvotes"].int!, userId: set["user_id"].int!, chordsPreview: set["chords_preview"].string!)
                        allDownloads.append(t)
                    }
                   //after completed, pass everything to the callback
                   completion(downloads: allDownloads)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    //download one tabs
    class func downloadTabsSetContent(downloadedTabsSet: DownloadedTabsSet, completion: (( downloadWithContent: DownloadedTabsSet) -> Void)) {
        
        Alamofire.request(.GET, jamBaseURL + "/tabs_sets/\(downloadedTabsSet.id)").responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    let set = json["tabs_set_content"]
                    
                    print(json)
                    var theTimes = [Float]()
                    
                    //TODO: array for times come in as string array, need to change backend, and this might too much for everything at once, needs pagination soon
                    for time in set["times"].arrayObject as! [String] {
                        theTimes.append(Float(time)!)
                    }
                    
                    downloadedTabsSet.times = theTimes
                    downloadedTabsSet.chords  = set["chords"].arrayObject as! [String]
                    downloadedTabsSet.tabs  = set["tabs"].arrayObject as! [String]
                    
                    //after completed, pass everything to the callback
                    completion(downloadWithContent: downloadedTabsSet)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    //download all lyrics related to one song
    class func downloadLyrics(mediaItem: MPMediaItem, completion: ( (downloads: [DownloadedLyricsSet])-> Void ) ) {
        var allDownloads = [DownloadedLyricsSet]()
        
        //given a song's title, artist, and duration, we can find all its corresponding tabs
        let parameters = ["title": mediaItem.title!, "artist": mediaItem.artist!, "duration": mediaItem.playbackDuration]
        
        Alamofire.request(.GET, jamBaseURL + "/get_lyrics_sets", parameters: parameters as? [String : AnyObject]).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    print(json)
                    for set in json["lyrics_sets"].array! {

                        let l  = DownloadedLyricsSet(id: set["id"].int!, songId: set["song_id"].int!, userId: set["user_id"].int!, upvotes: set["upvotes"].int!, downvotes: set["downvotes"].int!, lyricsPreview: set["lyrics_preview"].string!, lines: set["number_of_lines"].int!)
                        allDownloads.append(l)
                    }
                    //after completed, pass everything to the callback
                    completion(downloads: allDownloads)
                }
            case .Failure(let error):
                print(error)
            }
        }
        
    }
    
    //
    
    class func downloadLyricsSetContent(inputLyricsSet: DownloadedLyricsSet, completion: (( downloadWithContent: DownloadedLyricsSet) -> Void)) {
        Alamofire.request(.GET, jamBaseURL + "/lyrics_sets/\(inputLyricsSet.id)").responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    let set = json["lyrics_set_content"]
                    
                    print(json)
                    var theTimes = [Float]()
                    
                    //TODO: array for times come in as string array, need to change backend, and this might too much for everything at once, needs pagination soon
                    for time in set["times"].arrayObject as! [String] {
                        theTimes.append(Float(time)!)
                    }
                    
                    inputLyricsSet.times = theTimes
                    inputLyricsSet.lyrics  = set["lyrics"].arrayObject as! [String]
                    
                    //after completed, pass everything to the callback
                    completion(downloadWithContent: inputLyricsSet)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }

    class func updateVotes(isUp: Bool, tabsSet: DownloadedTabsSet){
        //TODO: need a user token to update, and one user can only update a tabs once!
        let parameters = ["increment_votes": (isUp ? 1 : 0)]
        Alamofire.request(.PUT, jamBaseURL + "/tabs_sets/\(tabsSet.id)", parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    
                    print(json)
                }
            case .Failure(let error):
                //TODO: show alert dialog cannot update
                print(error)
            }
        }
    }
}
