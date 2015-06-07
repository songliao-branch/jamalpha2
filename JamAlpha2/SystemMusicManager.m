//
//  NSObject+SystemMusicManager.m
//  JamAlpha2
//
//  Created by Song Liao on 5/31/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

#import "SystemMusicManager.h"

#define isMusic(x) (x & MPMediaTypeMusic)
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
           
            NSInteger type = [[song valueForProperty:MPMediaItemPropertyMediaType] integerValue];
            if (isMusic(type)){
                
            }
            
            NSLog(@"Song: %@ has media type %@",songTitle, [song valueForProperty:MPMediaItemPropertyMediaType]);
            
        }
    
//    MPMediaPropertyPredicate *titlePredicate = [MPMediaPropertyPredicate predicateWithValue:@"give me love" forProperty:MPMediaItemPropertyTitle comparisonType:MPMediaPredicateComparisonContains];
//    
//    NSPredicate *test = [NSPredicate predicateWithFormat:@"title contains[cd] OR albumTitle contains[cd] %@ OR artist contains[cd] %@",@"",@"",@""];
//    NSArray *filteredTitle = [[everything items] filteredArrayUsingPredicate:test];
//    
//    for (MPMediaItem *song in filteredTitle) {
//        
//    }
    
    return collection;
}
@end
