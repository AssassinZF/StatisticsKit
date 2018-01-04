//
//  StatisticsCacheManager.m
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/28.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import "StatisticsCacheManager.h"
#import "BNTraceStatistics.h"
#import "ChunkUploadModel.h"
#import "StatisticsDataUpload.h"
#import "EventModel.h"

//所有用户收集的日志文件存放目录
static NSString * const KLogCacheDir = @"LogCacheDir";

//存放所有搜集到的事件的文件名
static NSString * const KAllCollectEventFile = @"AllCollectEventFile";
//从存放所有事件文件中 按照规则读取文件打包 等待上传 的文件名
static NSString * const KPackEventWaitUpdateFile = @"PackEventWaitUpdateFile";
//Crash log file
static NSString * const KCrashLogFile = @"CrashLogFile";


@interface StatisticsCacheManager()
@property(nonatomic,strong,readwrite)NSMutableArray *eventArray;
@property(nonatomic,strong,readwrite)NSMutableArray <ChunkUploadModel *>*waitUpdateData;
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
        //定时时间到 打包所有数据 进行上传
        [self startUploadStatisticData];
    }
    
}


-(void)saveEventData:(EventModel *)eventInfo{
    if (!eventInfo) {
        return;
    }
    switch (eventInfo.etype) {
        case EventTypePV:
        case EventTypeMV:
        {
            [self.eventArray addObject:eventInfo];//缓存到内存中
            [self archiveData:self.eventArray fileName:KAllCollectEventFile];//缓存到磁盘
            [self startUploadStatisticData];//检查是否可以上传
            
        }break;
        case EventTypeCrash:
        {
            [self archiveCrashLog:eventInfo];
        }break;

        default:
            break;
    }
}

-(void)startUploadStatisticData{
    if ([BNTraceStatistics statisticsInstance].updateWay == UpdateWayAmount && ![self checkStartPackUpload]){
        return;//暂未达到上传要求 等待中
    }
    [self packChunkData];//打包需要上传的数据
    for (ChunkUploadModel *model in self.waitUpdateData) {
        if (model.status != RequestStatusUploading && model.status == RequestStatusSuccess) {
            //发现有上传失败的时候 继续提交上传
            [[StatisticsDataUpload uploadManager] uploadWithData:model];
        }
    }
}

-(void)packChunkData{
    NSData * data = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] filePath:KAllCollectEventFile]];
    NSMutableArray *dataArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    ChunkUploadModel *uploadModel = [[ChunkUploadModel alloc] init];
    uploadModel.dataArray = dataArray;
    uploadModel.identifier = [self randomStringId];
    [self.waitUpdateData addObject:uploadModel];
    //保存准备上传的包数据
    BOOL flag = [self archiveData:self.waitUpdateData fileName:KPackEventWaitUpdateFile];
    if (flag) {
        [self clearFile:KAllCollectEventFile];//确保数据打包等待上传并且缓存成功 清理该文件
    }
}

-(void)archiveCrashLog:(EventModel *)crashData{
    
    NSData * data = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] filePath:KCrashLogFile]];
    NSMutableArray *dataArray;
    if (data) {
        dataArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }else{
        dataArray = @[].mutableCopy;
    }
    [dataArray addObject:crashData];
    BOOL suc = [self archiveData:dataArray fileName:KCrashLogFile];
    if ([BNTraceStatistics statisticsInstance].isLogEnabled) {
        NSLog(@"保存奔溃日志结果：%@",suc?@"YES":@"NO");
    }
}

-(BOOL)archiveData:(id)data fileName:(NSString *)fileName{
    NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:data];
    BOOL isSuc = [NSKeyedArchiver archiveRootObject:newData toFile:[[self class] filePath:fileName]];
    if (!isSuc && [BNTraceStatistics statisticsInstance].isLogEnabled) {
        NSLog(@"归档失败");
        return NO;
    }
    return YES;
}

-(void)removeWaitUplaodData:(ChunkUploadModel *)uploadData{
    if (uploadData)return;
    if ([self.waitUpdateData containsObject:uploadData]) {
        [self.waitUpdateData removeObject:uploadData];
    }
    BOOL flag = [self archiveData:self.waitUpdateData fileName:KPackEventWaitUpdateFile];
    if ([BNTraceStatistics statisticsInstance].isLogEnabled && flag) {
        NSLog(@"\n 一次数据上报成功，并且成功删除 磁盘缓存已更新");
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

-(NSMutableArray <ChunkUploadModel *>*)waitUpdateData{
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
    NSString *directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:KLogCacheDir];
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
