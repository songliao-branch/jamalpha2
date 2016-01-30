//
//  SearchAPI.swift
//  JamAlpha2
//
//  Created by FangXin on 1/4/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import UIKit
import Alamofire
import Haneke
import SwiftyJSON


class SearchResult: NSObject {
    
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


class SearchAPI: NSObject {

    enum ImageSize: String {
        case Thumbnail = "80x80", Large = "300x300"
    }
    
    static var musicRequest: Request?
    //MARK: iTunes search
    static let searchBaseURL = "https://itunes.apple.com/search"
    
    class func searchSong(searchText: String, completion: ((results: [SearchResult]) -> Void)) {
        if searchText.characters.count < 1 {
            let searchResults = [SearchResult]()
            completion(results: searchResults)
            return
        }
        musicRequest?.cancel()
        var searchResults = [SearchResult]()
        
        let parameters = ["term":"\(searchText)", "limit":"30", "media":"music"]
        musicRequest = Alamofire.request(.GET, searchBaseURL, parameters: parameters).responseJSON { response in
            if let data = response.result.value {
                
                let json = JSON(data)
                
                for item in json["results"].array! {
                    let searchResponse = SearchResult(wrapperType: item["wrapperType"].string!, kind: item["kind"].string!)
                    
                    if let trackId = item["trackId"].number {
                        searchResponse.trackId = Int(trackId)
                    }
                    if let trackName = item["trackName"].string {
                        searchResponse.trackName = trackName
                    }
                    if let artistName = item["artistName"].string {
                        searchResponse.artistName = artistName
                    }
                    if let collectionName = item["collectionName"].string {
                        searchResponse.collectionName = collectionName
                    }
                    if let artwork = item["artworkUrl100"].string {
                        let newString = artwork.replace("100x100", replacement: "300x300")
                        searchResponse.artworkUrl100 = newString
                    }
                    if let preview = item["previewUrl"].string {
                        searchResponse.previewUrl = preview
                    }
                    if let trackViewUrl = item["trackViewUrl"].string {
                        searchResponse.trackViewUrl = trackViewUrl
                    }
                    
                    if let trackTimeMillis = item["trackTimeMillis"].number {
                        searchResponse.trackTimeMillis = Float(trackTimeMillis)/1000
                    }
                    
                    searchResults.append(searchResponse)
                }
                
                completion(results: searchResults)
            }
        }
    }
    

    class func getBackgroundImageForSong(searchText: String, imageSize: ImageSize, completion: ((image: UIImage) -> Void)) {
        if searchText.characters.count < 1 {
            completion(image: UIImage(named: "liwengbg")!)
            return
        }
        musicRequest?.cancel()
        
        let parameters = ["term":"\(searchText)", "limit":"1", "media":"music"]
        
        musicRequest = Alamofire.request(.GET, searchBaseURL, parameters: parameters).responseJSON { response in
            if let data = response.result.value {
                
                let json = JSON(data)
                
                if json["resultCount"] > 0 {
                    let firstValue = json["results"].array![0]
                    let searchResponse = SearchResult(wrapperType: firstValue["wrapperType"].string!, kind: firstValue["kind"].string!)
                    
                    if let artwork = firstValue["artworkUrl100"].string {
                        let newString = artwork.replace("100x100", replacement: imageSize.rawValue)
                        searchResponse.artworkUrl100 = newString
                        
                        let url = NSURL(string: newString)!
                        let fetcher = NetworkFetcher<UIImage>(URL: url)
                        let cache = Shared.imageCache
                        cache.fetch(fetcher: fetcher).onSuccess { image in
                            completion(image: image)
                        }
                    }
                } else {
                    completion(image: UIImage(named: "liwengbg")!)
                }
            }
        }
    }

}