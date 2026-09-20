//
//  OpenKeyManager.h
//  ModernKey
//
//  Created by Tuyen on 1/27/19.
//  Copyright © 2019 Tuyen Mai. All rights reserved.
//

#ifndef OpenKeyManager_h
#define OpenKeyManager_h

#import <Cocoa/Cocoa.h>

typedef void (^CheckNewVersionCallback)(void);

@interface OpenKeyManager : NSObject
+(BOOL)isInited;
+(BOOL)initEventTap;
+(BOOL)stopEventTap;

+(NSArray*)getTableCodes;

+(NSString*)getBuildDate;
+(void)showMessage:(NSWindow*)window message:(NSString*)msg subMsg:(NSString*)subMsg;

+(BOOL)quickConvert;

+(void)startAutoUpdateTimer;
+(void)checkStagedUpdate;
+(void)checkDueOnWake;
+(void)checkForUpdatesWithPrompt:(BOOL)isManual parentWindow:(NSWindow*)parent callback:(CheckNewVersionCallback)callback;
+(void)applyUpdateAndRestart;
+(NSString*)stagedVersionName;
+(int)stagedVersionCode;
+(BOOL)hasReadyUpdate;

+(void)checkNewVersion:(NSWindow*)parent callbackFunc:(CheckNewVersionCallback) callback;
@end

#endif /* OpenKeyManager_h */
