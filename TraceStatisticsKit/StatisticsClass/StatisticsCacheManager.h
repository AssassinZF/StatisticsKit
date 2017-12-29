//
//  StatisticsCacheManager.h
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/28.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EventInfo , ChunkUploadModel;
@interface StatisticsCacheManager : NSObject

@property(nonatomic,strong,readonly)NSMutableArray *eventArray;
@property(nonatomic,strong,readonly)NSMutableArray <ChunkUploadModel *>*waitUpdateData;

+(instancetype)cacheManager;

-(void)saveEventData:(EventInfo *)eventInfo;

-(void)removeWaitUplaodData:(ChunkUploadModel *)uploadData;
@end
