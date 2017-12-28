//
//  StatisticsDataUpload.h
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/28.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatisticsDataUpload : NSObject
+(instancetype)uploadManager;
-(void)uploadWithData:(NSArray <NSDictionary *>*)dataList;
@end
