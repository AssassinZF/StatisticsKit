//
//  UIGestureRecognizer+GestureHook.m
//  TraceStatisticsKitge
//
//  Created by kris on 2018/1/3.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import "UIGestureRecognizer+GestureHook.h"
#import "HookTool.h"


@implementation UIGestureRecognizer (GestureHook)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(initWithTarget:action:);
        SEL swizzledSelector = @selector(swiz_initWithTarget:action:);
        [HookTool swizzlingInClass:[self class] targetClass:[self class] originalSelector:originalSelector swizzledSelector:swizzledSelector];
        
        SEL originalSelector1 = @selector(addTarget:action:);
        SEL swizzledSelector1 = @selector(swiz_addTarget:action:);
        [HookTool swizzlingInClass:[self class] targetClass:[self class] originalSelector:originalSelector1 swizzledSelector:swizzledSelector1];

    });
}

- (instancetype)swiz_initWithTarget:(nullable id)target action:(nullable SEL)action{
    
    return [self swiz_initWithTarget:target action:action];
}

- (void)swiz_addTarget:(id)target action:(SEL)action{
    [HookTool swizzlingInClass:[target class] targetClass:[self class] originalSelector:action swizzledSelector:@selector(replace_GestureRecognizerEvent:)];
    [self swiz_addTarget:target action:action];
}

-(void)replace_GestureRecognizerEvent:(UIGestureRecognizer *)gesture{
    [self replace_GestureRecognizerEvent:gesture];
    NSLog(@"replace_gesture");
}



@end
