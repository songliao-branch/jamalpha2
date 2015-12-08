//
//  AWSS3TransferManager.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/30/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import AWSS3

class AWSS3Manager: NSObject {
    
    var uploadRequests: Array<AWSS3TransferManagerUploadRequest?> = Array<AWSS3TransferManagerUploadRequest?>()
    var uploadFileURLs: Array<NSURL?> = Array<NSURL?>()
    
    func addUploadRequestToArray(sender: UIImage, style: String, email: String) -> String {
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let dateString = formatter.stringFromDate(NSDate()).replace(" ", replacement: "-").replace(":", replacement: "-").replace(",", replacement: "-").replace("/", replacement: "-")
    
        let fileName = ((randomStringWithLength(4) as String) + "-" + dateString + "-" + email  + "-" + style).stringByAppendingString(".png")//NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".png")
        let filePath = ((NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("upload") as NSString).stringByAppendingPathComponent(fileName)
        let imageData = UIImagePNGRepresentation(sender)
        imageData!.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = NSURL(fileURLWithPath: filePath)
        uploadRequest.key = fileName
        uploadRequest.bucket = S3BucketName
        
        self.uploadRequests.append(uploadRequest)
        self.uploadFileURLs.append(nil)
        
        return fileName
    }
    
    func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {

        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch (errorCode) {
                        case .Cancelled, .Paused:
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                // reload data
                                
                            })
                            break;
                            
                        default:
                            print("upload() failed: [\(error)]")
                            break;
                        }
                    } else {
                        print("upload() failed: [\(error)]")
                    }
                } else {
                    print("upload() failed: [\(error)]")
                }
            }
            
            if let exception = task.exception {
                print("upload() failed: [\(exception)]")
            }
            
            if task.result != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let index = self.indexOfUploadRequest(self.uploadRequests, uploadRequest: uploadRequest) {
                        self.uploadRequests[index] = nil
                        self.uploadFileURLs[index] = uploadRequest.body
                    }
                })
            }
            return nil
        }
        
    }
    
    
    func downloadImage(url: String, completion: ((image: UIImage) -> Void)) {
        
        if url == "" {
            completion(image: UIImage(named: "kitten_profile")!)
            return
        }
        
        let request = AWSS3TransferManagerDownloadRequest()
        request.bucket = S3BucketName
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

    func indexOfUploadRequest(array: Array<AWSS3TransferManagerUploadRequest?>, uploadRequest: AWSS3TransferManagerUploadRequest?) -> Int? {
        for (index, object) in array.enumerate() {
            if object == uploadRequest {
                return index
            }
        }
        return nil
    }

    func randomStringWithLength (len : Int) -> NSString {
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
