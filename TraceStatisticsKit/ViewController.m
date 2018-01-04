//
//  ViewController.m
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/27.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import "ViewController.h"
#import "WebTestViewController.h"
#import "CustomClassHook.h"
@interface ViewController ()

@end

@implementation ViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"enter webview" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor purpleColor];
    [btn addTarget:self action:@selector(clickTest:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(100, 100, 100, 30);
    [self.view addSubview:btn];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(clickTapGesture:)];
    [self.view addGestureRecognizer:tap];
    
    [[[CustomClassHook alloc] init] analyseUserdefinedTarget:NSStringFromClass([self class]) action:@selector(testFunc:) method:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self testFunc:@"测试开始"];
    });
}

-(void)clickTapGesture:(UIGestureRecognizer *)gesture{
    NSLog(@"tap gesture");
//    NSMutableArray *array = @[].mutableCopy;
//    [array removeObjectAtIndex:2];
}

- (void)clickTest:(id)sender {
    WebTestViewController *webpage = [[WebTestViewController alloc] init];
    [self.navigationController pushViewController:webpage animated:YES];
}

-(void)testFunc:(NSString *)name{
    NSLog(@"--%@",name);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
