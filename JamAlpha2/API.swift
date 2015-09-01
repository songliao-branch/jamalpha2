//
//  API.swift
//  JamAlpha2
//  Created by Song Liao on 8/31/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//  iTunes search api

import UIKit
import Alamofire

extension Alamofire.Request {
    public static func imageResponseSerializer() -> GenericResponseSerializer<UIImage> {
        return GenericResponseSerializer { request, response, data in
            if data == nil {
                return (nil, nil)
            }
            let image = UIImage(data: data!)
            return (image, nil)
        }
    }
    
    public func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self {
        return response(responseSerializer: Request.imageResponseSerializer(), completionHandler: completionHandler)
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
        case TermAttribute(String, Attribute) //search term and entity(e.g.)
        var URLRequest: NSURLRequest {
            let (path: String, parameters: [String: AnyObject]) = {
                switch self {
                    // i.e. https://itunes.apple.com/search?term=ed+sheeran
                    case .Term(let term):
                        var params = ["term":"\(term)", "limit":"10"] //default limit is 50
                        return ("/search", params) //empty dictionary
               
                case .TermAttribute(let term, let attribute):
                    var params = ["term": "\(term)", "attribute": "\(attribute.rawValue)", "limit":"10"]
                    return ("/search", params)
                    }
                }()
            let URL = NSURL(string: Router.baseURLString)
            let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            let encoding = Alamofire.ParameterEncoding.URL
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
}