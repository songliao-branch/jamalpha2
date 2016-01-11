//
//  TunerManager.h
//  aaa
//
//  Created by Jun Zhou on 1/10/16.
//  Copyright © 2016 myStride. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#ifndef TunerManager_h
#define TunerManager_h
@interface TunerManager: NSObject
+ (void)initialTuner;
+ (void)initMomuAudio;
+ (void)deinitialTuner;
+ (Float32)getMaxHZ;
@end
#endif /* TunerManager_h */
