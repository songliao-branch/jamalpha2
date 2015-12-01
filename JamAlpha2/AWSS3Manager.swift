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
    
    var downloadRequests: Array<AWSS3TransferManagerDownloadRequest?> = Array<AWSS3TransferManagerDownloadRequest?>()
    var downloadFileURLs: Array<NSURL?> = Array<NSURL?>()
    
    func addRequestToArray(sender: UIImage, style: String, userId: String) -> String {
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let dateString = formatter.stringFromDate(NSDate()).replace(" ", replacement: "-").replace(":", replacement: "-").replace(",", replacement: "-").replace("/", replacement: "-")
    
        let fileName = ((randomStringWithLength(4) as String) + "-" + dateString + "-" + userId  + "-" + style).stringByAppendingString(".png")//NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".png")
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
    
    func addDownloadRequestToArray(sender: String) {
        // Construct the NSURL for the download location.
        let downloadingFilePath: NSString = ((NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("download") as NSString).stringByAppendingPathComponent(sender)
        let downloadingFileURL: NSURL = NSURL(fileURLWithPath:downloadingFilePath as String)
        print(downloadingFileURL)
        // Construct the download request.
        let downloadRequest: AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest.bucket = S3BucketName
        downloadRequest.key = sender
        downloadRequest.downloadingFileURL = downloadingFileURL
        
        self.downloadRequests.append(downloadRequest)
        self.downloadFileURLs.append(nil)
    }
    
    func download(downloadRequest: AWSS3TransferManagerDownloadRequest) {
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        transferManager.download(downloadRequest).continueWithBlock({ (task) -> AnyObject! in
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
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let index = self.indexOfDownloadRequest(self.downloadRequests, downloadRequest: downloadRequest) {
                        self.downloadRequests[index] = nil
                        self.downloadFileURLs[index] = downloadRequest.downloadingFileURL
                    }
                })
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
    
    func indexOfDownloadRequest(array: Array<AWSS3TransferManagerDownloadRequest?>, downloadRequest: AWSS3TransferManagerDownloadRequest?) -> Int? {
        for (index, object) in array.enumerate() {
            if object == downloadRequest {
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
    

    
    // after download the image then able to get the image
    func getImage() -> UIImage {
        if let downloadFileURL = self.downloadFileURLs[0] {
            if let data = NSData(contentsOfURL: downloadFileURL) {
                return UIImage(data: data)!
            }
        }
        return UIImage(named: "kitten_profile")!
    }

}
