//
//  HookTool.m
//  StatisticsDemo
//
//  Created by kris on 2017/12/26.
//

#import "HookTool.h"
#import <objc/runtime.h>


static void hook_exchangeMethod(Class originalClass, SEL originalSel, Class replacedClass, SEL replacedSel){
    // 原方法
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    //    assert(originalMethod);
    // 替换方法
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    //    assert(originalMethod);
    IMP replacedMethodIMP = method_getImplementation(replacedMethod);
    // 向实现delegate的类中添加新的方法
    BOOL didAddMethod = class_addMethod(originalClass, replacedSel, replacedMethodIMP, "v@:@@");
    if (didAddMethod) { // 添加成功
        NSLog(@"class_addMethod_success --> (%@)", NSStringFromSelector(replacedSel));
    }
    // 重新拿到添加被添加的method,这部是关键(注意这里originalClass, 不replacedClass), 因为替换的方法已经添加到原类中了, 应该交换原类中的两个方法
    Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
    // 实现交换
    method_exchangeImplementations(originalMethod, newMethod);
}


@implementation HookTool
+ (void)swizzlingInClass:(Class)cls targetClass:(Class)targetCls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector
{
    hook_exchangeMethod(cls, originalSelector, targetCls, swizzledSelector);
}

@end
