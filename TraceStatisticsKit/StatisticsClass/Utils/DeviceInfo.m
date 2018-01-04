//
//  DeviceInfo.m
//  ZFKit
//
//  Created by Daisy on 2017/12/16.
//  Copyright © 2017年 zf. All rights reserved.
//

#import "DeviceInfo.h"
#import "sys/utsname.h"

//广告标识符框架
#import <AdSupport/AdSupport.h>

// 下面是获取mac地址需要导入的头文件
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

// 设备型号的枚举值
typedef NS_ENUM(NSUInteger, DiviceType) {
    iPhone_1G = 0,
    iPhone_3G,
    iPhone_3GS,
    iPhone_4,
    iPhone_4_Verizon,
    iPhone_4S,
    iPhone_5_GSM,
    iPhone_5_CDMA,
    iPhone_5C_GSM,
    iPhone_5C_GSM_CDMA,
    iPhone_5S_GSM,
    iPhone_5S_GSM_CDMA,
    iPhone_6,
    iPhone_6_Plus,
    iPhone_6S,
    iPhone_6S_Plus,
    iPhone_SE,
    Chinese_iPhone_7,
    Chinese_iPhone_7_Plus,
    American_iPhone_7,
    American_iPhone_7_Plus,
    Chinese_iPhone_8,
    Chinese_iPhone_8_Plus,
    Chinese_iPhone_X,
    Global_iPhone_8,
    Global_iPhone_8_Plus,
    Global_iPhone_X,
    
    iPod_Touch_1G,
    iPod_Touch_2G,
    iPod_Touch_3G,
    iPod_Touch_4G,
    iPod_Touch_5Gen,
    iPod_Touch_6G,
    
    iPad_1,
    iPad_3G,
    iPad_2_WiFi,
    iPad_2_GSM,
    iPad_2_CDMA,
    iPad_3_WiFi,
    iPad_3_GSM,
    iPad_3_CDMA,
    iPad_3_GSM_CDMA,
    iPad_4_WiFi,
    iPad_4_GSM,
    iPad_4_CDMA,
    iPad_4_GSM_CDMA,
    iPad_Air,
    iPad_Air_Cellular,
    iPad_Air_2_WiFi,
    iPad_Air_2_Cellular,
    iPad_Pro_97inch_WiFi,
    iPad_Pro_97inch_Cellular,
    iPad_Pro_129inch_WiFi,
    iPad_Pro_129inch_Cellular,
    iPad_Mini,
    iPad_Mini_WiFi,
    iPad_Mini_GSM,
    iPad_Mini_CDMA,
    iPad_Mini_GSM_CDMA,
    iPad_Mini_2,
    iPad_Mini_2_Cellular,
    iPad_Mini_3_WiFi,
    iPad_Mini_3_Cellular,
    iPad_Mini_4_WiFi,
    iPad_Mini_4_Cellular,
    iPad_5_WiFi,
    iPad_5_Cellular,
    iPad_Pro_129inch_2nd_gen_WiFi,
    iPad_Pro_129inch_2nd_gen_Cellular,
    iPad_Pro_105inch_WiFi,
    iPad_Pro_105inch_Cellular,
    
    appleTV2,
    appleTV3,
    appleTV4,
    
    i386Simulator,
    x86_64Simulator,
    
    iUnknown,
};


@implementation DeviceInfo

+ (const NSString *)getDeviceName {
    DiviceType deviceType = [[DeviceInfo class] transformMachineToIdevice];
    return iDeviceNameContainer[deviceType];
}

+ (NSString *)getDeviceIdentifierID{
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    return cfuuidString;
//    NSString *uuid = [[NSUUID UUID] UUIDString];
//    return uuid;
    
}

+ (const NSString *)getCPUProcessor {
    DiviceType deviceType = [[DeviceInfo class] transformMachineToIdevice];
    return CPUNameContainer[deviceType];
}

+ (NSString *)getIDFA {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

+ (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceModel;
}

+ (NSDate *)getSystemUptime {
    NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];
    return [[NSDate alloc] initWithTimeIntervalSinceNow:(0 - time)];
}

+ (int64_t)getTotalDiskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

+ (int64_t)getFreeDiskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

+ (int64_t)getUsedDiskSpace {
    int64_t totalDisk = [self getTotalDiskSpace];
    int64_t freeDisk = [self getFreeDiskSpace];
    if (totalDisk < 0 || freeDisk < 0) return -1;
    int64_t usedDisk = totalDisk - freeDisk;
    if (usedDisk < 0) usedDisk = -1;
    return usedDisk;
}

+ (NSString *)getMacAddress {
    int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return [outstring uppercaseString];
}


static const NSString *iDeviceNameContainer[] = {
    [iPhone_1G]                 = @"iPhone 1G",
    [iPhone_3G]                 = @"iPhone 3G",
    [iPhone_3GS]                = @"iPhone 3GS",
    [iPhone_4]                  = @"iPhone 4",
    [iPhone_4_Verizon]          = @"Verizon iPhone 4",
    [iPhone_4S]                 = @"iPhone 4S",
    [iPhone_5_GSM]              = @"iPhone 5 (GSM)",
    [iPhone_5_CDMA]             = @"iPhone 5 (CDMA)",
    [iPhone_5C_GSM]             = @"iPhone 5C (GSM)",
    [iPhone_5C_GSM_CDMA]        = @"iPhone 5C (GSM+CDMA)",
    [iPhone_5S_GSM]             = @"iPhone 5S (GSM)",
    [iPhone_5S_GSM_CDMA]        = @"iPhone 5S (GSM+CDMA)",
    [iPhone_6]                  = @"iPhone 6",
    [iPhone_6_Plus]             = @"iPhone 6 Plus",
    [iPhone_6S]                 = @"iPhone 6S",
    [iPhone_6S_Plus]            = @"iPhone 6S Plus",
    [iPhone_SE]                 = @"iPhone SE",
    [Chinese_iPhone_7]          = @"国行/日版/港行 iPhone 7",
    [Chinese_iPhone_7_Plus]     = @"港行/国行 iPhone 7 Plus",
    [American_iPhone_7]         = @"美版/台版 iPhone 7",
    [American_iPhone_7_Plus]    = @"美版/台版 iPhone 7 Plus",
    [Chinese_iPhone_8]          = @"国行/日版 iPhone 8",
    [Chinese_iPhone_8_Plus]     = @"国行/日版 iPhone 8 Plus",
    [Chinese_iPhone_X]          = @"国行/日版 iPhone X",
    [Global_iPhone_8]           = @"美版(Global) iPhone 8",
    [Global_iPhone_8_Plus]      = @"美版(Global) iPhone 8 Plus",
    [Global_iPhone_X]           = @"美版(Global) iPhone X",
    
    [iPod_Touch_1G]             = @"iPod Touch 1G",
    [iPod_Touch_2G]             = @"iPod Touch 2G",
    [iPod_Touch_3G]             = @"iPod Touch 3G",
    [iPod_Touch_4G]             = @"iPod Touch 4G",
    [iPod_Touch_5Gen]           = @"iPod Touch 5(Gen)",
    [iPod_Touch_6G]             = @"iPod Touch 6G",
    [iPad_1]                    = @"iPad 1",
    [iPad_3G]                   = @"iPad 3G",
    [iPad_2_CDMA]               = @"iPad 2 (GSM)",
    [iPad_2_GSM]                = @"iPad 2 (CDMA)",
    [iPad_2_WiFi]               = @"iPad 2 (WiFi)",
    [iPad_3_WiFi]               = @"iPad 3 (WiFi)",
    [iPad_3_GSM]                = @"iPad 3 (GSM)",
    [iPad_3_CDMA]               = @"iPad 3 (CDMA)",
    [iPad_3_GSM_CDMA]           = @"iPad 3 (GSM+CDMA)",
    [iPad_4_WiFi]               = @"iPad 4 (WiFi)",
    [iPad_4_GSM]                = @"iPad 4 (GSM)",
    [iPad_4_CDMA]               = @"iPad 4 (CDMA)",
    [iPad_4_GSM_CDMA]           = @"iPad 4 (GSM+CDMA)",
    [iPad_Air]                  = @"iPad Air",
    [iPad_Air_Cellular]         = @"iPad Air (Cellular)",
    [iPad_Air_2_WiFi]           = @"iPad Air 2(WiFi)",
    [iPad_Air_2_Cellular]       = @"iPad Air 2 (Cellular)",
    [iPad_Mini_WiFi]            = @"iPad Mini (WiFi)",
    [iPad_Mini_GSM]             = @"iPad Mini (GSM)",
    [iPad_Mini_CDMA]            = @"iPad Mini (CDMA)",
    [iPad_Mini_2]               = @"iPad Mini 2",
    [iPad_Mini_2_Cellular]      = @"iPad Mini 2 (Cellular)",
    [iPad_Mini_3_WiFi]          = @"iPad Mini 3(WiFi)",
    [iPad_Mini_3_Cellular]      = @"iPad Mini 3 (Cellular)",
    [iPad_Pro_97inch_WiFi]      = @"iPad Pro 9.7 inch(WiFi)",
    [iPad_Pro_97inch_Cellular]  = @"iPad Pro 9.7 inch(Cellular)",
    [iPad_Pro_129inch_WiFi]     = @"iPad Pro 12.9 inch(WiFi)",
    [iPad_Pro_129inch_Cellular] = @"iPad Pro 12.9 inch(Cellular)",
    [iPad_5_WiFi]               = @"iPad 5(WiFi)",
    [iPad_5_Cellular]           = @"iPad 5(Cellular)",
    [iPad_Pro_129inch_2nd_gen_WiFi]     = @"iPad Pro 12.9 inch(2nd generation)(WiFi)",
    [iPad_Pro_129inch_2nd_gen_Cellular] = @"iPad Pro 12.9 inch(2nd generation)(Cellular)",
    [iPad_Pro_105inch_WiFi]             = @"iPad Pro 10.5 inch(WiFi)",
    [iPad_Pro_105inch_Cellular]         = @"iPad Pro 10.5 inch(Cellular)",
    
    [appleTV2]                  = @"appleTV2",
    [appleTV3]                  = @"appleTV3",
    [appleTV4]                  = @"appleTV4",
    
    [i386Simulator]             = @"i386Simulator",
    [x86_64Simulator]           = @"x86_64Simulator",
    
    [iUnknown]                  = @"Unknown"
};


+ (DiviceType)transformMachineToIdevice{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machineString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    
    if ([machineString isEqualToString:@"iPhone1,1"])   return iPhone_1G;
    if ([machineString isEqualToString:@"iPhone1,2"])   return iPhone_3G;
    if ([machineString isEqualToString:@"iPhone2,1"])   return iPhone_3GS;
    if ([machineString isEqualToString:@"iPhone3,1"])   return iPhone_4;
    if ([machineString isEqualToString:@"iPhone3,3"])   return iPhone_4_Verizon;
    if ([machineString isEqualToString:@"iPhone4,1"])   return iPhone_4S;
    if ([machineString isEqualToString:@"iPhone5,1"])   return iPhone_5_GSM;
    if ([machineString isEqualToString:@"iPhone5,2"])   return iPhone_5_CDMA;
    if ([machineString isEqualToString:@"iPhone5,3"])   return iPhone_5C_GSM;
    if ([machineString isEqualToString:@"iPhone5,4"])   return iPhone_5C_GSM_CDMA;
    if ([machineString isEqualToString:@"iPhone6,1"])   return iPhone_5S_GSM;
    if ([machineString isEqualToString:@"iPhone6,2"])   return iPhone_5S_GSM_CDMA;
    if ([machineString isEqualToString:@"iPhone7,2"])   return iPhone_6;
    if ([machineString isEqualToString:@"iPhone7,1"])   return iPhone_6_Plus;
    if ([machineString isEqualToString:@"iPhone8,1"])   return iPhone_6S;
    if ([machineString isEqualToString:@"iPhone8,2"])   return iPhone_6S_Plus;
    if ([machineString isEqualToString:@"iPhone8,4"])   return iPhone_SE;
    
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([machineString isEqualToString:@"iPhone9,1"])   return Chinese_iPhone_7;
    if ([machineString isEqualToString:@"iPhone9,2"])   return Chinese_iPhone_7_Plus;
    if ([machineString isEqualToString:@"iPhone9,3"])   return American_iPhone_7;
    if ([machineString isEqualToString:@"iPhone9,4"])   return American_iPhone_7_Plus;
    if ([machineString isEqualToString:@"iPhone10,1"])  return Chinese_iPhone_8;
    if ([machineString isEqualToString:@"iPhone10,4"])  return Global_iPhone_8;
    if ([machineString isEqualToString:@"iPhone10,2"])  return Global_iPhone_8;
    if ([machineString isEqualToString:@"iPhone10,5"])  return Global_iPhone_8_Plus;
    if ([machineString isEqualToString:@"iPhone10,3"])  return Chinese_iPhone_X;
    if ([machineString isEqualToString:@"iPhone10,6"])  return Global_iPhone_X;
    
    if ([machineString isEqualToString:@"iPod1,1"])     return iPod_Touch_1G;
    if ([machineString isEqualToString:@"iPod2,1"])     return iPod_Touch_2G;
    if ([machineString isEqualToString:@"iPod3,1"])     return iPod_Touch_3G;
    if ([machineString isEqualToString:@"iPod4,1"])     return iPod_Touch_4G;
    if ([machineString isEqualToString:@"iPod5,1"])     return iPod_Touch_5Gen;
    if ([machineString isEqualToString:@"iPod7,1"])     return iPod_Touch_6G;
    
    if ([machineString isEqualToString:@"iPad1,1"])     return iPad_1;
    if ([machineString isEqualToString:@"iPad1,2"])     return iPad_3G;
    if ([machineString isEqualToString:@"iPad2,1"])     return iPad_2_WiFi;
    if ([machineString isEqualToString:@"iPad2,2"])     return iPad_2_GSM;
    if ([machineString isEqualToString:@"iPad2,3"])     return iPad_2_CDMA;
    if ([machineString isEqualToString:@"iPad2,4"])     return iPad_2_CDMA;
    if ([machineString isEqualToString:@"iPad2,5"])     return iPad_Mini_WiFi;
    if ([machineString isEqualToString:@"iPad2,6"])     return iPad_Mini_GSM;
    if ([machineString isEqualToString:@"iPad2,7"])     return iPad_Mini_CDMA;
    if ([machineString isEqualToString:@"iPad3,1"])     return iPad_3_WiFi;
    if ([machineString isEqualToString:@"iPad3,2"])     return iPad_3_GSM;
    if ([machineString isEqualToString:@"iPad3,3"])     return iPad_3_CDMA;
    if ([machineString isEqualToString:@"iPad3,4"])     return iPad_4_WiFi;
    if ([machineString isEqualToString:@"iPad3,5"])     return iPad_4_GSM;
    if ([machineString isEqualToString:@"iPad3,6"])     return iPad_4_CDMA;
    if ([machineString isEqualToString:@"iPad4,1"])     return iPad_Air;
    if ([machineString isEqualToString:@"iPad4,2"])     return iPad_Air_Cellular;
    if ([machineString isEqualToString:@"iPad4,4"])     return iPad_Mini_2;
    if ([machineString isEqualToString:@"iPad4,5"])     return iPad_Mini_2_Cellular;
    if ([machineString isEqualToString:@"iPad4,7"])     return iPad_Mini_3_WiFi;
    if ([machineString isEqualToString:@"iPad4,8"])     return iPad_Mini_3_Cellular;
    if ([machineString isEqualToString:@"iPad4,9"])     return iPad_Mini_3_Cellular;
    if ([machineString isEqualToString:@"iPad5,1"])     return iPad_Mini_4_WiFi;
    if ([machineString isEqualToString:@"iPad5,2"])     return iPad_Mini_3_Cellular;
    if ([machineString isEqualToString:@"iPad5,3"])     return iPad_Air_2_WiFi;
    if ([machineString isEqualToString:@"iPad5,4"])     return iPad_Air_2_Cellular;
    if ([machineString isEqualToString:@"iPad6,3"])     return iPad_Pro_97inch_WiFi;
    if ([machineString isEqualToString:@"iPad6,4"])     return iPad_Pro_97inch_Cellular;
    if ([machineString isEqualToString:@"iPad6,7"])     return iPad_Pro_129inch_WiFi;
    if ([machineString isEqualToString:@"iPad6,8"])     return iPad_Pro_129inch_Cellular;
    
    if ([machineString isEqualToString:@"iPad6,11"])    return iPad_5_WiFi;
    if ([machineString isEqualToString:@"iPad6,12"])    return iPad_5_Cellular;
    if ([machineString isEqualToString:@"iPad7,1"])     return iPad_Pro_129inch_2nd_gen_WiFi;
    if ([machineString isEqualToString:@"iPad7,2"])     return iPad_Pro_129inch_2nd_gen_Cellular;
    if ([machineString isEqualToString:@"iPad7,3"])     return iPad_Pro_105inch_WiFi;
    if ([machineString isEqualToString:@"iPad7,4"])     return iPad_Pro_105inch_Cellular;
    
    if ([machineString isEqualToString:@"AppleTV2,1"])  return appleTV2;
    if ([machineString isEqualToString:@"AppleTV3,1"])  return appleTV3;
    if ([machineString isEqualToString:@"AppleTV3,2"])  return appleTV3;
    if ([machineString isEqualToString:@"AppleTV5,3"])  return appleTV4;
    
    if ([machineString isEqualToString:@"i386"])        return i386Simulator;
    if ([machineString isEqualToString:@"x86_64"])      return x86_64Simulator;
    
    return iUnknown;
}

static const NSString *CPUNameContainer[] = {
    [iPhone_1G]                 = @"ARM 1176JZ",
    [iPhone_3G]                 = @"ARM 1176JZ",
    [iPhone_3GS]                = @"ARM Cortex-A8",
    [iPhone_4]                  = @"Apple A4",
    [iPhone_4_Verizon]          = @"Apple A4",
    [iPhone_4S]                 = @"Apple A5",
    [iPhone_5_GSM]              = @"Apple A6",
    [iPhone_5_CDMA]             = @"Apple A6",
    [iPhone_5C_GSM]             = @"Apple A6",
    [iPhone_5C_GSM_CDMA]        = @"Apple A6",
    [iPhone_5S_GSM]             = @"Apple A7",
    [iPhone_5S_GSM_CDMA]        = @"Apple A7",
    [iPhone_6]                  = @"Apple A8",
    [iPhone_6_Plus]             = @"Apple A8",
    [iPhone_6S]                 = @"Apple A9",
    [iPhone_6S_Plus]            = @"Apple A9",
    [iPhone_SE]                 = @"Apple A9",
    [Chinese_iPhone_7]          = @"Apple A10",
    [American_iPhone_7]         = @"Apple A10",
    [American_iPhone_7_Plus]    = @"Apple A10",
    [Chinese_iPhone_7_Plus]     = @"Apple A10",
    [Chinese_iPhone_8]          = @"Apple A11",
    [Chinese_iPhone_8_Plus]     = @"Apple A11",
    [Chinese_iPhone_X]          = @"Apple A11",
    [Global_iPhone_8]           = @"Apple A11",
    [Global_iPhone_8_Plus]      = @"Apple A11",
    [Global_iPhone_X]           = @"Apple A11",
    
    [iPod_Touch_1G]             = @"ARM 1176JZ",
    [iPod_Touch_2G]             = @"ARM 1176JZ",
    [iPod_Touch_3G]             = @"ARM Cortex-A8",
    [iPod_Touch_4G]             = @"ARM Cortex-A8",
    [iPod_Touch_5Gen]           = @"Apple A5",
    [iPad_1]                    = @"ARM Cortex-A8",
    [iPad_2_CDMA]               = @"ARM Cortex-A9",
    [iPad_2_GSM]                = @"ARM Cortex-A9",
    [iPad_2_WiFi]               = @"ARM Cortex-A9",
    [iPad_3_WiFi]               = @"ARM Cortex-A9",
    [iPad_3_GSM]                = @"ARM Cortex-A9",
    [iPad_3_CDMA]               = @"ARM Cortex-A9",
    [iPad_4_WiFi]               = @"Apple Swift",
    [iPad_4_GSM]                = @"Apple Swift",
    [iPad_4_CDMA]               = @"Apple Swift",
    [iPad_Air]                  = @"Apple A7",
    [iPad_Air_Cellular]         = @"Apple A7",
    [iPad_Air_2_WiFi]           = @"Apple A8X",
    [iPad_Air_2_Cellular]       = @"Apple A8X",
    [iPad_Mini_WiFi]            = @"ARM Cortex-A9",
    [iPad_Mini_GSM]             = @"ARM Cortex-A9",
    [iPad_Mini_CDMA]            = @"ARM Cortex-A9",
    [iPad_Mini_2]               = @"Apple A7",
    [iPad_Mini_2_Cellular]      = @"Apple A7",
    [iPad_Mini_3_WiFi]          = @"Apple A7",
    [iPad_Mini_3_Cellular]      = @"Apple A7",
    
    [iPad_Pro_97inch_WiFi]      = @"Apple A9X",
    [iPad_Pro_97inch_Cellular]  = @"Apple A9X",
    [iPad_Pro_129inch_WiFi]     = @"Apple A9X",
    [iPad_Pro_129inch_Cellular] = @"Apple A9X",
    [iPad_Pro_129inch_2nd_gen_WiFi]     = @"Apple A10X",
    [iPad_Pro_129inch_2nd_gen_Cellular] = @"Apple A10X",
    [iPad_Pro_105inch_WiFi]             = @"Apple A10X",
    [iPad_Pro_105inch_Cellular]         = @"Apple A10X",
    
    [iUnknown]                          = @"Unknown"
};


@end
