//
//  UIWebView+webViewLoad.m
//  TraceStatisticsKit
//
//  Created by kris on 2018/1/3.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import "UIWebView+webViewLoad.h"
#import "HookTool.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface HookWebViewDelegateMonitor : NSObject
+ (void)exchangeUIWebViewDelegateMethod:(Class)aClass;
@end

@implementation UIWebView (webViewLoad)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(setDelegate:);
        SEL swizzledSelector = @selector(hook_setDelegate:);
        [HookTool swizzlingInClass:[self class] targetClass:[self class] originalSelector:originalSelector swizzledSelector:swizzledSelector];
    });
}

- (void)hook_setDelegate:(id<UIWebViewDelegate>)delegate{
    [self hook_setDelegate:delegate];
    Class aClass = [delegate class];
    [HookWebViewDelegateMonitor exchangeUIWebViewDelegateMethod:aClass];
}
@end

@implementation HookWebViewDelegateMonitor
+ (void)exchangeUIWebViewDelegateMethod:(Class)aClass{
    // 分别hook它的所有代理方法
    [HookTool swizzlingInClass:aClass targetClass:[self class] originalSelector:@selector(webViewDidFinishLoad:) swizzledSelector:@selector(replace_webViewDidFinishLoad:)];
//    hook_exchangeMethod(aClass, @selector(webViewDidFinishLoad:), [self class], @selector(replace_webViewDidFinishLoad:));
//    hook_exchangeMethod(aClass, @selector(webView:didFailLoadWithError:), [self class], @selector(replace_webView:didFailLoadWithError:));
//    hook_exchangeMethod(aClass, @selector(webView:shouldStartLoadWithRequest:navigationType:), [self class], @selector(replace_webView:shouldStartLoadWithRequest:navigationType:));
}

// 交换后的具体方法实现
- (BOOL)replace_webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"replaced_webView-shouldStartLoadWithRequest");
    return [self replace_webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)replace_webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"replaced_webViewDidStartLoad");
    [self replace_webViewDidStartLoad:webView];
}

- (void)replace_webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"replaced_webViewDidFinishLoad");
    [self replace_webViewDidFinishLoad:webView];
}

- (void)replace_webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"replaced_webView-didFailLoadWithError");
    [self replace_webView:webView didFailLoadWithError:error];
}

@end

