//
//  CustomClassHook.m
//  TraceStatisticsKit
//
//  Created by kris on 2018/1/4.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import "CustomClassHook.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation CustomClassHook
- (void)analyseUserdefinedTarget:(NSString *)targetClass action:(SEL)action{
    
    if (targetClass !=nil && action !=nil) {
        Class target = NSClassFromString(targetClass);
        NSObject *temp = [[target alloc]init];
    
        if ([temp respondsToSelector:action]) {
            NSString * methodName = NSStringFromSelector(action);
            Method m_gesture = class_getInstanceMethod([target class], action);
            
            SEL hook_sel = NSSelectorFromString([NSString stringWithFormat:@"hook_%@",methodName]);
            IMP method = nil;
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

#warning 注意 此方案只能支持：只能hook带一个参数的自定义类里面的自定义方法

void myHookMethodIMP(id self, SEL _cmd, id arg0)
{
    if ([self respondsToSelector:_cmd]) {
        NSString * methodName = NSStringFromSelector(_cmd);
        SEL hook_sel = NSSelectorFromString([NSString stringWithFormat:@"hook_%@",methodName]);
        
        if (arg0 !=nil) {
            if ([arg0 isKindOfClass:[NSObject class]] ) {

                if ([arg0 isKindOfClass:[NSString class]]||[arg0 isKindOfClass:[NSNumber class]]||[arg0 isKindOfClass:[NSArray class]]||[arg0 isKindOfClass:[NSDictionary class]]||[arg0 isKindOfClass:[NSNull class]]) {
                    NSLog(@"抓到一个方法的参数是：%@",arg0);
                }

            }else{
                NSLog(@"waring：==> 不知道你想要绑定的的方法的参数，建议你查看埋点模块的使用说明");
            }
        }
        if ([self respondsToSelector:hook_sel]) {
            IMP imp = [self methodForSelector:hook_sel];
            void (*func)(id, SEL,id) = (void *)imp;
            if (imp!=NULL) {
                func(self, hook_sel,arg0);
            }
        }

    }
}



/*
void myHookMethodIMP(id self, SEL _cmd,...)
{
    
    if ([self respondsToSelector:_cmd]) {
        NSString * methodName = NSStringFromSelector(_cmd);
        SEL hook_sel = NSSelectorFromString([NSString stringWithFormat:@"hook_%@",methodName]);
        
//        if (arg0 !=nil) {
//            if ([arg0 isKindOfClass:[NSObject class]] ) {
//
//                if ([arg0 isKindOfClass:[NSString class]]||[arg0 isKindOfClass:[NSNumber class]]||[arg0 isKindOfClass:[NSArray class]]||[arg0 isKindOfClass:[NSDictionary class]]||[arg0 isKindOfClass:[NSNull class]]) {
//                    NSLog(@"抓到一个方法的参数是：%@",arg0);
//                }
//
//            }else{
//                NSLog(@"waring：==> 不知道你想要绑定的的方法的参数，建议你查看埋点模块的使用说明");
//            }
//        }
        if ([self respondsToSelector:hook_sel]) {
            IMP imp = [self methodForSelector:hook_sel];
            void (*func)(id, SEL,id) = (void *)imp;
            if (imp!=NULL) {
                func(self, hook_sel,arg0);
            }
        }
        
    }

    Method m_gesture = class_getInstanceMethod([self class], _cmd);
    int paramCount = method_getNumberOfArguments(m_gesture);

    //开始获取方法的参数w
    if (paramCount>2) {
        int start = 2;//这个地方为什么从 2 开始 是因为 前两个参数是 返回类型 和 “：”select 选择器符号 第三个参数才是我们方法里面获取的第一个参数
        
        NSMutableArray *arr = [NSMutableArray new];
        va_list args;
        va_start(args, _cmd);
        for (int i = start; i< paramCount ; i++) {
            
            char *typeChar = method_copyArgumentType(m_gesture, i);
            if (*typeChar == '@') {
                id arg = va_arg(args, id);
                [arr addObject:arg];
            }else if (*typeChar == 'q'){
                NSInteger arg = va_arg(args, NSInteger);
                [arr addObject:[NSNumber numberWithInteger:arg]];

            }
        }
        va_end(args);
        NSLog(@"%@",arr);

    }
}
 */
+ (BOOL) checkClassIsAppClass:(Class)targetClass{
    
    if (targetClass == nil) {
        return NO;
    }
    NSBundle *bundleOfApp = [NSBundle mainBundle];
    
    
    NSBundle *bundleOfT = [NSBundle bundleForClass:[targetClass class]];
    
    
    return [bundleOfT.bundlePath hasPrefix:bundleOfApp.bundlePath];
    
}

@end
