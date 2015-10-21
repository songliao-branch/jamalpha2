//
//  API.swift
//  JamAlpha2
//  Created by Song Liao on 8/31/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//  iTunes search api

import UIKit
import Alamofire

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

//mixTerm, genreIndex, artistTerm, composerTerm, albumTerm, ratingIndex, songTerm
enum Attribute: String {
    case songTerm = "songTerm"
    case artistTerm = "artistTerm"
}
struct API {
    enum Router: URLRequestConvertible {
        static let baseURLString = "https://itunes.apple.com"
        
        case Term(String)
        //case TermAttribute(String, Attribute) //search term and entity(e.g.)
        var URLRequest: NSMutableURLRequest {
            
            typealias Path = (String, [String: AnyObject])
            
            let thePath: Path = {
                switch self {
                    // i.e. https://itunes.apple.com/search?term=ed+sheeran
                case .Term(let term):
                    let params = ["term":"\(term)", "limit":"20", "media":"music"] //default limit is 50
                    return ("/search", params) //empty dictionary
                }
            }()
            
            let URL = NSURL(string: Router.baseURLString)
            let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(thePath.0))
            let encoding = Alamofire.ParameterEncoding.URL
            return encoding.encode(URLRequest, parameters: thePath.1).0
        }
    }
}