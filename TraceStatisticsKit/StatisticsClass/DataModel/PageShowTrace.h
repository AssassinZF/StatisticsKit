//
//  PageShowTrace.h
//  TraceStatisticsKit
//
//  Created by kris on 2018/1/8.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import "EventModel.h"

@interface PageShowTrace : EventModel
@property(nonatomic,copy)NSString *pageTitle;
@property(nonatomic,copy)NSString *pageClassName;
//@property(nonatomic,assign)NSTimeInterval tiemInterval;
@property(nonatomic,copy)NSString * time;

@end
