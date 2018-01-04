//
//  CustomClassHook.m
//  TraceStatisticsKit
//
//  Created by kris on 2018/1/4.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import "CustomClassHook.h"
#import <objc/runtime.h>

@implementation CustomClassHook
- (void)analyseUserdefinedTarget:(NSString *)targetClass action:(nullable SEL)action method:(IMP)method{
    
    if (targetClass !=nil && action !=nil) {
        Class target = NSClassFromString(targetClass);
        NSObject *temp = [[target alloc]init];
        if ([temp respondsToSelector:action]) {
            NSString * methodName = NSStringFromSelector(action);
            Method m_gesture = class_getInstanceMethod([target class], action);
            
            SEL hook_sel = NSSelectorFromString([NSString stringWithFormat:@"hook_%@",methodName]);
            if (method == nil) {
                method = (IMP) myHookMethodIMP;
            }
            if (![self respondsToSelector:hook_sel]) {
                class_addMethod([self class], hook_sel, method, method_getTypeEncoding(m_gesture));
                class_addMethod([target class], hook_sel, method_getImplementation(m_gesture), method_getTypeEncoding(m_gesture));
            }
            method_setImplementation(m_gesture, class_getMethodImplementation([self class], hook_sel));
            
        }
        
    }
}

void myHookMethodIMP(id self, SEL _cmd,id arg0)
{
    if ([self respondsToSelector:_cmd]) {
        NSString * methodName = NSStringFromSelector(_cmd);
        SEL hook_sel = NSSelectorFromString([NSString stringWithFormat:@"hook_%@",methodName]);
        
//        controlInfo = [NSMutableDictionary new];
//        [controlInfo setObject:[NSString stringWithUTF8String:object_getClassName(self)] forKey:ACTIONTARGET];
//
//        [controlInfo setObject:methodName forKey:ACTIONNAME];
//        [controlInfo setObject:[NSNumber numberWithInteger:ActionTypeUserdefined] forKey:ACTIONTYPE];
        
        if (arg0 !=nil) {
            if ([arg0 isKindOfClass:[NSObject class]] ) {
                
                if ([arg0 isKindOfClass:[NSString class]]||[arg0 isKindOfClass:[NSNumber class]]||[arg0 isKindOfClass:[NSArray class]]||[arg0 isKindOfClass:[NSDictionary class]]||[arg0 isKindOfClass:[NSNull class]]) {
//                    [controlInfo setObject:arg0 forKey:ACTIONINFO];
                }
                
            }else{
                
//                [controlInfo setObject:[NSValue valueWithNonretainedObject:arg0] forKey:ACTIONINFO];
            }
        }
        
//        NSDictionary *reportInfo = @{[NSNumber numberWithInteger:[self hash]]:controlInfo};
//        addActionReport(reportInfo);
        
        if ([self respondsToSelector:hook_sel]) {
            IMP imp = [self methodForSelector:hook_sel];
            void (*func)(id, SEL,id) = (void *)imp;
            if (imp!=NULL) {
                func(self, hook_sel,arg0);
            }
        }
        
    }
}

@end
