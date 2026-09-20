//
//  OpenKeyManager.m
//  OpenKey
//
//  Created by Tuyen on 1/27/19.
//  Copyright © 2019 Tuyen Mai. All rights reserved.
//

#import "OpenKeyManager.h"
#import "AppDelegate.h"
#include <sys/stat.h>

extern AppDelegate* appDelegate;

extern void OpenKeyInit(void);

extern CGEventRef OpenKeyCallback(CGEventTapProxy proxy,
                                  CGEventType type,
                                  CGEventRef event,
                                  void *refcon);

extern NSString* ConvertUtil(NSString* str);

@interface OpenKeyManager ()

@end

@implementation OpenKeyManager {

}
static BOOL _isInited = NO;

static CFMachPortRef      eventTap;
static CGEventMask        eventMask;
static CFRunLoopSourceRef runLoopSource;

+(BOOL)isInited {
    return _isInited;
}

+(BOOL)initEventTap {
    if (_isInited)
        return true;
    
    //init modernKey
    OpenKeyInit();
    
    // Create an event tap. We are interested in key presses.
    eventMask = ((1 << kCGEventKeyDown) |
                 (1 << kCGEventKeyUp) |
                 (1 << kCGEventFlagsChanged) |
                 (1 << kCGEventLeftMouseDown) |
                 (1 << kCGEventRightMouseDown) |
                 (1 << kCGEventLeftMouseDragged) |
                 (1 << kCGEventRightMouseDragged));
    
    eventTap = CGEventTapCreate(kCGSessionEventTap,
                                kCGHeadInsertEventTap,
                                0,
                                eventMask,
                                OpenKeyCallback,
                                NULL);
    
    if (!eventTap) {
        
        fprintf(stderr, "failed to create event tap\n");
        return NO;
    }
    
    _isInited = YES;
    
    // Create a run loop source.
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    
    // Add to the current run loop.
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    
    // Enable the event tap.
    CGEventTapEnable(eventTap, true);
    
    return YES;
}

+(BOOL)stopEventTap {
    if (_isInited) { //release all object
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
        CFRelease(runLoopSource);
        runLoopSource = nil;
        
        CFMachPortInvalidate(eventTap);
        CFRelease(eventTap);
        eventTap = nil;
        
        _isInited = false;
    }
    return YES;
}

+(NSArray*)getTableCodes {
    return [[NSArray alloc] initWithObjects:
            @"Unicode",
            @"TCVN3 (ABC)",
            @"VNI Windows",
            @"Unicode tổ hợp",
            @"Vietnamese Locale CP 1258", nil];
}

+(NSString*)getBuildDate {
    return [NSString stringWithUTF8String:__DATE__];
}

#pragma mark -Convert feature
+(BOOL)quickConvert {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *htmlString = [pasteboard stringForType:NSPasteboardTypeHTML];
    NSString *rawString = [pasteboard stringForType:NSPasteboardTypeString];
    bool converted = false;
    if (htmlString != nil) {
        htmlString = ConvertUtil(htmlString);
        converted = true;
    }
    if (rawString != nil) {
        rawString = ConvertUtil(rawString);
        converted = true;
    }
    if (converted) {
        [pasteboard clearContents];
        if (htmlString != nil)
            [pasteboard setString:htmlString forType:NSPasteboardTypeHTML];
        if (rawString != nil)
            [pasteboard setString:rawString forType:NSPasteboardTypeString];
        
        return YES;
    }
    return NO;
}

+(void)showMessage:(NSWindow*)window message:(NSString*)msg subMsg:(NSString*)subMsg {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:msg];
    [alert setInformativeText:subMsg];
    [alert addButtonWithTitle:@"OK"];
    if (window) {
        [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        }];
    } else {
        [alert runModal];
    }
}

#pragma mark - AutoUpdate Feature

static NSTimer *autoUpdateTimer = nil;
static BOOL isDownloadingUpdate = NO;

+ (NSString *)updateCacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths firstObject];
    NSString *goxCache = [cachesDir stringByAppendingPathComponent:@"com.tuyennq1001.gox/Updates"];
    [[NSFileManager defaultManager] createDirectoryAtPath:goxCache withIntermediateDirectories:YES attributes:nil error:nil];
    return goxCache;
}

+ (NSString *)stagedAppPath {
    return [[self updateCacheDirectory] stringByAppendingPathComponent:@"staged/Gox.app"];
}

+ (NSString *)stagedVersionName {
    NSString *infoPath = [[self stagedAppPath] stringByAppendingPathComponent:@"Contents/Info.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:infoPath]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:infoPath];
        return dict[@"CFBundleShortVersionString"] ?: dict[@"CFBundleVersion"];
    }
    return nil;
}

+ (int)stagedVersionCode {
    NSString *infoPath = [[self stagedAppPath] stringByAppendingPathComponent:@"Contents/Info.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:infoPath]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:infoPath];
        return [dict[@"CFBundleVersion"] intValue];
    }
    return 0;
}

+ (BOOL)isStagedAppValidForVersionCode:(int)targetVersionCode {
    NSString *staged = [self stagedAppPath];
    NSString *infoPath = [staged stringByAppendingPathComponent:@"Contents/Info.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:infoPath]) {
        return NO;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:infoPath];
    if (!dict) return NO;
    
    NSString *bundleId = dict[@"CFBundleIdentifier"];
    if (![bundleId isEqualToString:@"com.tuyennq1001.gox"]) {
        return NO;
    }
    
    int stagedCode = [dict[@"CFBundleVersion"] intValue];
    return (stagedCode >= targetVersionCode);
}

+ (BOOL)hasReadyUpdate {
    int currentVersionCode = (int)[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
    int stagedCode = [self stagedVersionCode];
    if (stagedCode > currentVersionCode) {
        return [self isStagedAppValidForVersionCode:stagedCode];
    }
    return NO;
}

+ (void)checkStagedUpdate {
    int currentVersionCode = (int)[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
    int stagedCode = [self stagedVersionCode];
    
    if (stagedCode > currentVersionCode && [self isStagedAppValidForVersionCode:stagedCode]) {
        NSString *verName = [self stagedVersionName] ?: [NSString stringWithFormat:@"%d", stagedCode];
        [appDelegate showRestartToUpdateMenu:verName];
    } else if (stagedCode > 0 && stagedCode <= currentVersionCode) {
        // Đã cập nhật xong, dọn dẹp thư mục staged cũ
        NSString *stagedDir = [[self updateCacheDirectory] stringByAppendingPathComponent:@"staged"];
        [[NSFileManager defaultManager] removeItemAtPath:stagedDir error:nil];
        [appDelegate hideRestartToUpdateMenu];
    }
}

+ (void)startAutoUpdateTimer {
    // 1. Kiểm tra nếu trong Cache đã có sẵn bản cập nhật từ phiên trước
    [self checkStagedUpdate];
    
    // 2. Kiểm tra nếu đã đủ 24 giờ kể từ lần check trước
    NSTimeInterval lastCheck = [[NSUserDefaults standardUserDefaults] doubleForKey:@"LastCheckUpdateTime"];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSInteger dontCheckUpdate = [[NSUserDefaults standardUserDefaults] integerForKey:@"DontCheckUpdate"];
    if (!dontCheckUpdate) {
        if (lastCheck == 0 || (now - lastCheck) >= 24 * 3600) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self checkForUpdatesWithPrompt:NO parentWindow:nil callback:nil];
            });
        }
    }
    
    // 3. Timer định kỳ mỗi 1 giờ để kiểm tra mốc 24h
    if (autoUpdateTimer) {
        [autoUpdateTimer invalidate];
        autoUpdateTimer = nil;
    }
    autoUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:3600.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSInteger dontCheck = [[NSUserDefaults standardUserDefaults] integerForKey:@"DontCheckUpdate"];
        if (dontCheck) return;
        
        NSTimeInterval last = [[NSUserDefaults standardUserDefaults] doubleForKey:@"LastCheckUpdateTime"];
        NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
        if (last == 0 || (current - last) >= 24 * 3600) {
            [self checkForUpdatesWithPrompt:NO parentWindow:nil callback:nil];
        }
    }];
}

+ (void)checkDueOnWake {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger dontCheck = [[NSUserDefaults standardUserDefaults] integerForKey:@"DontCheckUpdate"];
        if (!dontCheck) {
            NSTimeInterval last = [[NSUserDefaults standardUserDefaults] doubleForKey:@"LastCheckUpdateTime"];
            NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
            if (last == 0 || (current - last) >= 24 * 3600) {
                [self checkForUpdatesWithPrompt:NO parentWindow:nil callback:nil];
            }
        }
    });
}

+ (void)checkNewVersion:(NSWindow*)parent callbackFunc:(CheckNewVersionCallback)callback {
    [self checkForUpdatesWithPrompt:YES parentWindow:parent callback:callback];
}

+ (void)checkForUpdatesWithPrompt:(BOOL)isManual parentWindow:(NSWindow*)parent callback:(CheckNewVersionCallback)callback {
    if (isDownloadingUpdate) {
        if (isManual) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Đang tải bản cập nhật..."];
            [alert setInformativeText:@"Gox đang tự động tải ngầm phiên bản mới. Mục khởi động lại sẽ xuất hiện trên thanh Menu ngay khi hoàn tất."];
            [alert addButtonWithTitle:@"OK"];
            if (parent) {
                [alert beginSheetModalForWindow:parent completionHandler:nil];
            } else {
                [alert.window setLevel:NSStatusWindowLevel];
                [alert runModal];
            }
            if (callback) callback();
        }
        return;
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSString *urlString = [NSString stringWithFormat:@"https://raw.githubusercontent.com/tuyennq1001/gox/master/version.json?t=%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:15.0];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) callback();
        });
        
        if (error || ((NSHTTPURLResponse *)response).statusCode != 200 || !data) {
            if (isManual) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"Không thể kiểm tra bản mới"];
                    [alert setInformativeText:@"Vui lòng kiểm tra lại kết nối mạng và thử lại sau."];
                    [alert addButtonWithTitle:@"OK"];
                    if (parent) {
                        [alert beginSheetModalForWindow:parent completionHandler:nil];
                    } else {
                        [alert.window setLevel:NSStatusWindowLevel];
                        [alert runModal];
                    }
                });
            }
            return;
        }
        
        NSError *jsonError = nil;
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (![object isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSDictionary *results = (NSDictionary *)object;
        NSDictionary *ver = results[@"latestVersion"];
        if (!ver) return;
        
        int versionCode = [ver[@"versionCode"] intValue];
        NSString *versionName = ver[@"versionName"] ?: @"";
        NSString *downloadUrl = ver[@"downloadUrl"];
        int currentVersionCode = (int)[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
        
        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:@"LastCheckUpdateTime"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (versionCode <= currentVersionCode) {
                [self checkStagedUpdate];
                if (isManual) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"Bạn đang dùng phiên bản mới nhất!"];
                    [alert setInformativeText:[NSString stringWithFormat:@"Gox phiên bản %@ (build %d) là bản mới nhất hiện nay.", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], currentVersionCode]];
                    [alert addButtonWithTitle:@"OK"];
                    if (parent) {
                        [alert beginSheetModalForWindow:parent completionHandler:nil];
                    } else {
                        [alert.window setLevel:NSStatusWindowLevel];
                        [alert runModal];
                    }
                }
            } else {
                if ([self isStagedAppValidForVersionCode:versionCode]) {
                    [appDelegate showRestartToUpdateMenu:versionName];
                    if (isManual) {
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert setMessageText:[NSString stringWithFormat:@"Đã có bản mới (v%@)", versionName]];
                        [alert setInformativeText:@"Bản cập nhật đã được tải về sẵn sàng. Bạn có muốn khởi động lại Gox ngay bây giờ để áp dụng bản mới?"];
                        [alert addButtonWithTitle:@"Khởi động lại ngay"];
                        [alert addButtonWithTitle:@"Để sau"];
                        if (parent) {
                            [alert beginSheetModalForWindow:parent completionHandler:^(NSModalResponse returnCode) {
                                if (returnCode == NSAlertFirstButtonReturn) {
                                    [self applyUpdateAndRestart];
                                }
                            }];
                        } else {
                            [alert.window setLevel:NSStatusWindowLevel];
                            if ([alert runModal] == NSAlertFirstButtonReturn) {
                                [self applyUpdateAndRestart];
                            }
                        }
                    }
                } else {
                    if (isManual) {
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert setMessageText:[NSString stringWithFormat:@"Tìm thấy phiên bản mới (v%@)", versionName]];
                        [alert setInformativeText:@"Gox đang tiến hành tải ngầm bản cập nhật. Khi hoàn tất, tuỳ chọn khởi động lại sẽ hiển thị trên thanh Menu."];
                        [alert addButtonWithTitle:@"OK"];
                        if (parent) {
                            [alert beginSheetModalForWindow:parent completionHandler:nil];
                        } else {
                            [alert.window setLevel:NSStatusWindowLevel];
                            [alert runModal];
                        }
                    }
                    [self startDownloadUpdate:versionName versionCode:versionCode customUrl:downloadUrl];
                }
            }
        });
    }] resume];
}

+ (void)startDownloadUpdate:(NSString *)versionName versionCode:(int)versionCode customUrl:(NSString *)customUrl {
    if (isDownloadingUpdate) return;
    isDownloadingUpdate = YES;
    
    NSURL *targetUrl = nil;
    NSURL *fallbackUrl = nil;
    
    if (customUrl && [customUrl length] > 0) {
        targetUrl = [NSURL URLWithString:customUrl];
    } else {
        NSString *zipStr = [NSString stringWithFormat:@"https://github.com/tuyennq1001/gox/releases/download/v%@/Gox.zip", versionName];
        NSString *dmgStr = [NSString stringWithFormat:@"https://github.com/tuyennq1001/gox/releases/download/v%@/Gox.dmg", versionName];
        targetUrl = [NSURL URLWithString:zipStr];
        fallbackUrl = [NSURL URLWithString:dmgStr];
    }
    
    [self performDownloadWithUrl:targetUrl fallbackUrl:fallbackUrl versionName:versionName versionCode:versionCode];
}

+ (void)performDownloadWithUrl:(NSURL *)url
                   fallbackUrl:(NSURL *)fallbackUrl
                   versionName:(NSString *)versionName
                   versionCode:(int)versionCode {
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    [[session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (error || statusCode != 200 || !location) {
            NSLog(@"[GoxUpdater] Download failed for URL %@ (status %ld, error: %@)", url, (long)statusCode, error);
            if (fallbackUrl) {
                NSLog(@"[GoxUpdater] Retrying with fallback URL: %@", fallbackUrl);
                [self performDownloadWithUrl:fallbackUrl fallbackUrl:nil versionName:versionName versionCode:versionCode];
                return;
            }
            isDownloadingUpdate = NO;
            return;
        }
        
        NSString *cacheDir = [self updateCacheDirectory];
        NSString *downloadDir = [cacheDir stringByAppendingPathComponent:@"download"];
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString *ext = [url pathExtension];
        if (ext.length == 0) ext = @"zip";
        NSString *savedArchive = [downloadDir stringByAppendingPathComponent:[NSString stringWithFormat:@"update.%@", ext]];
        [[NSFileManager defaultManager] removeItemAtPath:savedArchive error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:[location path] toPath:savedArchive error:nil];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *stagedDir = [cacheDir stringByAppendingPathComponent:@"staged"];
            [[NSFileManager defaultManager] removeItemAtPath:stagedDir error:nil];
            [[NSFileManager defaultManager] createDirectoryAtPath:stagedDir withIntermediateDirectories:YES attributes:nil error:nil];
            
            BOOL extracted = NO;
            if ([ext isEqualToString:@"dmg"]) {
                extracted = [self extractDmg:savedArchive toDestination:stagedDir];
            } else {
                extracted = [self extractZip:savedArchive toDestination:stagedDir];
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:savedArchive error:nil];
            
            BOOL valid = NO;
            if (extracted) {
                valid = [self isStagedAppValidForVersionCode:versionCode];
            }
            
            isDownloadingUpdate = NO;
            
            if (valid) {
                NSLog(@"[GoxUpdater] Update v%@ staged successfully!", versionName);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [appDelegate showRestartToUpdateMenu:versionName];
                });
            } else {
                NSLog(@"[GoxUpdater] Extracted update validation failed!");
                [[NSFileManager defaultManager] removeItemAtPath:stagedDir error:nil];
            }
        });
    }] resume];
}

+ (BOOL)extractZip:(NSString *)zipPath toDestination:(NSString *)destDir {
    @try {
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/bin/ditto";
        task.arguments = @[@"-x", @"-k", zipPath, destDir];
        [task launch];
        [task waitUntilExit];
        return (task.terminationStatus == 0);
    } @catch (NSException *exception) {
        NSLog(@"[GoxUpdater] ditto exception: %@", exception);
        return NO;
    }
}

+ (BOOL)extractDmg:(NSString *)dmgPath toDestination:(NSString *)destDir {
    @try {
        NSTask *attachTask = [[NSTask alloc] init];
        attachTask.launchPath = @"/usr/bin/hdiutil";
        attachTask.arguments = @[@"attach", @"-nobrowse", @"-readonly", @"-plist", dmgPath];
        NSPipe *pipe = [NSPipe pipe];
        [attachTask setStandardOutput:pipe];
        [attachTask setStandardError:[NSFileHandle fileHandleWithNullDevice]];
        [attachTask launch];
        [attachTask waitUntilExit];
        
        if (attachTask.terminationStatus != 0) {
            return NO;
        }
        
        NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
        NSError *error = nil;
        NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:&error];
        if (!plist || ![plist isKindOfClass:[NSDictionary class]]) {
            return NO;
        }
        
        NSString *mountPoint = nil;
        NSArray *entities = plist[@"system-entities"];
        for (NSDictionary *entity in entities) {
            if (entity[@"mount-point"]) {
                mountPoint = entity[@"mount-point"];
                break;
            }
        }
        
        if (!mountPoint) return NO;
        
        NSString *appInDmg = [mountPoint stringByAppendingPathComponent:@"Gox.app"];
        NSString *targetApp = [destDir stringByAppendingPathComponent:@"Gox.app"];
        
        NSTask *cpTask = [[NSTask alloc] init];
        cpTask.launchPath = @"/bin/cp";
        cpTask.arguments = @[@"-R", appInDmg, targetApp];
        [cpTask launch];
        [cpTask waitUntilExit];
        
        NSTask *detachTask = [[NSTask alloc] init];
        detachTask.launchPath = @"/usr/bin/hdiutil";
        detachTask.arguments = @[@"detach", mountPoint, @"-force"];
        [detachTask launch];
        [detachTask waitUntilExit];
        
        return [[NSFileManager defaultManager] fileExistsAtPath:targetApp];
    } @catch (NSException *exception) {
        NSLog(@"[GoxUpdater] DMG extract exception: %@", exception);
        return NO;
    }
}

+ (void)applyUpdateAndRestart {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *stagedApp = [self stagedAppPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stagedApp]) {
        NSLog(@"[GoxUpdater] Cannot apply update: staged app not found at %@", stagedApp);
        return;
    }
    
    NSString *cacheDir = [self updateCacheDirectory];
    NSString *scriptPath = [cacheDir stringByAppendingPathComponent:@"relaunch.sh"];
    pid_t pid = [[NSProcessInfo processInfo] processIdentifier];
    
    NSString *scriptContent = [NSString stringWithFormat:
        @"#!/bin/sh\n"
        @"exec >> /tmp/gox_updater.log 2>&1\n"
        @"echo \"[$(date)] Starting Gox updater for PID %d\"\n"
        @"PID=%d\n"
        @"STAGED_APP=\"%@\"\n"
        @"TARGET_APP=\"%@\"\n"
        @"\n"
        @"while kill -0 \"$PID\" 2>/dev/null; do\n"
        @"    sleep 0.1\n"
        @"done\n"
        @"sleep 0.2\n"
        @"\n"
        @"if [ ! -d \"$STAGED_APP\" ]; then\n"
        @"    echo \"Staged app not found at $STAGED_APP\"\n"
        @"    exit 1\n"
        @"fi\n"
        @"\n"
        @"echo \"Replacing $TARGET_APP with $STAGED_APP...\"\n"
        @"rm -rf \"$TARGET_APP\"\n"
        @"cp -R \"$STAGED_APP\" \"$TARGET_APP\"\n"
        @"\n"
        @"xattr -dr com.apple.quarantine \"$TARGET_APP\" 2>/dev/null || true\n"
        @"rm -rf \"$(dirname \"$STAGED_APP\")\"\n"
        @"\n"
        @"echo \"Launching $TARGET_APP...\"\n"
        @"open \"$TARGET_APP\"\n"
        @"echo \"Done.\"\n",
        pid, pid, stagedApp, bundlePath];
    
    NSError *writeErr = nil;
    [scriptContent writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:&writeErr];
    if (writeErr) {
        NSLog(@"[GoxUpdater] Error writing relaunch script: %@", writeErr);
        return;
    }
    
    chmod([scriptPath UTF8String], 0755);
    
    @try {
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/bin/sh";
        task.arguments = @[scriptPath];
        [task launch];
    } @catch (NSException *e) {
        NSLog(@"[GoxUpdater] Failed to launch script: %@", e);
        return;
    }
    
    [NSApp terminate:nil];
}

+(NSString*)getApplicationSupportFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths firstObject];
    return [NSString stringWithFormat:@"%@/Gox", applicationSupportDirectory];
}
@end
