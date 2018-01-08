//
//  FilterEvent.h
//  TraceStatisticsKit
//
//  Created by kris on 2018/1/3.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FilterEvent : NSObject

+(void)pvEnterWithClassName:(nullable NSString *)className target:(UIViewController *)targer;
+(void)pvLeaveWithClassName:(nullable NSString *)className target:(UIViewController *)targer;

+(void)mvWithAction:(nullable SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event;


@end
