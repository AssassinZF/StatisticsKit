//
//  StatisticsDataUpload.m
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/28.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import "StatisticsDataUpload.h"
#import "BNTraceStatistics.h"
#import "ChunkUploadModel.h"
#import "PageShowTrace.h"
#import "StatisticsCacheManager.h"
#pragma mark - Task Model

@class UploadTask;
typedef void (^RTCompletioBlock)(UploadTask *task, NSDictionary *dic, NSURLResponse *response, NSError *error);
typedef void (^RTSuccessBlock)(NSDictionary *data);
typedef void (^RTFailureBlock)(NSError *error);

@interface UploadTask:NSOperation
@property(nonatomic,strong)ChunkUploadModel *data;
@property(nonatomic,copy)RTCompletioBlock resultBlock;

+(instancetype)taskData:(ChunkUploadModel *)data complection:(RTCompletioBlock)complectionBlock;
@end

@implementation UploadTask

+(instancetype)taskData:(ChunkUploadModel *)data complection:(RTCompletioBlock)complectionBlock{
    UploadTask *task = [[UploadTask alloc] init];
    if (task) {
        task.data = data;
        task.resultBlock = complectionBlock;
    }
    return task;
}

-(void)main{
    
    [self postWithUrlString:self.data.requestApi
                         parameters:self.data
                        complection:self.resultBlock];
}
- (void)postWithUrlString:(NSString *)url parameters:(id)parameters complection:(RTCompletioBlock)complectionBlock
{
    //test
    ChunkUploadModel *model = (ChunkUploadModel *)parameters;
    NSString *topstring = @"*************** 上报事件 ********************";
    NSString *downstring = @"*************** 完成上报 ********************";
    
    NSMutableString *string = @"".mutableCopy;
    [string appendFormat:@"\n"];
    [string appendString:topstring];
    for (EventModel *item in model.dataArray) {
        if([item isKindOfClass:[PageShowTrace class]]){
            PageShowTrace *pageModel = (PageShowTrace *)item;
            [string appendString:[NSString stringWithFormat:@"\n --%@",pageModel.pageClassName]];
            [string appendString:[NSString stringWithFormat:@"\n --%@",pageModel.pageTitle]];
            [string appendString:[NSString stringWithFormat:@"\n --%@",pageModel.eventID]];
        }
    }
    [string appendFormat:@"\n"];
    [string appendString:downstring];
    
    NSLog(@"%@", string);
    complectionBlock(self,parameters,nil,nil);
    
    return;
    NSURL *nsurl = [NSURL URLWithString:url];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    //如果想要设置网络超时的时间的话，可以使用下面的方法：
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:nsurl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];

    //设置请求类型
    request.HTTPMethod = @"POST";
    
    //将需要的信息放入请求头 随便定义了几个
    [request setValue:@"xxx" forHTTPHeaderField:@"Authorization"];//token
    
    //把参数放到请求体内
    //    NSString *postStr = [XMNetWorkHelper parseParams:parameters];
    NSString *postStr = @"";
    request.HTTPBody = [postStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dic = nil;
        if (!error) { //请求失败
            dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        }
        complectionBlock(self,dic,response,error);
    }];
    [dataTask resume];  //开始请求
}

@end


static dispatch_queue_t upload_manager_creation_queue() {
    static dispatch_queue_t upload_manager_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        upload_manager_creation_queue = dispatch_queue_create("com.statistic.upload.manager.creation", DISPATCH_QUEUE_SERIAL);
    });
    return upload_manager_creation_queue;
}

static NSUInteger const KMaxConcurrentOperationCount = 10;


@interface StatisticsDataUpload()
@property(nonatomic,strong)NSMutableArray *requestFailKeyList;
@property(nonatomic,strong)NSOperationQueue *queue;

@end

static StatisticsDataUpload *instance = nil;
@implementation StatisticsDataUpload

+(instancetype)uploadManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[super alloc] init];
        }
    });
    return instance;
}

-(void)uploadWithData:(ChunkUploadModel *)data{
    if (!data) return;
    UploadTask *task = [UploadTask taskData:data
                                complection:^(UploadTask *task, NSDictionary *dic, NSURLResponse *response, NSError *error) {
                                    if ([BNTraceStatistics statisticsInstance].isLogEnabled) {
//                                        NSLog(@"\n 统计上报结果：\n identifier = %@ \n response = %@ ",task.data.identifier,dic);
                                    }
                                    if (error) {
                                        
                                    }else{
//                                        NSLog(@"\n事件上报成功");
                                        [[StatisticsCacheManager cacheManager] removeWaitUplaodData:task.data];
                                        
                                    }
                                }];
    [self.queue addOperation:task]; // task start run
    
}

-(NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = KMaxConcurrentOperationCount;//并发数不易过大
    }
    return _queue;
}

-(NSMutableArray *)requestFailKeyList{
    if (!_requestFailKeyList) {
        _requestFailKeyList = @[].mutableCopy;
    }
    return _requestFailKeyList;
}

@end

