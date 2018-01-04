//
//  StatisticsCacheManager.h
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/28.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EventModel , ChunkUploadModel;
@interface StatisticsCacheManager : NSObject

@property(nonatomic,strong,readonly)NSMutableArray *eventArray;
@property(nonatomic,strong,readonly)NSMutableArray <ChunkUploadModel *>*waitUpdateData;
+(instancetype)cacheManager;


/**
 搜集事件并且缓存

 @param eventInfo 事件数据 model
 */
-(void)saveEventData:(EventModel *)eventInfo;


/**
 删除上传成功的事件数据包

 @param uploadData 打包上传的文件包
 */
-(void)removeWaitUplaodData:(ChunkUploadModel *)uploadData;
@end
