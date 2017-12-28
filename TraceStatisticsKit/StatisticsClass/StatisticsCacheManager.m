//
//  StatisticsCacheManager.m
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/28.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import "StatisticsCacheManager.h"
#import "BNTraceStatistics.h"

//存放所有搜集到的事件的文件名
static NSString * const KAllCollectEventFile = @"AllCollectEventFile";
//从存放所有事件文件中 按照规则读取文件打包 等待上传 的文件名
static NSString * const KPackEventWaitUpdateFile = @"PackEventWaitUpdateFile";

@interface StatisticsCacheManager()
@property(nonatomic,strong,readwrite)NSMutableArray *eventArray;
@property(nonatomic,strong,readwrite)NSMutableArray *waitUpdateData;
@property(nonatomic,strong)NSTimer *timer;
@end

static StatisticsCacheManager *instance = nil;
@implementation StatisticsCacheManager

+(instancetype)cacheManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[super alloc] init];
        }
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)startTimer{
    BNTraceStatistics *statistic = [BNTraceStatistics statisticsInstance];
    if (statistic.updateWay == UpdateWayTime) {
        if (statistic.isLogEnabled) {
            NSLog(@"开启定时器间隔模式");
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:statistic.time
                                                      target:self
                                                    selector:@selector(timerAction)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

-(void)timerAction{
    if ([BNTraceStatistics statisticsInstance].isLogEnabled && self.eventArray.count) {
        NSLog(@"统计时间间隔已到, 当前缓存数量--%ld",self.eventArray.count);
    }
    if (self.eventArray.count) {
        //打包上传
    }
    
}


-(void)saveEventData:(EventInfo *)eventInfo{
    
    [self.eventArray addObject:eventInfo];
    [self archiveData:self.eventArray fileName:KAllCollectEventFile];
    [self startUploadStatisticData];
    
//    NSData * data = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath:KAllCollectEventFile]];
//    NSMutableArray *dataArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    NSLog(@"%@",dataArray);

    
}

-(void)startUploadStatisticData{
    if ([BNTraceStatistics statisticsInstance].updateWay == UpdateWayAmount && ![self checkStartPackUpload]){
        return;
    }
    
}

-(void)packChunkData{
    BNTraceStatistics *statistic = [BNTraceStatistics statisticsInstance];
    if (statistic.updateWay == UpdateWayTime) {
        NSData * data = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] filePath:KAllCollectEventFile]];
        NSMutableArray *dataArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSMutableDictionary *dic = @{}.mutableCopy;
        [dic setValue:dataArray forKey:[self randomStringId]];
        [self.waitUpdateData addObject:dic];
        //保存准备上传的包数据
        [self archiveData:self.waitUpdateData fileName:KPackEventWaitUpdateFile];
    }

}



-(BOOL)archiveData:(id)data fileName:(NSString *)fileName{
    NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:data];
    BOOL isSuc = [NSKeyedArchiver archiveRootObject:newData toFile:[[self class] filePath:fileName]];
    if (!isSuc && [BNTraceStatistics statisticsInstance].isLogEnabled) {
        NSLog(@"统计事件归档失败");
        return NO;
    }
    return YES;
}

-(void)removeWaitUplaodData:(NSString *)key{
    for (NSDictionary *dic in self.waitUpdateData) {
        if (dic[key]) {
            
        }
    }
}

-(BOOL)checkStartPackUpload{
    BNTraceStatistics *statistic = [BNTraceStatistics statisticsInstance];
    if (statistic.updateWay == UpdateWayAmount) {
        return self.eventArray.count >= statistic.amount;
    }else{
        return YES;
    }
}

#pragma mark - Get
-(NSMutableArray *)eventArray{
    if (!_eventArray) {
        _eventArray = @[].mutableCopy;
        NSMutableArray *cacheData = [self getCacheData:KAllCollectEventFile];
        if (cacheData && cacheData.count) {
            [_eventArray addObjectsFromArray:cacheData];
        }
    }
    return _eventArray;
}

-(NSMutableArray *)waitUpdateData{
    if (!_waitUpdateData) {
        _waitUpdateData = @[].mutableCopy;
        NSMutableArray *cacheData = [self getCacheData:KPackEventWaitUpdateFile];
        if (cacheData && cacheData.count) {
            [_waitUpdateData addObjectsFromArray:cacheData];
        }
    }
    return _waitUpdateData;
}

#pragma mark - Archive

-(void)clearFile:(NSString *)fileName{
    NSFileManager *fileM = [NSFileManager defaultManager];
    if ([fileM fileExistsAtPath:fileName]) {
        [fileM removeItemAtPath:fileName error:nil];
        if ([BNTraceStatistics statisticsInstance].isLogEnabled) {
            NSLog(@"统计系统 移除文件 -- %@",fileName);
        }
    }
}

-(NSMutableArray *)getCacheData:(NSString *)cacheFileName{
    NSData * data = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] filePath:cacheFileName]];
    NSMutableArray *dataArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return dataArray;
}

#pragma mark - File handle

+(NSString *)filePath:(NSString *)fileName{
    if (!fileName.length) {
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:directory]) {
        [fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [directory stringByAppendingPathComponent:fileName];
}

-(NSString *)randomStringId{
    NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
    NSString *dateString = [NSString stringWithFormat:@"%0.f",date * 1000];
    return dateString;
}


@end
