//
//  UIViewController+VCStatistics.m
//  StatisticsDemo
//
//  Created by kris on 2017/12/26.
//

#import "UIViewController+VCStatistics.h"
#import "HookTool.h"
#import "BNTraceStatistics.h"
#import "FilterEvent.h"

@implementation UIViewController (VCStatistics)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //view will appear
        SEL originalSelector_appear = @selector(viewWillAppear:);
        SEL swizzledSelector_appear = @selector(swiz_viewWillAppear:);
        [HookTool swizzlingInClass:[self class] targetClass:[self class] originalSelector:originalSelector_appear swizzledSelector:swizzledSelector_appear];
        
        //view will disappear
        SEL originalSelector_disAppear = @selector(viewWillDisappear:);
        SEL swizzledSelector_disAppear = @selector(swiz_viewWillDisappear:);
        [HookTool swizzlingInClass:[self class] targetClass:[self class] originalSelector:originalSelector_disAppear swizzledSelector:swizzledSelector_disAppear];
    });
}
#pragma mark - Method Swizzling
- (void)swiz_viewWillAppear:(BOOL)animated
{
    [self swiz_viewWillAppear:animated];
    NSString *classString = NSStringFromClass([self class]);
    [FilterEvent pvEnterWithClassName:classString];
}

- (void)swiz_viewWillDisappear:(BOOL)animated
{
    [self swiz_viewWillDisappear:animated];
    NSString *classString = NSStringFromClass([self class]);
    [FilterEvent pvLeaveWithClassName:classString];
    
}


@end
