//
//  TraceStatisticsKitTests.m
//  TraceStatisticsKitTests
//
//  Created by kris on 2017/12/27.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DeviceInfo.h"
#import "UncaughtExceptionHandler.h"

@interface TraceStatisticsKitTests : XCTestCase

@end

@implementation TraceStatisticsKitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
}

- (void)testDeviceInfo{
//    [[NSNotificationCenter defaultCenter] postNotificationName:CrashLogNotifify object:@"test1234"];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
