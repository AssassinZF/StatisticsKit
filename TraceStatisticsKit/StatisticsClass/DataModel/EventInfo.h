//
//  EventInfo.h
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/27.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventModel.h"

@interface EventInfo : EventModel
@property (nonatomic, copy) NSString *event_id;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *activity;
@property (nonatomic, copy) NSString *label;
@property (nonatomic) int acc;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *jsonstr;
@property (nonatomic, copy) NSString *lib_version;
@property (nonatomic, copy) NSString *session_id;

@end
