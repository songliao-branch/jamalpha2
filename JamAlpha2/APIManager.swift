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


let jamBaseURL = "https://jamapi.herokuapp.com"

class APIManager: NSObject {
    
    static let tabsSetURL = jamBaseURL + "/tabs_sets"
    static let lyricsSetURL = jamBaseURL + "/lyrics_sets"
    
    //upload tabs
    class func uploadTabs(song: Findable, completion: ((cloudId: Int) -> Void)) {
        
        var chords = [Chord]() //([Chord], String, Int)
        var tuning = ""
        var capo = 0
        var visible = true
        (chords, tuning, capo, _, visible) = CoreDataManager.getTabs(song, fetchingUsers: true)
        
        if chords.count < 2 {
            print("uploading tabs error: tabs count is less than 2")
            return
        }
        
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
            "user_id": Int(CoreDataManager.getCurrentUser()!.id),
            "visible": visible
        ]
        
        Alamofire.request(.POST, tabsSetURL, parameters: parameters as? [String : AnyObject], encoding: .JSON).responseJSON
            {
                response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        //we get an ID, successfully created or updated
                        completion(cloudId: json["tabs_set"]["id"].int!)
                        print("Tabs uploaded succesfully")
                    }
                case .Failure(let error):
                    print("upload tabs failed")
                    print(error)
                }
        }
    }
    
    //upload lyrics
    class func uploadLyrics(song: Findable, completion: ((cloudId: Int) -> Void)) {

        var lyric = Lyric()
        
        (lyric, _) = CoreDataManager.getLyrics(song, fetchingUsers: true)
        
        if lyric.lyric.count < 2 {
            print("uploading lyrics error: lyrics count is less than 2")
            return
        }
        
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
            "user_id": Int(CoreDataManager.getCurrentUser()!.id),
            "visible": true //lyrics are all public..I assume no-one cares
        ]
    
        Alamofire.request(.POST, lyricsSetURL, parameters: parameters as? [String : AnyObject], encoding: .JSON).responseJSON
            {
                response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        //we get an ID, successfully created or updated
                        completion(cloudId: json["lyrics_set"]["id"].int!)
                        print("Lyrics uploaded succesfully")
                    }
                case .Failure(_):
                    print("Lyrics upload failed")
                }
        }
    }
    
    class func toggleSetVisibility(setId setId: Int, isTabs: Bool, completion: ((visible: Bool) -> Void)) {
        let url = isTabs ? tabsSetURL : lyricsSetURL
        // PUT /tabs_sets/:id/change_visibility
        Alamofire.request(.PUT, url + "/\(setId)/change_visibility").responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
 
                    let visible = isTabs ? json["tabs_set"]["visible"].bool! : json["lyrics_set"]["visible"].bool!
                    completion(visible: visible)
                }
            case .Failure(let error):
                print("Cannot delete network error")
                print(error)
            }
        }
    }
    
    class func deleteSet(isTabs isTabs: Bool, id: Int) {
        let url = isTabs ? tabsSetURL : lyricsSetURL
        Alamofire.request(.DELETE, url + "/\(id)").responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    if json["result"].string! == "successfully destroyed"{
                        print("successfully destroyed")
                    } else {
                        print("delete request sent, but cannot delete")
                    }
                }
            case .Failure(let error):
                print("Cannot delete network error")
                print(error)
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

                    for set in json["tabs_sets"].array! {
                        
                        let editor = Editor(userId: set["user"]["id"].int!, nickname: set["user"]["nickname"].string!, avatarUrlMedium: set["user"]["avatar_url_medium"].string!, avatarUrlThumbnail: set["user"]["avatar_url_thumbnail"].string!)
                        
                        let t = DownloadedTabsSet(id: set["id"].int!, tuning: set["tuning"].string!, capo: set["capo"].int!, chordsPreview: set["chords_preview"].string!, votesScore: set["cached_votes_score"].int!, voteStatus: set["vote_status"].string!, editor: editor, lastEdited: set["last_edited"].string!)
                        
                        let song = SearchResult(title: set["song"]["title"].string!, artist: set["song"]["artist"].string! , duration: set["song"]["duration"].float!)
                        t.song = song
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
                    
                    var theTimes = [Float]()
                    
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
    
    class func downloadMostLikedTabs(findable: Findable, completion: ((found: Bool, downloadWithContent: DownloadedTabsSet) -> Void)) {
        
        var parameters = [String: AnyObject]()
        
        parameters = ["title": findable.getTitle(), "artist": findable.getArtist(), "duration": findable.getDuration()]
        
        Alamofire.request(.GET, jamBaseURL + "/get_most_liked_tabs_set", parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    
                    if let _ = json["error"].string {
                        print("no most liked tabs yet")
                        completion(found: false, downloadWithContent:  DownloadedTabsSet(id: 0,  tuning: "", capo: 0, chordsPreview: "", votesScore: 0, voteStatus: "", editor: Editor(), lastEdited: ""))
                        return
                    }
                    
                    let set = json["tabs_set_content"]
                    
                    let editor = Editor(userId: set["user_id"].int!, nickname: "", avatarUrlMedium: "", avatarUrlThumbnail: "")
                    let t = DownloadedTabsSet(id: set["id"].int!, tuning: set["tuning"].string!, capo: set["capo"].int!, chordsPreview: "", votesScore: 0, voteStatus: "", editor: editor, lastEdited: "")
                    
                    var theTimes = [Float]()
                    
                    for time in set["times"].arrayObject as! [String] {
                        theTimes.append(Float(time)!)
                    }
                    
                    t.times = theTimes
                    t.chords  = set["chords"].arrayObject as! [String]
                    t.tabs  = set["tabs"].arrayObject as! [String]
                    
                    //after completed, pass everything to the callback
                    completion(found: true, downloadWithContent: t)
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

                    for set in json["lyrics_sets"].array! {
                        
                        let editor = Editor(userId: set["user"]["id"].int!, nickname: set["user"]["nickname"].string!, avatarUrlMedium: set["user"]["avatar_url_medium"].string!, avatarUrlThumbnail: set["user"]["avatar_url_thumbnail"].string!)
                        
                        let l = DownloadedLyricsSet(id: set["id"].int!, lyricsPreview: set["lyrics_preview"].string!, numberOfLines: set["number_of_lines"].int!, votesScore: set["cached_votes_score"].int!, voteStatus: set["vote_status"].string!, editor: editor, lastEdited: set["last_edited"].string!)
                        
                        let song = SearchResult(title: set["song"]["title"].string!, artist: set["song"]["artist"].string! , duration: set["song"]["duration"].float!)
                        l.song = song
                        
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
                    
                    var theTimes = [Float]()
                    
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
    
    class func downloadMostLikedLyrics(findable: Findable, completion: (( found: Bool, downloadWithContent: DownloadedLyricsSet) -> Void)) {
        
        var parameters = [String: AnyObject]()
        
        parameters = ["title": findable.getTitle(), "artist": findable.getArtist(), "duration": findable.getDuration()]
        
        Alamofire.request(.GET, jamBaseURL + "/get_most_liked_lyrics_set", parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    if let _ = json["error"].string {
                        print("no most liked lyrics yet")
                        completion(found: false, downloadWithContent: DownloadedLyricsSet(id: 0,lyricsPreview: "", numberOfLines: 0, votesScore: 0, voteStatus: "", editor: Editor(), lastEdited: ""))
                        return
                    }
                    let set = json["lyrics_set_content"]
                    
                    
                    var theTimes = [Float]()
                    for time in set["times"].arrayObject as! [String] {
                        theTimes.append(Float(time)!)
                    }
                    
                    let editor = Editor(userId: set["user_id"].int!, nickname: "", avatarUrlMedium: "", avatarUrlThumbnail: "")
                    let l = DownloadedLyricsSet(id: set["id"].int!, lyricsPreview: "", numberOfLines: 0, votesScore: 0, voteStatus: "", editor: editor, lastEdited: "")
                    
                    l.lyrics = set["lyrics"].arrayObject as! [String]
                    l.times = theTimes
                    //after completed, pass everything to the callback
                    completion(found: true, downloadWithContent: l)

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
    
    class func downloadCurrentUserTabsAndLyrics(completion: ((downloadedTabsSets: [DownloadedTabsSet], downloadedLyricsSets: [DownloadedLyricsSet]) -> Void)) {
      
        Alamofire.request(.GET, jamBaseURL + "/users/\(CoreDataManager.getCurrentUser()!.id)").responseJSON { response in
            
            var myTabsSets = [DownloadedTabsSet]()
            var myLyricsSets = [DownloadedLyricsSet]()
            
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    
                    let tabsSets = json["user"]["tabs_sets"]
                    let lyricsSets = json["user"]["lyrics_sets"]
                    
                    //must have an user_id
                    let editor = Editor(userId: json["user"]["id"].int!, nickname: "", avatarUrlMedium: "", avatarUrlThumbnail: "")
                    
                    for set in tabsSets.array! {
                        let t = DownloadedTabsSet(id: set["id"].int!, tuning: set["tuning"].string!, capo: set["capo"].int!, chordsPreview: set["chords_preview"].string!, votesScore: 0, voteStatus: "", editor: editor, lastEdited: set["last_edited"].string!)
                        
                        t.chords = set["chords"].arrayObject as! [String]
                        t.tabs = set["tabs"].arrayObject as! [String]
                        t.visible = set["visible"].bool!
                        
                        var theTimes = [Float]()
                        
                        let song = SearchResult(songId: set["song"]["id"].int!, title: set["song"]["title"].string!, artist: set["song"]["artist"].string!, duration: set["song"]["duration"].float!)

                        t.song = song
                        for time in set["times"].arrayObject as! [String] {
                            theTimes.append(Float(time)!)
                        }
                        
                        t.times = theTimes
                        myTabsSets.append(t)
                    }
                    
                    for set in lyricsSets.array! {
                        let l = DownloadedLyricsSet(id: set["id"].int!, lyricsPreview: set["lyrics_preview"].string!, numberOfLines: set["number_of_lines"].int!, votesScore: 0, voteStatus: "", editor: editor, lastEdited: set["last_edited"].string!)
                        l.lyrics = set["lyrics"].arrayObject as! [String]
                        
                        var theTimes = [Float]()
                        
                        //TODO: array for times come in as string array, need to change backend, and this might too much for everything at once, needs pagination soon
                        for time in set["times"].arrayObject as! [String] {
                            theTimes.append(Float(time)!)
                        }
                        
                        l.times = theTimes
                        
                        let song = SearchResult(songId: set["song"]["id"].int!, title: set["song"]["title"].string!, artist: set["song"]["artist"].string!, duration: set["song"]["duration"].float!)
                        l.song = song
                        myLyricsSets.append(l)
                    }
                   completion(downloadedTabsSets: myTabsSets, downloadedLyricsSets: myLyricsSets)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    //favorite a song
    class func favoriteTheSong(findable: Findable, completion: ((completed: String) -> Void)) {
        //given a song's title, artist, and duration, we can find all its corresponding tabs
        var parameters = [String: AnyObject]()
        
        parameters = ["title": findable.getTitle(), "artist": findable.getArtist(), "duration": findable.getDuration()]
        
        //user/:id/favorite_a_song body: {"title":"", "artist": "", "duration": ""}
        Alamofire.request(.PUT, jamBaseURL + "/users/\(CoreDataManager.getCurrentUser()!.id)/favorite_a_song" , parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    let result = json["result"].string!
                    completion(completed: result) //either "liked" or "disliked"
                }
                
            case .Failure(let error):
                print("favorite song error: \(error)")
            }
        }
    }
    
    class func getFavorites(completion: (( songs: [SearchResult]) -> Void)) {
        Alamofire.request(.GET, jamBaseURL + "/users/\(CoreDataManager.getCurrentUser()!.id)/favorite_songs").responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    var songs = [SearchResult]()
                    for song in json["users"].array! {
                        let s = SearchResult(title: song["title"].string!, artist: song["artist"].string!, duration: song["duration"].float!)
                        songs.append(s)
                    }
                    completion(songs: songs)
                }
            case .Failure(let error):
                print("favorite song error: \(error)")
            }
        }
    }
    
    //get id and url
    class func getSongInformation(findable: Findable, completion: ((id: Int, soundwaveUrl: String) -> Void)) {
        var parameters = [String: AnyObject]()
        
        parameters = ["title": findable.getTitle(), "artist": findable.getArtist(), "duration": findable.getDuration()]
   
        Alamofire.request(.GET, jamBaseURL + "/get_soundwave_url", parameters: parameters).responseJSON { response in

            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    let id = json["song_information"]["id"].int!
                    let url = json["song_information"]["soundwave_url"].string!
                    completion(id: id, soundwaveUrl: url)
                }
            case .Failure(let error):
                print("Get soundwave error: \(error)")
            }
        }
    }
    
    class func updateSoundwaveUrl(songId: Int, url: String) {
        let parameters = ["soundwave_url": url]
        
        Alamofire.request(.PUT, jamBaseURL + "/songs/\(songId)", parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    _ = JSON(data)
                    print("update soundwave url success")
                }
            case .Failure(let error):
                print("Update soundwave error: \(error)")
            }
        }
    }
    
    class func getTopSongs(completion: (( songs: [SearchResult]) -> Void)) {
        Alamofire.request(.GET, jamBaseURL + "/get_top_songs").responseJSON { response in
            switch response.result {
            case .Success:
                if let data = response.result.value {
                    let json = JSON(data)
                    var results = [SearchResult]()
                    for song in json["songs"].array! {
                        
                        let result = SearchResult(songId: song["id"].int!, trackId: song["track_id"].int!, title: song["title"].string!, artist: song["artist"].string!, duration: song["duration"].float!, previewUrl: song["preview_url"].string!, trackViewUrl: song["store_link"].string!, artwork: song["artwork_url"].string!)

                        results.append(result)
                    }
                    completion(songs: results)
                }
            case .Failure(let error):
                print("favorite song error: \(error)")
            }
        }
    }

    class func sendPasswordResetInstructions(email: String, completion: ((message: String) -> Void)) {
        
        Alamofire.request(.POST, jamBaseURL + "/password_resets", parameters: ["email": email], encoding: .JSON).responseJSON
            {
                response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        completion(message: json["message"].string!)
                    }
                case .Failure(_):
                    print("Failed to get a password reset request")
                }
        }
    }

}


