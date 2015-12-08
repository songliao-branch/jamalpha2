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
    
    var trackId:Int?
    var trackName: String?
    var artistName: String?
    var collectionName: String?
    var trackTimeMillis: Float?
    
    
    var artworkUrl100: String?//large 100
    var previewUrl: String?
    var trackViewUrl: String? // link to apple music or iTunes
    
    init(wrapperType: String, kind: String){
        self.wrapperType = wrapperType
        self.kind = kind
    }
    
    var image: UIImage?
}


let jamBaseURL = "https://jamapi.herokuapp.com"

class APIManager: NSObject {
    
    //MARK: iTunes search
    static let searchBaseURL = "https://itunes.apple.com/search"
    
    class func searchParameters(searchTerm: String) -> [String: String] {
        return ["term":"\(searchTerm)", "limit":"20", "media":"music"]
    }
    
    static let tabsSetURL = jamBaseURL + "/tabs_sets"
    static let lyricsSetURL = jamBaseURL + "/lyrics_sets"
    
    //upload tabs
    class func uploadTabs(song: Findable, completion: ((isSuccess: Bool) -> Void)) {
        
        var chords = [Chord]() //([Chord], String, Int)
        var tuning = ""
        var capo = 0
        
        (chords, tuning, capo, _) = CoreDataManager.getTabs(song, fetchingLocalOnly: true)
        
        var timesData = [Float]()
        var chordsData = [String]()
        var tabsData = [String]()
        
        for i in 0..<chords.count {
            timesData.append((chords[i].time).toDecimalNumer())
            chordsData.append(chords[i].tab.name)
            tabsData.append(chords[i].tab.content)
        }
        
        let parameters = [
            "title": song.getTitle(),
            "artist": song.getArtist(),
            "duration": song.getDuration(),
            
            "tuning": tuning,
            "capo": capo,
            "times": timesData,
            "chords": chordsData,
            "tabs": tabsData,
            "user_id": Int(CoreDataManager.getCurrentUser()!.id)
        ]
        
        Alamofire.request(.POST, tabsSetURL, parameters: parameters as? [String : AnyObject], encoding: .JSON).responseJSON
            {
                response in
                switch response.result {
                case .Success:
                    completion(isSuccess: true)
                    print("Tabs uploaded succesfully")
                case .Failure(let error):
                    completion(isSuccess: false)
                    print(error)
                }
        }
    }
    
    //upload lyrics
    class func uploadLyrics(song: Findable, completion: ((isSuccess: Bool) -> Void)) {

        var lyric = Lyric()
        
        (lyric, _) = CoreDataManager.getLyrics(song, fetchingLocalOnly: true)
        
        var times = [Float]()
        var lyrics = [String]()
        
        for line in lyric.lyric {
            times.append(line.time.toDecimalNumer())
            lyrics.append(line.str)
        }
        
        let parameters = [
            "title": song.getTitle(),
            "artist": song.getArtist(),
            "duration": song.getDuration(),
            
            "times": times,
            "lyrics": lyrics,
            "user_id": Int(CoreDataManager.getCurrentUser()!.id)
        ]
    
        Alamofire.request(.POST, lyricsSetURL, parameters: parameters as? [String : AnyObject], encoding: .JSON).responseJSON
            {
                response in
                switch response.result {
                case .Success:
                    print("Lyrics uploaded succesfully")
                    completion(isSuccess: true)
                case .Failure(_):
                    completion(isSuccess: false)
                }
        }
    }
    
    //download all tabs sets for one song, the callback return the result
    class func downloadTabs(findable: Findable, completion: ((downloads: [DownloadedTabsSet]) -> Void)) {
        
        var allDownloads = [DownloadedTabsSet]()
        
        //given a song's title, artist, and duration, we can find all its corresponding tabs
        var parameters = [String: AnyObject]()
        
        parameters = ["title": findable.getTitle(), "artist": findable.getArtist(), "duration": findable.getDuration()]
        
        //we use user id to determine the vote status of each tabsSet for the current user
        if CoreDataManager.getCurrentUser() != nil {
            parameters["user_id"] = Int(CoreDataManager.getCurrentUser()!.id)
        }
        
        Alamofire.request(.GET, jamBaseURL + "/get_tabs_sets", parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    print(json)
                    for set in json["tabs_sets"].array! {
                        
                        let editor = Editor(userId: set["user"]["id"].int!, nickname: set["user"]["nickname"].string!, avatarUrlMedium: set["user"]["avatar_url_medium"].string!, avatarUrlThumbnail: set["user"]["avatar_url_thumbnail"].string!)
                        let t = DownloadedTabsSet(id: set["id"].int!, songId: set["song_id"].int!, tuning: set["tuning"].string!, capo: set["capo"].int!, chordsPreview: set["chords_preview"].string!, votesScore: set["cached_votes_score"].int!, voteStatus: set["vote_status"].string!, editor: editor, updatedAt: set["updated_at"].string!)
                        
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
    
    class func downloadMostLikedTabs(findable: Findable, completion: (( downloadWithContent: DownloadedTabsSet) -> Void)) {
        
        var parameters = [String: AnyObject]()
        
        parameters = ["title": findable.getTitle(), "artist": findable.getArtist(), "duration": findable.getDuration()]
        
        Alamofire.request(.GET, jamBaseURL + "/get_most_liked_tabs_set", parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    
                    print(json)
                    if let _ = json["error"].string {
                        print("no most liked tabs yet")
                        return
                    }
                    let set = json["tabs_set_content"]
                    
           
                    
                    var theTimes = [Float]()
                    
                    //TODO: array for times come in as string array, need to change backend, and this might too much for everything at once, needs pagination soon
                    for time in set["times"].arrayObject as! [String] {
                        theTimes.append(Float(time)!)
                    }
                    
                    let t = DownloadedTabsSet(id: set["id"].int!, songId: set["song_id"].int!, tuning: set["tuning"].string!, capo: set["capo"].int!, chordsPreview: "", votesScore: 0, voteStatus: "", editor: Editor(), updatedAt: "")
                    
                    t.times = theTimes
                    t.chords  = set["chords"].arrayObject as! [String]
                    t.tabs  = set["tabs"].arrayObject as! [String]
                    
                    //after completed, pass everything to the callback
                    completion(downloadWithContent: t)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    //download all lyrics related to one song
    class func downloadLyrics(findable: Findable, completion: ( (downloads: [DownloadedLyricsSet])-> Void ) ) {
        var allDownloads = [DownloadedLyricsSet]()
        
        //given a song's title, artist, and duration, we can find all its corresponding tabs
        var parameters = [String: AnyObject]()
        
        parameters = ["title": findable.getTitle(), "artist": findable.getArtist(), "duration": findable.getDuration()]
        
        //we use user id to determine the vote status of each lyricsSet for the current user
        if CoreDataManager.getCurrentUser() != nil {
            parameters["user_id"] = Int(CoreDataManager.getCurrentUser()!.id)
        }

        Alamofire.request(.GET, jamBaseURL + "/get_lyrics_sets", parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    print(json)
                    for set in json["lyrics_sets"].array! {
                        
                         let editor = Editor(userId: set["user"]["id"].int!, nickname: set["user"]["nickname"].string!, avatarUrlMedium: set["user"]["avatar_url_medium"].string!, avatarUrlThumbnail: set["user"]["avatar_url_thumbnail"].string!)
                        
                        let l = DownloadedLyricsSet(id: set["id"].int!, songId: set["song_id"].int!, lyricsPreview: set["lyrics_preview"].string!, numberOfLines: set["number_of_lines"].int!, votesScore: set["cached_votes_score"].int!, voteStatus: set["vote_status"].string!, editor: editor, updatedAt: set["updated_at"].string!)
                        
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
    
    class func downloadMostLikedLyrics(findable: Findable, completion: (( downloadWithContent: DownloadedLyricsSet) -> Void)) {
        
        var parameters = [String: AnyObject]()
        
        parameters = ["title": findable.getTitle(), "artist": findable.getArtist(), "duration": findable.getDuration()]
        
        Alamofire.request(.GET, jamBaseURL + "/get_most_liked_lyrics_set", parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    
                    print(json)
                    if let _ = json["error"].string {
                        print("no most liked lyrics yet")
                        return
                    }
                    let set = json["lyrics_set_content"]
                    
                    
                    var theTimes = [Float]()
                    
                    //TODO: array for times come in as string array, need to change backend, and this might too much for everything at once, needs pagination soon
                    for time in set["times"].arrayObject as! [String] {
                        theTimes.append(Float(time)!)
                    }
                    
                    let l = DownloadedLyricsSet(id: set["id"].int!, songId: set["song_id"].int!, lyricsPreview: "", numberOfLines: 0, votesScore: 0, voteStatus: "", editor: Editor(), updatedAt: "")
                    
                    l.lyrics = set["lyrics"].arrayObject as! [String]
                    l.times = theTimes
                    //after completed, pass everything to the callback
                    completion(downloadWithContent: l)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    
    //upvote or downvote either tabsSet or lyricsSet
    class func updateVotes(isUp: Bool, isTabs: Bool, setId: Int, completion: (( voteStatus: String, voteScore: Int) -> Void)){
        
        
        let parameters = ["user_id": "\(CoreDataManager.getCurrentUser()!.id)"]
        
        var path = isTabs ? "/tabs_sets/\(setId)" : "/lyrics_sets/\(setId)"
        path += isUp ? "/like" : "/dislike"
        
        Alamofire.request(.PUT, jamBaseURL + path , parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    
                    if isTabs {
                        let set = json["tabs_set"]
                        completion(voteStatus: set["vote_status"].string!, voteScore: set["cached_votes_score"].int!)
                    } else {
                        let set = json["lyrics_set"]
                        completion(voteStatus: set["vote_status"].string!, voteScore: set["cached_votes_score"].int!)
                    }
                    
                    print(json)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    
    //MARK: update user API
    class func updateUserNickname(nickname: String, completion: ((completed: Bool) -> Void)) {
        
        let parameters = ["nickname": nickname]
        
        Alamofire.request(.PUT, jamBaseURL + "/users/\(CoreDataManager.getCurrentUser()!.id)" , parameters: parameters).responseJSON { response in
            print(response)
            switch response.result {
            case .Success:
                completion(completed: true)
            case .Failure(let error):
                completion(completed: true)
                print("update user error: \(error)")
            }
        }
    }
    
    class func updateUserAvatar(avatarUrlMedium: String, avatarUrlThumbnail: String, completion: ((completed: Bool) -> Void)) {
        //TODO: check network availability
        
        //given a song's title, artist, and duration, we can find all its corresponding tabs
        let parameters = ["avatar_url_medium": avatarUrlMedium, "avatar_url_thumbnail": avatarUrlThumbnail]
    
        Alamofire.request(.PUT, jamBaseURL + "/users/\(CoreDataManager.getCurrentUser()!.id)" , parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                completion(completed: true)
            case .Failure(let error):
                completion(completed: true)
                print("update user error: \(error)")
            }
        }
    }
}
