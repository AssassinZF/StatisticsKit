//
//  UncaughtExceptionHandler.h
//  UMSAgent
//
//  Created by wb on 16/4/19.
//
//

#import <Foundation/Foundation.h>

extern NSString * const CrashLogNotifify;

@interface UncaughtExceptionHandler : NSObject

+ (NSUUID *)ExecutableUUID;

+ (NSString *)getCPUType;

+ (NSString *)getBinary;

@end

void HandleException(NSException *exception);

void SignalHandler(int signal);

void InstallUncaughtExceptionHandler(void);

