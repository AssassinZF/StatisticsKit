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
{
    WebTestViewController *webpage;
}
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
    
    webpage = [[WebTestViewController alloc] init];
    
    [[[CustomClassHook alloc] init] analyseUserdefinedTarget:NSStringFromClass([self class]) action:@selector(testFunc:agep:)];

    [[[CustomClassHook alloc] init] analyseUserdefinedTarget:NSStringFromClass([webpage class]) action:@selector(testFun2:)];

    [[[CustomClassHook alloc] init] analyseUserdefinedTarget:NSStringFromClass([webpage class]) action:@selector(testFun1:)];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self testFunc:@"testFunc:agep" agep:100];
        [webpage testFun2:@"testfun2"];
        
    });
}

-(void)clickTapGesture:(UIGestureRecognizer *)gesture{
    NSLog(@"tap gesture");
//    NSMutableArray *array = @[].mutableCopy;
//    [array removeObjectAtIndex:2];
}

- (void)clickTest:(id)sender {
    
    [self.navigationController pushViewController:webpage animated:YES];
}

-(void)testFunc:(NSString *)name agep:(NSInteger)age{
    NSLog(@"--%@ , -- %ld",name,age);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
