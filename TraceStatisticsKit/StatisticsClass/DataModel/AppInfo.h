//
//  AppInfo.h
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/27.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppInfo : NSObject
@property (nonatomic,strong) NSString *appKey;
@property (nonatomic,strong) NSString *appVersion;
@property (nonatomic,strong) NSString *userIdentifier;
@property (nonatomic,strong) NSString *appName;
@property (nonatomic,strong) NSString *deviceid;
@property (nonatomic,strong) NSString *lib_version;
@end
