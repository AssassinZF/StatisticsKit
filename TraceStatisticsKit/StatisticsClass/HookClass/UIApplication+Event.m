//
//  UIApplication+Event.m
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/27.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import "UIApplication+Event.h"
#import "HookTool.h"
#import "FilterEvent.h"

@implementation UIApplication (Event)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(sendAction:to:from:forEvent:);
        SEL swizzledSelector = @selector(swiz_sendAction:to:from:forEvent:);
        [HookTool swizzlingInClass:[self class] targetClass:[self class] originalSelector:originalSelector swizzledSelector:swizzledSelector];
    });
    
}

#pragma mark - Method Swizzling
- (BOOL)swiz_sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event{
    NSLog(@"action = %@,taget = %@,event = %ld",NSStringFromSelector(action),target,(long)event);
    [FilterEvent mvWithAction:action to:target from:sender forEvent:event];
    [self swiz_sendAction:action to:target from:sender forEvent:event];
    return YES;

}
@end
