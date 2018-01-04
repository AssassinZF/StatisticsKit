//
//  CrashLog.h
//  TraceStatisticsKit
//
//  Created by kris on 2018/1/4.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import "EventModel.h"

@interface CrashLog : EventModel
@property (nonatomic, copy) NSString *stackTrace;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *activity;
@property (nonatomic, copy) NSString *appkey;
@property (nonatomic, copy) NSString *osVersion;
@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *uuID;
@property (nonatomic, copy) NSString *cpt;
@property (nonatomic, copy) NSString *bim;
@property (nonatomic, copy) NSString *lib_version;
@property (nonatomic, copy) NSString *session_id;
@property (nonatomic, copy) NSString *error_type;

@end
