//
//  DeviceInfo.h
//  ZFKit
//
//  Created by Daisy on 2017/12/16.
//  Copyright © 2017年 zf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject

/**
 获取设备名称

 @return name string
 */
+ (const NSString *)getDeviceName;


/**
 获取设备唯一识别码（UUID CFUUID NSUUID ）

 @return ID
 */
+ (NSString *)getDeviceIdentifierID;

/**
 获取当前设备处理器名称

 @return name string
 */
+ (const NSString *)getCPUProcessor;

/**
 *  获取mac地址
 *
 *  @return mac地址  为了保护用户隐私，每次都不一样，苹果官方哄小孩玩的
 */

+ (NSString *)getMacAddress;


/**
 获取广告标识符

 @return string
 */
+ (NSString *)getIDFA;
+ (NSString *)getDeviceModel;

/* 获取设备上次重启时间*/
+ (NSDate *)getSystemUptime;

/* 磁盘总内存大小 */
+ (int64_t)getTotalDiskSpace;

/* 磁盘空闲空间*/
+ (int64_t)getFreeDiskSpace;

/* 磁盘已用空间*/
+ (int64_t)getUsedDiskSpace;
@end
