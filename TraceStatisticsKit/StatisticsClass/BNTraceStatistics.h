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
@property (nonatomic,assign) BOOL isLogEnabled; //default open

/**
 上传方式 ：按照数量 / 按照时间
 */
@property(nonatomic,assign,readonly)UpdateWay updateWay;

/**
 多少条开始上传 （可修改）
 */
@property(nonatomic,assign,readonly)NSUInteger amount;

/**
 多长时间间隔上传上传一次 （可修改）
 */
@property(nonatomic,assign,readonly)NSInteger time;

/**
 appKey
 */
@property(nonatomic,copy,readonly)NSString *appKey;


/**
 配置文件
 */
@property(nonatomic,strong,readonly)NSMutableDictionary *congigurePlistDic;

/**
 domin url
 */
@property(nonatomic,copy,readonly)NSString *serverUrl;


/**
 是否允许程序自动检查最新版本 作出提示 default NO
 */
@property(nonatomic,assign)BOOL allowCheckUpdateVersion;


+(instancetype)statisticsInstance;
+(void)clearInstance;


/**
 init

 @param appKey appkey
 @param way 上传方式
 */
+(void)initWithAppKey:(NSString *)appKey statisticsWay:(UpdateWay)way;


/**
 改变方式阈值

 @param amount 数量
 */
+(void)changeAmount:(NSInteger)amount;//default 10条 上报一次
+(void)changeTime:(NSInteger)time;//default 30s 上报一次

/**
 手动检查更新版本
 */
+(BOOL)checkUpdateVersion;

@end
