//
//  ChunkUploadModel.h
//  TraceStatisticsKit
//
//  Created by kris on 2017/12/29.
//  Copyright © 2017年 kris'Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,EventType) {
    EventTypeDefault = 0
};

typedef NS_ENUM(NSInteger,RequestStatus) {
    RequestStatusWaiting = 0,
    RequestStatusUploading,
    RequestStatusSuccess,
    RequestStatusFail,
};

@interface ChunkUploadModel : NSObject
@property(nonatomic,assign)RequestStatus status;
@property(nonatomic,copy)NSString *requestApi;
@property(nonatomic,assign)EventType eventType;
 @property(nonatomic,copy)NSString *identifier;
@property(nonatomic,strong)NSArray *dataArray;
@end
