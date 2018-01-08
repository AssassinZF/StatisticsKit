//
//  EventModel.h
//  TraceStatisticsKit
//
//  Created by kris on 2018/1/3.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension/MJExtension.h>

typedef NS_ENUM(NSInteger,EventType) {
    EventTypePV,
    EventTypeMV,
    EventTypeCrash,
    EventTypeTag,
};

@interface EventModel : NSObject
@property(nonatomic,copy)NSString *eventID;
@property(nonatomic,copy)NSString *eventDesc;
@property(nonatomic,assign)EventType etype;
@end
