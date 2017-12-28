//
//  BNTraceStatistics.h
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/27.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,UpdateWay) {
    UpdateWayAmount = 0,
    UpdateWayTime
};

@interface BNTraceStatistics : NSObject
@property (nonatomic,assign) BOOL isLogEnabled;

@property(nonatomic,assign,readonly)UpdateWay updateWay;
@property(nonatomic,assign,readonly)NSUInteger amount;
@property(nonatomic,assign,readonly)NSInteger time;
@property(nonatomic,copy,readonly)NSString *appKey;
@property(nonatomic,strong,readonly)NSMutableDictionary *congigurePlistDic;
@property(nonatomic,copy,readonly)NSString *serverUrl;


+(instancetype)statisticsInstance;
+(void)clearInstance;

+(void)initWithAppKey:(NSString *)appKey statisticsWay:(UpdateWay)way;

+(void)changeAmount:(NSInteger)amount;//default 10条 上报一次
+(void)changeTime:(NSInteger)time;//default 30s 上报一次

@end
