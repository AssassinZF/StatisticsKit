//
//  CustomClassHook.h
//  TraceStatisticsKit
//
//  Created by kris on 2018/1/4.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning 注意 👇
/*
 注意：这个类是hook 你的自定义类的自定义方法的 如果你想要搜集你的某个自定义类的自定义方法的触发，那么这个方法一定要是没有返回值并且只有一个参数但是这个参数
 的类型必须为 NSString 如果你在你原来已经成型的方法中想实现这个效果，你可以尽量在写的时候留意以后如果需要统计这个方法，那就最好分出来写一个自带一个参数的方法
 */

@interface CustomClassHook : NSObject

/**
 hook 自定类的自定方法

 @param targetClass 自定义类的 className
 @param action sel
 */
- (void)analyseUserdefinedTarget:(NSString *)targetClass action:(SEL)action;

/**
 判断一个class 是否是系统的class

 @param targetClass class
 @return bool
 */
+ (BOOL) checkClassIsAppClass:(Class)targetClass;
@end
