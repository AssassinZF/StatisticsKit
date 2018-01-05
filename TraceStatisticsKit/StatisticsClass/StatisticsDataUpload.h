//
//  StatisticsDataUpload.h
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/28.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChunkUploadModel;

@interface StatisticsDataUpload : NSObject
+(instancetype)uploadManager;

/**
 文件上传方法 按照 参数格式传入需要上传的统计数据即可

 @param data 
 */
-(void)uploadWithData:(ChunkUploadModel *)data;
@end
