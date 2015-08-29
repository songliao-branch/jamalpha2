//
//  SoundWaveView.swift
//  waveForm
//
//  Created by Anne Dong on 7/19/15.
//  Copyright (c) 2015 Anne Dong. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation


class FVSoundWaveView: UIView {
    
    var soundURL:NSURL!
    var progress:Float!
    var waveColor:UIColor!
    var coverColor:UIColor!
    var progressColor:UIColor!
    var drawSpaces:Bool!
    var waveImageView:UIImageView?
    //var coverImageView:UIImageView?
    var progressImageView:UIImageView?
    var touched:Bool?
    var touch:UITapGestureRecognizer?
    
    
    
    
    override init(frame: CGRect)  {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.waveColor = UIColor.whiteColor()
        //self.coverColor = UIColor.blackColor().colorWithAlphaComponent(1)
        self.progressColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
        
        drawSpaces = true
        touched = false
        
        layoutSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    class Tint:UIImage {
        
    
        
        func tintedImageColor(color:UIColor) -> UIImage{
            var imageSize:CGSize = CGSizeMake(self.size.width/2, self.size.height/2)
            UIGraphicsBeginImageContextWithOptions(imageSize, false, self.scale)
            //println(self.size)
            var context:CGContextRef = UIGraphicsGetCurrentContext()
            var area:CGRect = CGRectMake(0, -(self.size.height/4), self.size.width/2, self.size.height/2)
            
            CGContextScaleCTM(context, 1, -1)
            CGContextTranslateCTM(context, 0, -area.size.height/2)
            
            CGContextSaveGState(context)
            CGContextClipToMask(context, area, self.CGImage)
            
            color.set()
            
            CGContextFillRect(context, area)
            CGContextRestoreGState(context)
            CGContextSetBlendMode(context, kCGBlendModeMultiply)
            CGContextDrawImage(context, area, self.CGImage)
            
            var colorizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return colorizedImage
        }
    }

    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if(waveImageView == nil){
            
            waveImageView = UIImageView(frame: self.bounds)

           // coverImageView = UIImageView(frame: self.bounds)
            progressImageView = UIImageView(frame: self.bounds)
            
            waveImageView!.contentMode = UIViewContentMode.Left
            //coverImageView!.contentMode = UIViewContentMode.Left
            progressImageView!.contentMode = UIViewContentMode.Left
            waveImageView!.clipsToBounds = true
            //coverImageView!.clipsToBounds = true
            progressImageView!.clipsToBounds = true
            
            self.addSubview(waveImageView!)
            //self.addSubview(coverImageView!)
            self.addSubview(progressImageView!)
        }
    }
    
    func render(){
        
       
                var asset:AVURLAsset = AVURLAsset(URL: self.soundURL, options: nil)
                var renderedImage:UIImage = self.renderWaveImageFromAudioAsset(asset)
                var renderedImageTemp:Tint = Tint(CGImage: renderedImage.CGImage)!
                self.waveImageView!.image = renderedImage
                self.progressImageView!.image = renderedImageTemp.tintedImageColor(self.progressColor)
                
                self.waveImageView!.width = renderedImage.size.width
                 self.waveImageView!.left = (self.width - renderedImage.size.width)/2
            
        //coverImageView!.image = renderedImageTemp.tintedImageColor(coverColor)
        
        //coverImageView!.width = waveImageView!.width
        //coverImageView!.left = waveImageView!.left
        progressImageView!.left = waveImageView!.left
        progressImageView!.width = 0 //adjust the length of the progress of the vedio
    }
    
    func drawImageFromSamples(samples:UnsafePointer<Int16>, maxValue:Int16, sampleCount:NSInteger) -> UIImage{
        //sampleCount as Float
        //println(self.height)
        var imageSize:CGSize = CGSizeMake(CGFloat(sampleCount) * (drawSpaces! ? 2.0 : 0) , self.height)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, self.backgroundColor?.CGColor)
        CGContextSetAlpha(context, 1.0) ///set alpha
        
        var rect:CGRect! = CGRect()
        rect!.size = imageSize
        rect!.origin.x = 0
        rect!.origin.y = 0
        
        var waveColor:CGColorRef = self.waveColor.CGColor
        
        CGContextFillRect(context, rect)
        CGContextSetLineWidth(context, 1.0)
        
        
        var channelCenterY:Float = Float(imageSize.height/2)
        var sampleAdjustmentFactor:Float = Float(Float(imageSize.height)/(Float(maxValue)))
        
       
        
        for(var i:Int = 0; i < sampleCount; i++){
            var val:Float = Float(samples.advancedBy(i).memory)
            //println(val)
            val = abs(val*sampleAdjustmentFactor)
            
            if(Int(val) == 0)
            {
                val=1.0
            }
            
           CGContextMoveToPoint(context, CGFloat(i * (drawSpaces! ? 2 : 1)), CGFloat(channelCenterY-val/2.0))
            CGContextAddLineToPoint(context, CGFloat(i * (drawSpaces! ? 2 : 1)), CGFloat(channelCenterY))
            CGContextSetStrokeColorWithColor(context, waveColor);
            CGContextStrokePath(context);
        }
        
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func renderWaveImageFromAudioAsset(songAsset:AVURLAsset) -> UIImage{
        var error:NSError?
        
        
        var reader:AVAssetReader = AVAssetReader(asset: songAsset, error:&error)
        
        var songTrack:AVAssetTrack = songAsset.tracks[0] as! AVAssetTrack
        
        var outputSettingsDict:NSDictionary  = NSDictionary()
        
        outputSettingsDict=[
            AVFormatIDKey:NSNumber(int:Int32(kAudioFormatLinearPCM)),
            AVNumberOfChannelsKey:NSNumber(int: 1),
            AVLinearPCMBitDepthKey:NSNumber(int: 8),
            AVLinearPCMIsBigEndianKey:NSNumber(bool: false),
            AVLinearPCMIsFloatKey:NSNumber(bool: false),
            AVLinearPCMIsNonInterleaved:NSNumber(bool: false)];
        
        var output:AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: songTrack, outputSettings: outputSettingsDict as [NSObject : AnyObject])
        
        reader.addOutput(output)
        
        var sampleRate:UInt32!
        var channelCount:UInt32!
        
        var formatDesc:NSArray = songTrack.formatDescriptions;
        
        for (var i:Int = 0; i < formatDesc.count; ++i)
        {
            var item:CMAudioFormatDescriptionRef = formatDesc[i] as! CMAudioFormatDescriptionRef
            let fmtDesc:AudioStreamBasicDescription? = CMAudioFormatDescriptionGetStreamBasicDescription(item).memory
            
            
            //CMAudioFormatDescriptionGetStreamBasicDescription (item);
            if fmtDesc != nil
            {
                channelCount = fmtDesc!.mChannelsPerFrame
                
            }
        }
        
        var bytesPerSample:UInt32 = 2 * channelCount
        var maxValue:Int16 = 0
        
        var fullSongData:NSMutableData = NSMutableData()
        
        reader.startReading()
        
        var totalBytes:UInt64 = 0
        var totalLeft:Int64 = 0
        var totalRight:Int64 = 0
        var sampleTally:NSInteger = 0
        
        var samplesPerPixel:NSInteger = 100 // pretty enougth for most of ui and fast
        
        var buffersCount:Int = 0
        while (reader.status == AVAssetReaderStatus.Reading)
        {
            var trackOutput:AVAssetReaderTrackOutput = reader.outputs[0] as! AVAssetReaderTrackOutput
            var sampleBufferRef:CMSampleBufferRef? = trackOutput.copyNextSampleBuffer()
            
            if (sampleBufferRef != nil)
            {
                var blockBufferRef:CMBlockBufferRef? = CMSampleBufferGetDataBuffer(sampleBufferRef);
                
                var length:size_t = CMBlockBufferGetDataLength(blockBufferRef)
                totalBytes += UInt64(length)
                
                autoreleasepool
                {
                    var data:NSMutableData = NSMutableData(length: Int(length))!
                    CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes)
            
                    var samples:UnsafeMutablePointer<Int16> = UnsafeMutablePointer<Int16>(data.mutableBytes)
                    var sampleCount:Int = (Int(length) / Int(bytesPerSample))
                    
                    for (var i:Int = 0; i < sampleCount; i++)
                    {
                        var left:Int16? = samples.memory
                        samples = samples.successor()
                        
                        totalLeft += Int64(left!)
                        //println(left)
                        
                        var right:Int16?
                        
                        if (channelCount == 2)
                        {
                            right = (samples.memory)
                            samples = samples.successor()
                           // println(right)
                            
                            totalRight += Int64(right!)
                        }
                        
                        sampleTally++
                        
                        if (sampleTally > samplesPerPixel)
                        {
                            //println(totalLeft)
                            
                            var temp:Int64 = totalLeft / Int64(sampleTally)
                            
                            left = Int16(temp)
                            
                            
                            if (channelCount == 2)
                            {
                                
                                var temp:Int64 = totalRight / Int64(sampleTally)
                                
                                right = Int16(temp)
                            }
                            
                            var val:Int16
                            
                            if(right != nil){
                                
                                val = right!
                                //val = 1
                            }else{
                                val = left!
                            }
                            
                           
                            
                            fullSongData.appendBytes(&val, length: sizeofValue(val))
                            
                            totalLeft = 0;
                            totalRight = 0;
                            sampleTally = 0;
                        }
                    }
                    CMSampleBufferInvalidate(sampleBufferRef);
                                    }
            }
            
            buffersCount++;
        }
        
        var adjustedSongData:NSMutableData = NSMutableData()
        
        var sampleCount:Int = (fullSongData.length / 2)  // sizeof(SInt16)
        
        
        var adjustFactor:Int = Int(ceilf( Float(sampleCount) / (Float(self.width) / (drawSpaces! ? 2.0 : 1.0))))
        
        
        var samples:UnsafeMutablePointer<Int16> = UnsafeMutablePointer<Int16>(fullSongData.mutableBytes)
        
        var m:Int = 0
        
        while (m < sampleCount)
        {
            var valTemp:Int = 0
            var val:Int16 = 0 ;
            
            for (var j:Int = 0; j < adjustFactor; j++)
            {
                
                valTemp += Int(samples.advancedBy(m+j).memory)
                
                if valTemp <= Int(Int16.max) && valTemp >= Int(Int16.min)
                {
                    val = Int16(valTemp)
                }
               
            }
            
        
            if (abs(val) > maxValue)
            {
                maxValue = abs(val);
            }
            adjustedSongData.appendBytes(&valTemp, length:sizeofValue(val))
            
            //println(sizeofValue(val))
            
            m = m + adjustFactor;
        }
        
        sampleCount = adjustedSongData.length / 2;
        
        if (reader.status == AVAssetReaderStatus.Completed)
        {
            //var image:UIImage = self.drawImageFromSamples(Int16(adjustedSongData.bytes), maxValue:maxValue, sampleCount:sampleCount)
            //println( adjustedSongData.bytes)
            
            var image:UIImage = self.drawImageFromSamples(UnsafePointer<Int16>(adjustedSongData.bytes), maxValue: maxValue, sampleCount: sampleCount-1)
            return image;
        }
        return UIImage()
        
    }
    

    
    func SetSoundURL(soundURL:NSURL){
        self.soundURL = soundURL
        self.render()
    }
    
    func setProgress(progress:CGFloat) {

            self.progressImageView!.frame = CGRectMake(self.waveImageView!.left, 0 ,  progress, self.height)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
