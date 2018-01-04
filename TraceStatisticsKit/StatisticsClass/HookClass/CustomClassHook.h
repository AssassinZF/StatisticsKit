//
//  CustomClassHook.h
//  TraceStatisticsKit
//
//  Created by kris on 2018/1/4.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomClassHook : NSObject
- (void)analyseUserdefinedTarget:(NSString *)targetClass action:(nullable SEL)action method:(IMP)method;
@end
