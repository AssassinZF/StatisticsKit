//
//  BNTraceStatistics.m
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/27.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import "BNTraceStatistics.h"
#import <UIKit/UIKit.h>
#import "UncaughtExceptionHandler.h"
#import "CrashLog.h"
#import "ChunkUploadModel.h"
#import "StatisticsCacheManager.h"
#import "StatisticsDataUpload.h"

static NSUInteger const KAMOUNT = 30;
static NSUInteger const KTIME = 10;
static NSString *const plistPathName = @"StatisticsConfigure";

@interface BNTraceStatistics()
@property(nonatomic,assign,readwrite)UpdateWay updateWay;
@property(nonatomic,assign,readwrite)NSUInteger amount;
@property(nonatomic,assign,readwrite)NSInteger time;
@property(nonatomic,copy,readwrite)NSString *appKey;
@property(nonatomic,copy,readwrite)NSString *serverUrl;
@property(nonatomic,strong,readwrite)NSMutableDictionary *congigurePlistDic;
@end

static BNTraceStatistics *instance = nil;
@implementation BNTraceStatistics
+(instancetype)statisticsInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[super alloc] init];
        }
    });
    return instance;
}

-(void)settingDefaultParam{
    self.amount = KAMOUNT;
    self.time = KTIME;
    self.isLogEnabled = YES;
    [self addNotificationCenter];
    
    NSInteger count = self.congigurePlistDic.count;
    NSAssert(count > 0, @"缺少配置服务URL" );
    InstallUncaughtExceptionHandler();
}

+(void)initWithAppKey:(NSString *)appKey statisticsWay:(UpdateWay)way{
    NSAssert(appKey.length>0, @"appkey 不合法");
    BNTraceStatistics *instance = [BNTraceStatistics statisticsInstance];
    instance.updateWay = way;
    instance.appKey = appKey;
    [instance settingDefaultParam];
}

#pragma mark - NotificationCenter
-(void)addNotificationCenter{
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self
                    selector:@selector(resignActive:)
                        name:UIApplicationWillResignActiveNotification
                      object:nil];

    [notifCenter addObserver:self
                    selector:@selector(becomeActive:)
                        name:UIApplicationDidBecomeActiveNotification
                      object:nil];
    
    [notifCenter addObserver:self
                    selector:@selector(didFinishLaunchingNotification:)
                        name:UIApplicationDidFinishLaunchingNotification
                      object:nil];
    [notifCenter addObserver:self
                    selector:@selector(collectCrashLog:)
                        name:CrashLogNotifify
                      object:nil];
    
}

-(void)didFinishLaunchingNotification:(NSNotification *)noti{
    if (self.isLogEnabled) {
        NSLog(@"APP 启动了");
    }
    //程序一次冷启动 可以把 程序的崩溃日志上传至服务器
    //上传上次的崩溃日志
//    NSArray *crashData = [[StatisticsCacheManager cacheManager] getAllCrashLogData];
//    ChunkUploadModel *chunkDta = [[ChunkUploadModel alloc] init];
//    chunkDta.dataArray = crashData;
//    [[StatisticsDataUpload uploadManager] uploadWithData:chunkDta];
}


-(void)collectCrashLog:(NSNotification *)notification{
    NSString *logInfo = (NSString *)notification.object;
    if (!logInfo.length) {
        return;
    }
    CrashLog *cralog = [CrashLog new];
    cralog.stackTrace = logInfo;
    cralog.etype = EventTypeCrash;
    [[StatisticsCacheManager cacheManager] saveEventData:cralog];
    
}

-(void)resignActive:(NSNotification *)notification{
    if (self.isLogEnabled) {
        NSLog(@"统计系统检测--程序进入后台状态");
    }
}

-(void)becomeActive:(NSNotification *)notification{
    if (self.isLogEnabled) {
        NSLog(@"统计系统检测--到程序进入活跃状态");
    }

}

#pragma mark - congigure

+(void)changeAmount:(NSInteger)amount{
    if (![self checkInitState]) return;
    if (!instance.updateWay && amount > 0) {
        [BNTraceStatistics statisticsInstance].amount = amount;
    }
}

+(void)changeTime:(NSInteger)time{
    if (![self checkInitState]) return;
    if (instance.updateWay && time > 5) {
        [BNTraceStatistics statisticsInstance].time = time;
    }
}

+(BOOL)checkInitState{
    BNTraceStatistics *instance = [BNTraceStatistics statisticsInstance];
    if (!instance.appKey.length) {
        NSLog(@"必须调用 +initWithAppKey:statisticsWay 初始化");
        return NO;
    }
    return YES;
}

+(BOOL)checkUpdateVersion{
    return YES;
}

+(void)clearInstance{
    if (instance) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        instance = nil;
    }
}


-(NSMutableDictionary *)congigurePlistDic{
    if (!_congigurePlistDic) {
        NSString *plistName = [[NSBundle mainBundle] pathForResource:plistPathName ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:plistName];
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        _congigurePlistDic = jsonDic.mutableCopy;
    }
    return _congigurePlistDic;
}
@end
