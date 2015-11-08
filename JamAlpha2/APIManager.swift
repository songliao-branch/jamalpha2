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
    static let songURL = jamBaseURL + "/songs"
    static let tabsSetURL = jamBaseURL + "/tabs_sets"

    class func uploadTabs(mediaItem: MPMediaItem)  {
        
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
                    
                    let songId = json["songs"][0]["id"].int!
                    sendUploadTabsRequest(songId, mediaItem: mediaItem)
                    
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    private class func sendUploadTabsRequest(songID: Int, mediaItem: MPMediaItem){
        
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
        let parameters = [
            "tabs_set": [
                "tuning": tuning,
                "capo": capo,
                "times": timesData,
                "chords": chordsData,
                "tabs": tabsData,
                "song_id":  songID
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
    }
    
}
