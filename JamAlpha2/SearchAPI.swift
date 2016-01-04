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


class SearchAPI: NSObject {
    var searchResults: [SearchResult]!
    var musicRequest: Request?
    
    func webSearchSong(searchText: String, searchResultTableView:UITableView?=nil, completion: ((data: SwiftyJSON.JSON) -> Void)?) {
        if searchText.characters.count < 1 {
            return
        }
        musicRequest?.cancel()
        searchResults = [SearchResult]()
        if(searchResultTableView != nil){
            searchResultTableView!.reloadData()
        }
        
        
        musicRequest = Alamofire.request(.GET, APIManager.searchBaseURL, parameters: APIManager.searchParameters(searchText)).responseJSON { response in
            if let data = response.result.value {
                if(searchResultTableView != nil){
                    self.addDataToResults(JSON(data),searchResultTableView:searchResultTableView!)
                }else{
                    self.addDataToResults(JSON(data))
                }
                completion?(data: JSON(data))
            } else {
                print("something went wrong with search \(response.result.error)")
                completion?(data: nil)
            }
        }
    }
    
    
    func addDataToResults(data: SwiftyJSON.JSON, searchResultTableView:UITableView?=nil){
        if(searchResultTableView != nil){
            for item in data["results"].array! {
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
            
            dispatch_async(dispatch_get_main_queue()) {
                searchResultTableView!.reloadData()
            }
        }else {
            let item = data["results"].array![0]
            let searchResponse = SearchResult(wrapperType: item["wrapperType"].string!, kind: item["kind"].string!)
            
            if let artwork = item["artworkUrl100"].string {
                let newString = artwork.replace("100x100", replacement: "300x300")
                searchResponse.artworkUrl100 = newString
            }
            searchResults.append(searchResponse)
        }
 
    }
}