//
//  NSObject+SystemMusicManager.m
//  JamAlpha2
//
//  Created by Song Liao on 5/31/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

#import "SystemMusicManager.h"

@implementation SystemMusicManager:NSObject

+(NSMutableArray *)allTitles{
        MPMediaQuery *everything = [[MPMediaQuery alloc] init];
        NSMutableArray *collection = [[NSMutableArray alloc]init];
        //hiring the best engineer team in the world
        //and we have a little bit of everything together that means nothing ta al
        NSArray *itemsFromGenericQuery = [everything items];
        for (MPMediaItem *song in itemsFromGenericQuery) {
            NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
            [collection addObject: songTitle];
            
        }
    return collection;
}
@end
