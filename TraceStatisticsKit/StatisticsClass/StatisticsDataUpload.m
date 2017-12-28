//
//  StatisticsDataUpload.m
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/28.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import "StatisticsDataUpload.h"

#pragma mark - Task Model

typedef void (^RTCompletioBlock)(NSDictionary *dic, NSURLResponse *response, NSError *error);
typedef void (^RTSuccessBlock)(NSDictionary *data);
typedef void (^RTFailureBlock)(NSError *error);

@interface UploadTask:NSOperation
@property(nonatomic,strong)NSDictionary *dataDic;
@property(nonatomic,copy)RTSuccessBlock sucBlock;
@property(nonatomic,copy)RTFailureBlock failBlock;
+(instancetype)taskData:(NSDictionary *)dataDic success:(RTSuccessBlock)sucBlock fail:(RTFailureBlock)failBlock;
@end

@implementation UploadTask

+(instancetype)taskData:(NSDictionary *)dataDic success:(RTSuccessBlock)sucBlock fail:(RTFailureBlock)failBlock{
    UploadTask *task = [[UploadTask alloc] init];
    if (task) {
        task.dataDic = dataDic;
        task.sucBlock = sucBlock;
        task.failBlock = failBlock;
    }
    return task;
}

-(void)main{
    [[self class] postWithUrlString:@"" parameters:self.dataDic success:self.sucBlock failure:self.failBlock];
}
+ (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(RTSuccessBlock)successBlock failure:(RTFailureBlock)failureBlock
{
    NSDictionary *dic = (NSDictionary *)parameters;
    NSLog(@"\n执行线程 -- %@ --- key : %@",[NSThread currentThread],dic.allKeys.lastObject);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        successBlock(parameters);
    });
    
    return;
    
    NSURL *nsurl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    //如果想要设置网络超时的时间的话，可以使用下面的方法：
    //NSMutableURLRequest *mutableRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    //设置请求类型
    request.HTTPMethod = @"POST";
    
    //将需要的信息放入请求头 随便定义了几个
    [request setValue:@"xxx" forHTTPHeaderField:@"Authorization"];//token
    [request setValue:@"xxx" forHTTPHeaderField:@"Gis-Lng"];//坐标 lng
    [request setValue:@"xxx" forHTTPHeaderField:@"Gis-Lat"];//坐标 lat
    [request setValue:@"xxx" forHTTPHeaderField:@"Version"];//版本
    NSLog(@"POST-Header:%@",request.allHTTPHeaderFields);
    
    //把参数放到请求体内
    //    NSString *postStr = [XMNetWorkHelper parseParams:parameters];
    NSString *postStr = @"";
    request.HTTPBody = [postStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) { //请求失败
            failureBlock(error);
        } else {  //请求成功
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            successBlock(dic);
        }
    }];
    [dataTask resume];  //开始请求
}

@end


static dispatch_queue_t upload_manager_creation_queue() {
    static dispatch_queue_t upload_manager_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        upload_manager_creation_queue = dispatch_queue_create("com.statistic.upload.manager.creation", DISPATCH_QUEUE_CONCURRENT);
    });
    return upload_manager_creation_queue;
}

static NSUInteger const KMaxConcurrentOperationCount = 10;


@interface StatisticsDataUpload()
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

-(void)uploadWithData:(NSArray <NSDictionary *>*)dataList{
    if (!dataList.count) {
        return;
    }
    
    for (NSDictionary *dic in dataList) {
        UploadTask *task = [UploadTask taskData:dic
                                        success:^(NSDictionary *data) {
                                            NSLog(@"\n任务完成 key == %@",(NSString *)data.allKeys.lastObject);
                                        } fail:^(NSError *error) {
                                            
                                        }];
        [self.queue addOperation:task]; // task start run
    }
}

-(NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = KMaxConcurrentOperationCount;//并发数不易过大
    }
    return _queue;
}

@end

