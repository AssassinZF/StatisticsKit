//
//  FilterEvent.m
//  TraceStatisticsKit
//
//  Created by kris on 2018/1/3.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import "FilterEvent.h"
#import "BNTraceStatistics.h"
#import "StatisticsCacheManager.h"
#import "PageShowTrace.h"

@implementation FilterEvent

+(NSDictionary *)congigurePlist{
    return [BNTraceStatistics statisticsInstance].congigurePlistDic;
}

+(void)pvEnterWithClassName:(NSString *)className target:(UIViewController *)targer{
    
    NSDictionary *configure = [self congigurePlist];
    if(![configure.allKeys containsObject:className]){
        return;
    }
    PageShowTrace *page = [PageShowTrace new];
    page.eventID = [self congigurePlist][className][@"viewDidAppear"][@"ID"];
    page.pageClassName = className;
    page.pageTitle = targer.title;
    page.time = [self currentTimeString];
    [[StatisticsCacheManager cacheManager] saveEventData:page];

}

+(void)pvLeaveWithClassName:(NSString *)className target:(UIViewController *)targer;{
    NSDictionary *configure = [self congigurePlist];
    if(![configure.allKeys containsObject:className]){
        return;
    }
    PageShowTrace *page = [PageShowTrace new];
    page.eventID = [self congigurePlist][className][@"viewDidDisAppear"][@"ID"];
    page.pageClassName = className;
    page.pageTitle = targer.title;
    page.time = [self currentTimeString];
    [[StatisticsCacheManager cacheManager] saveEventData:page];
}

+(void)mvWithAction:(nullable SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event{
    
}

+(NSString *)currentTimeString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日 HH时mm分ss秒 Z";
    return [formatter stringFromDate:[NSDate date]];

}
@end
