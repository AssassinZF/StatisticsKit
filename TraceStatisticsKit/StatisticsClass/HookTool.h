//
//  HookTool.h
//  StatisticsDemo
//
//  Created by kris on 2017/12/26.
//

#import <Foundation/Foundation.h>

@interface HookTool : NSObject
+ (void)swizzlingInClass:(Class)cls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;
@end
