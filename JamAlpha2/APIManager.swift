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

struct DownloadedTabs {
    var tuning: String
    var capo: Int
    
    var chords: [String]
    var tabs: [String]
    var times: [Float]
    
    var songId = -1
    
    var upVote = 0
    var downVote = 0
    //var userId
    //var userName
    
}
class APIManager: NSObject {
    
    //MARK: iTunes search
    static let searchBaseURL = "https://itunes.apple.com/search"
    
    class func searchParameters(searchTerm: String) -> [String: String] {
        return ["term":"\(searchTerm)", "limit":"20", "media":"music"]
    }
    
    //MARK: heroku server codes
    static let jamBaseURL = "https://jamapi.herokuapp.com"
    static let songURL = jamBaseURL + "/songs"
    static let tabsSetURL = jamBaseURL + "/tabs_sets"
    

    class func uploadTabs(mediaItem: MPMediaItem) {
        let musicDataManager = MusicDataManager()
        
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
        
        findSongId(mediaItem, callback: { (songId: Int) in
            //TODO: needs user_id parameter
            let parameters = [
                "tabs_set": [
                    "tuning": tuning,
                    "capo": capo,
                    "times": timesData,
                    "chords": chordsData,
                    "tabs": tabsData,
                    "song_id":  songId
                ]
            ]
            
            Alamofire.request(.POST, tabsSetURL, parameters: parameters, encoding: .JSON).responseJSON
                {
                    response in
                    
                    switch response.result {
                    case .Success:
                        print("Tabs uploaded succesfully")
                    case .Failure(let error):
                        print(error)
                    }
            }
        })
    }
    
    //download all tabs sets for one song, the callback return the result
    class func downloadTabs(mediaItem: MPMediaItem, callbackResults: (downloads: [DownloadedTabs]) -> Void ) {
        var allDownloads = [DownloadedTabs]()
        
        findSongId(mediaItem, callback: { songId in
            
            let parameters = ["song_id": songId]
            
            Alamofire.request(.GET, tabsSetURL, parameters: parameters).responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        print("Downloaded JSON:\(json)")
                        
                        for set in json["tabs_sets"].array! {
                            var theTimes = [Float]()
                            
                            //TODO: array for times come in as string array, need to change backend, and this might too much for everything at once, needs pagination soon
                            for time in set["times"].arrayObject as! [String] {
                                theTimes.append(Float(time)!)
                            }
                            
                            let theChords = set["chords"].arrayObject as! [String]
                            let theTabs = set["tabs"].arrayObject as! [String]
                            let t = DownloadedTabs(tuning: set["tuning"].string!, capo: set["capo"].int!, chords: theChords, tabs: theTabs, times: theTimes, songId: set["song_id"].int!, upVote: set["upvotes"].int!, downVote: set["downvotes"].int!)
                            allDownloads.append(t)
                        }
                        
                        callbackResults(downloads: allDownloads)
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        })
    }
    
    
    
    //HELPER: find the songId required to associate with the tabs
    private class func findSongId(mediaItem: MPMediaItem, callback: (songId: Int) -> Void ) {
        let parameters = ["title": mediaItem.title!, "artist": mediaItem.artist!, "album": mediaItem.albumTitle!]
        
        Alamofire.request(.GET, songURL, parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    if json["songs"].count > 1 {
                        print("this song should never have been initialized twice")
                        return
                    }
                    
                    let id = json["songs"][0]["id"].int!
                    
                    //then initialize callback for another request
                    callback(songId: id)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
}
