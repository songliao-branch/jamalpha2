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

let noiseFloor:Float = -50.0

class SoundWaveView: UIView {
    
    var normalImageView:UIImageView!
    var progressImageView:UIImageView!
    var cropNormalView:UIView!
    var cropProgressView:UIView!
    var normalColorDirty:Bool!
    var progressColorDirty:Bool!
    
    
    var  asset:AVURLAsset!
    var normalColor:UIColor!
    var progressColor:UIColor!
    var progress:CGFloat! = 0
    var antialiasingEnabled:Bool!
    
    var generatedNormalImage:UIImage!
    var generatedProgressImage:UIImage!
    
    var originalSampleBuffer:NSMutableArray?
    
    let songVCSampleRate:CGFloat = 8
    let lineWidth:CGFloat = 3.5
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    override init(frame: CGRect)  {
        super.init(frame: frame)
        self.commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(){
        normalImageView = UIImageView()
        progressImageView = UIImageView()
        cropNormalView = UIView()
        cropProgressView = UIView()
        
        cropNormalView.clipsToBounds = true
        cropProgressView.clipsToBounds = true
        
        cropNormalView.addSubview(normalImageView)
        cropProgressView.addSubview(progressImageView)
        
        self.addSubview(cropNormalView)
        self.addSubview(cropProgressView)
        
        self.normalColor = UIColor.whiteColor()
        self.progressColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
        
        normalColorDirty = false
        progressColorDirty = false
        
        antialiasingEnabled = false
        
    }
    
    
    
     func renderPixelWaveformInContext(context:CGContextRef, halfGraphHeigh:Float, sample:Double, x:CGFloat){
      
        var pixelHeight:Float = halfGraphHeigh * Float(( 1 - sample / Double(noiseFloor)))
        
        if( pixelHeight < 0){
            pixelHeight = 0
        }
        CGContextMoveToPoint(context, x, CGFloat(halfGraphHeigh - pixelHeight))
        CGContextAddLineToPoint(context, x, CGFloat(halfGraphHeigh))
        CGContextStrokePath(context)
    }
    
     func getSampleDateFromAudio(asset:AVAsset?, size:CGSize){
        self.registerBackgroundTask()
        self.originalSampleBuffer = NSMutableArray()
        
        if(asset != nil ){
            let pixelRatio:CGFloat = UIScreen.mainScreen().scale
            
            let widthInPixels:CGFloat = size.width*pixelRatio
            
            let reader: AVAssetReader = try! AVAssetReader(asset: asset!)
            
            let audioTrackArray:NSArray = asset!.tracksWithMediaType(AVMediaTypeAudio)
            
            if(audioTrackArray.count != 0){
                let songTrack:AVAssetTrack = audioTrackArray[0] as! AVAssetTrack
                
                var outputSettingsDict:NSDictionary  = NSDictionary()
                
                outputSettingsDict=[
                    AVFormatIDKey:NSNumber(int:Int32(kAudioFormatLinearPCM)),
                    AVLinearPCMBitDepthKey:NSNumber(int: 16),
                    AVLinearPCMIsBigEndianKey:NSNumber(bool: false),
                    AVLinearPCMIsFloatKey:NSNumber(bool: false),
                    AVLinearPCMIsNonInterleaved:NSNumber(bool: false)]
                
                let output: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: songTrack, outputSettings: outputSettingsDict as? [String : AnyObject])
                
                reader.addOutput(output)

                var channelCount: UInt32!
                let formatDesc:NSArray = songTrack.formatDescriptions
               
                
                for(var i:Int = 0; i < formatDesc.count; i++) {
                    
                    let item:CMAudioFormatDescriptionRef = formatDesc[i] as! CMAudioFormatDescriptionRef
                    let fmtDesc:AudioStreamBasicDescription? = CMAudioFormatDescriptionGetStreamBasicDescription(item).memory
                    
                    
                    //CMAudioFormatDescriptionGetStreamBasicDescription (item);
                    if fmtDesc != nil
                    {
                        channelCount = fmtDesc!.mChannelsPerFrame
                        
                    }
                }
                
                let bytesPreInputSample:UInt32 = 2 * channelCount
                let totalSamples: UInt64 = UInt64(asset!.duration.value)
                var samplesPerPixel:NSInteger = NSInteger(CGFloat(totalSamples)  / widthInPixels)
                samplesPerPixel = samplesPerPixel < 1 ? 1 : samplesPerPixel
                
                reader.startReading()

                var bigSample:Double = 0
                var bigSampleCount:NSInteger = 0
                let data:NSMutableData = NSMutableData(length: 32768)!
                
                //var currentX:CGFloat = 0

                while (reader.status == AVAssetReaderStatus.Reading)
                {
                    let sampleBufferRef:CMSampleBufferRef? = output.copyNextSampleBuffer()

                    
                    if (sampleBufferRef != nil)
                    {
                        let blockBufferRef:CMBlockBufferRef? = CMSampleBufferGetDataBuffer(sampleBufferRef!);
                        let bufferLength:size_t = CMBlockBufferGetDataLength(blockBufferRef!)
                        
                        if(data.length < bufferLength){
                            data.length = bufferLength
                        }
                        CMBlockBufferCopyDataBytes(blockBufferRef!, 0, bufferLength, data.mutableBytes)
                        
                        var samples:UnsafeMutablePointer<Int16> = UnsafeMutablePointer<Int16>(data.mutableBytes)
                        let sampleCount:Int = (Int(bufferLength) / Int(bytesPreInputSample))
                        
                        for(var i:Int = 0; i < sampleCount; i++){
                            
                            var sample:Float32 = Float32(samples.memory)
                            samples = samples.successor()
                           
                            sample = 20.0 * log10 ((sample < 0 ? 0 - sample : sample) / 32767.0)
                            
                            if(sample == -Float.infinity || sample <= -50){
                                sample = -50
                                
                            }else{
                                if(sample >= 0){
                                    sample = 0
                                }
                            }
                            
                            for(var j:Int = 1; j < Int(channelCount); j++){
                                samples = samples.successor()
                            }
                            
                            
                            
                            bigSample += Double(sample)
                            bigSampleCount++
                            
                            
                            if(bigSampleCount == Int(songVCSampleRate)*samplesPerPixel){
                                let averageSample:Double = bigSample / Double(bigSampleCount)
                                self.originalSampleBuffer!.addObject(averageSample)
                                bigSample = 0
                                bigSampleCount = 0
                                
                            }
                        }
                        CMSampleBufferInvalidate(sampleBufferRef!)
                    }
                }
            }
        }
        if backgroundTask != UIBackgroundTaskInvalid {
                endBackgroundTask()
        }
    }
    
    // render sound wave from the NSMutableArray we saved in SongViewController
    func renderWavefromForSongVC(context:CGContextRef, color:UIColor, size:CGSize, antialiasingEnabled:Bool){
        let pixelRatio:CGFloat = UIScreen.mainScreen().scale
        
        let heightInPixels:CGFloat = size.height*pixelRatio
        
        CGContextSetAllowsAntialiasing(context, antialiasingEnabled)
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetFillColorWithColor(context, color.CGColor)
        
        let halfGraphHeight:Float = Float(heightInPixels) / 2
        
        var currentX:CGFloat = 0
      //////////////////////////////////////////////////////////////////////////
      //generate fake soundwave
      if originalSampleBuffer == nil || self.originalSampleBuffer!.count == 0 {
        let range = Int(size.width/40)
        for i in 0..<Int(size.width/4)
        {
          var fakeSample = Double(arc4random_uniform(5)+18)
          if i < range {
            fakeSample = Double(arc4random_uniform(6)+25)
          } else if i >= range && i <= 2*range {
            fakeSample = Double(arc4random_uniform(8)+20)
          } else if i > 9 * range {
            fakeSample = Double(arc4random_uniform(6)+25)
          } else if i > 8 * range && i <= 9 * range {
            fakeSample = Double(arc4random_uniform(8)+20)
          }
          if i == Int(size.width/4) - 2 {
            fakeSample = Double(arc4random_uniform(5)+30)
          }
          if i == Int(size.width/4) - 1 {
            fakeSample = Double(arc4random_uniform(5)+40)
          }
          
          renderPixelWaveformInContext(context, halfGraphHeigh: halfGraphHeight, sample: -fakeSample, x: currentX*self.songVCSampleRate+1.5)
          
          currentX++
        }
        return
      }
      //////////////////////////////////////////////////////////////////////////
      for averageSample in self.originalSampleBuffer!
      {
        renderPixelWaveformInContext(context, halfGraphHeigh: halfGraphHeight, sample: averageSample as! Double, x: currentX*self.songVCSampleRate+1.5)
          
          currentX++
      }
    }

    /*******************************************************/

  
    func generateWaveformImage(color:UIColor, size:CGSize, antialiasingEnabled:Bool) -> UIImage{
        let ratio:CGFloat = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width * ratio, size.height * ratio), false, 1);
        
        self.renderWavefromForSongVC(UIGraphicsGetCurrentContext()!, color: color, size: size, antialiasingEnabled: antialiasingEnabled)
            
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image;
    }
  
    
    
    class func recolorizeImage(image:UIImage, color:UIColor) -> UIImage{
        let imageRect:CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextTranslateCTM(context, 0.0, image.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextDrawImage(context, imageRect, image.CGImage)
        
        color.set()
        
        UIRectFillUsingBlendMode(imageRect, CGBlendMode.SourceAtop)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // from exisitng NSData we saved in the database
    func setWaveFormFromData(data: NSData) {
        self.generatedNormalImage = UIImage(data: data)
        self.normalImageView.image = generatedNormalImage
        normalColorDirty = false
        
        self.generatedProgressImage = SoundWaveView.recolorizeImage(self.generatedNormalImage, color: progressColor)
        self.progressImageView.image = generatedProgressImage
    }
  
    func setWaveFormFromImage(image: UIImage) {
      self.generatedNormalImage = image
      self.normalImageView.image = generatedNormalImage
      normalColorDirty = false
      
      self.generatedProgressImage = SoundWaveView.recolorizeImage(self.generatedNormalImage, color: progressColor)
      self.progressImageView.image = generatedProgressImage
    }
  
    func generateWaveforms(){
        
        let rect:CGRect = self.bounds
            
            self.generatedNormalImage = self.generateWaveformImage(self.normalColor, size: CGSizeMake(rect.size.width, rect.size.height), antialiasingEnabled: self.antialiasingEnabled)
            self.normalImageView.image = generatedNormalImage
            normalColorDirty = false
    }
    
    func applyProgressToSubviews(){
        let bs:CGRect = self.bounds
        let progressWidth:CGFloat = bs.size.width * progress
        cropProgressView.frame = CGRectMake(0, 0, progressWidth, bs.size.height);
        cropNormalView.frame = CGRectMake(progressWidth, 0, bs.size.width - progressWidth, bs.size.height);
        normalImageView.frame = CGRectMake(-progressWidth, 0, bs.size.width, bs.size.height);
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bs:CGRect = self.bounds;
        normalImageView.frame = bs;
        progressImageView.frame = bs;
        
//        // If the size is now bigger than the generated images
//        if (bs.size.width > self.generatedNormalImage.size.width) {
//            self.generatedNormalImage = nil;
//            self.generatedProgressImage = nil;
//        }
        
        self.applyProgressToSubviews()
    }
    
    
    func SetNormalColor(normalColor:UIColor)
    {
       self.normalColor = normalColor
        self.normalColorDirty = true
        self.setNeedsDisplay()
    }
    
    func SetProgressColor(progressColor:UIColor )
    {
        self.progressColor = progressColor;
        self.progressColorDirty = true
        self.setNeedsDisplay()
    }
    
    
    func SetSoundURL(soundURL:NSURL)
    {
        self.asset = AVURLAsset(URL: soundURL, options: nil)
        let rect:CGRect = self.bounds
        self.getSampleDateFromAudio(self.asset, size: CGSizeMake(rect.size.width, rect.size.height))
    }
    
    func setProgress(progress:CGFloat)
    {
        self.progress = progress;
        self.applyProgressToSubviews()
    }
    
    func GeneratedNormalImage() -> UIImage
    {
        return self.normalImageView.image!
    }
    
    func SetGeneratedNormalImage(generatedNormalImage:UIImage)
    {
        self.normalImageView.image = generatedNormalImage;
    }
    
    func GeneratedProgressImage() -> UIImage
    {
        return self.progressImageView.image!
    }

}

extension SoundWaveView{
    func registerBackgroundTask() {
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            [unowned self] in
            self.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        //NSLog("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
}

