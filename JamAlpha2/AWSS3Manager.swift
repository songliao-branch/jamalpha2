//
//  AWSS3TransferManager.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/30/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//  Refereneces: http://docs.aws.amazon.com/mobile/sdkforios/developerguide/s3transfermanager.html

import Foundation
import AWSS3

let CognitoRegionType = AWSRegionType.USEast1  // e.g. AWSRegionType.USEast1
let DefaultServiceRegionType = AWSRegionType.USEast1 // e.g. AWSRegionType.USEast1
let CognitoIdentityPoolId = "us-east-1:eb3a9f5f-4c55-4e34-b12b-fd64ba59b8f5"
let S3AvatarBucket = "userprofileimagebucket"
let S3SoundwaveBucket = "songsoundwave"


class AWSS3Manager: NSObject {

    enum ImageSize: String {
        case origin = "origin", thumbnail = "thumbnail"
    }
    
    class func uploadImage(image: UIImage, fileName: String, isProfileBucket: Bool) {
        let imageData = UIImagePNGRepresentation(image)
        
         let filePath = ((NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("upload") as NSString).stringByAppendingPathComponent(fileName)
        
        imageData!.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = NSURL(fileURLWithPath: filePath)
        uploadRequest.key = fileName
        uploadRequest.bucket = isProfileBucket ? S3AvatarBucket : S3SoundwaveBucket
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        transferManager.upload(uploadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: {
            (task) -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain {
                    switch error.code {
                    case AWSS3TransferManagerErrorType.Cancelled.rawValue:
                        break
                    case AWSS3TransferManagerErrorType.Paused.rawValue:
                        break
                    default:
                        print("upload error :\(error)")
                        break
                    }
                } else {
                    print("unknown upload error: \(error)")
                }
            }
            
            if let result = task.result {
                let _ = result as! AWSS3TransferManagerUploadOutput
                print("upload success")
            }
            return nil
        })
    }
    

    class func downloadImage(url: String, completion: ((image: UIImage) -> Void)) {
        
        if url == "" {
            completion(image: UIImage(named: "kitten_profile")!)
            return
        }
        
        let request = AWSS3TransferManagerDownloadRequest()
        request.bucket = S3AvatarBucket
        request.key = url
        
        var cachedFiles = [String]()
        //get cached files
        do {
            cachedFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSTemporaryDirectory())
            
        } catch _ {
            print("cannot open temporary directory")
        }
        
        for file in cachedFiles {
            if file == "\(url)" {
                let path = NSTemporaryDirectory().stringByAppendingString("\(file)")
                if let data = NSData(contentsOfURL: NSURL(fileURLWithPath: path)) {
                    completion(image: UIImage(data: data)!)
                }
                return
            }
        }
        
        let l =  NSTemporaryDirectory().stringByAppendingString("\(url)")
        let downloadingFileUrl = NSURL(fileURLWithPath: l)
        request.downloadingFileURL = downloadingFileUrl
        
        AWSS3TransferManager.defaultS3TransferManager().download(request)
            .continueWithBlock({ (task) -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain as String
                    && AWSS3TransferManagerErrorType(rawValue: error.code) == AWSS3TransferManagerErrorType.Paused {
                        print("Download paused.")
                } else {
                    print("download failed: [\(error)]")
                }
            } else if let exception = task.exception {
                print("download failed: [\(exception)]")
            } else {
                
                print("Download success with fileUrl: \(request.downloadingFileURL)")
                if let data = NSData(contentsOfURL: request.downloadingFileURL) {
                    completion(image: UIImage(data: data)!)
                }
            }
            return nil
        })
    }
    
    
    //MARK: Helper methods
    //customize a upload url for each different avatar based on the user email and image size
    class func concatenateFileNameForAvatar(email: String, imageSize: ImageSize) -> String {
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let dateString = formatter.stringFromDate(NSDate()).replace(" ", replacement: "-").replace(":", replacement: "-").replace(",", replacement: "-").replace("/", replacement: "-")
        
        return ((randomStringWithLength(4) as String) + "-" + dateString + "-" + email  + "-" + imageSize.rawValue).stringByAppendingString(".png")
    }
    
    
    class func concatenateFileNameForSoundwave(item: Findable) -> String {
        return (randomStringWithLength(4) as String) + "-" + item.getTitle() + "-" + item.getArtist()
    }
    
    private class func randomStringWithLength (len : Int) -> NSString {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        return randomString
    }
    
}
