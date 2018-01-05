//
//  WebTestViewController.m
//  TraceStatisticsKit
//
//  Created by kris on 2018/1/3.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

#import "WebTestViewController.h"
#import "UIWebView+webViewLoad.h"

@interface WebTestViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:8080"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"webview finish");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

-(void)testFun1:(NSString *)name{
    NSLog(@"%@",name);
}

 -(void)testFun2:(NSString *)age{
    NSLog(@"%@",age);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
