//
//  AppDelegate.m
//  ModernKey
//
//  Created by Tuyen on 1/18/19.
//  Copyright © 2019 Tuyen Mai. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>
#import <IOKit/IOKitLib.h>
#include <libproc.h>
#include <sys/proc_info.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import "OpenKeyManager.h"
#import "MJAccessibilityUtils.h"

AppDelegate* appDelegate;
extern ViewController* viewController;
extern void OnTableCodeChange(void);
extern void OnInputMethodChanged(void);
extern void RequestNewSession(void);
extern void OnActiveAppChanged(void);
extern void updateInputSourceState(void);
extern volatile BOOL isNonLatinInputActive;

//see document in Engine.h
int vLanguage = 1;
int vInputType = 0;
int vFreeMark = 0;
int vCodeTable = 0;
int vCheckSpelling = 1;
int vUseModernOrthography = 1;
int vQuickTelex = 0;
#define DEFAULT_SWITCH_STATUS 0x7A000206 //default option + z
int vSwitchKeyStatus = DEFAULT_SWITCH_STATUS;
int vRestoreIfWrongSpelling = 0;
int vFixRecommendBrowser = 1;
int vUseMacro = 1;
int vUseMacroInEnglishMode = 1;
int vAutoCapsMacro = 0;
int vSendKeyStepByStep = 0;
int vUseSmartSwitchKey = 1;
int vUpperCaseFirstChar = 0;
int vTempOffSpelling = 0;
int vAllowConsonantZFWJ = 0;
int vQuickStartConsonant = 0;
int vQuickEndConsonant = 0;
int vRememberCode = 1; //new on version 2.0
int vOtherLanguage = 1; //new on version 2.0
int vTempOffOpenKey = 0; //new on version 2.0

int vShowIconOnDock = 0; //new on version 2.0

int vPerformLayoutCompat = 0;

//beta feature
int vFixChromiumBrowser = 0; //new on version 2.0

extern int convertToolHotKey;
extern bool convertToolDontAlertWhenCompleted;

@interface AppDelegate ()

@end


@implementation AppDelegate {
    NSWindowController *_mainWC;
    NSWindowController *_macroWC;
    NSWindowController *_convertWC;
    NSWindowController *_aboutWC;
    
    NSStatusItem *statusItem;
    NSMenu *theMenu;
    
    NSMenuItem* menuInputMethod;
    
    NSMenuItem* mnuTelex;
    NSMenuItem* mnuVNI;
    NSMenuItem* mnuSimpleTelex1;
    NSMenuItem* mnuSimpleTelex2;
    
    NSMenuItem* mnuUnicode;
    NSMenuItem* mnuTCVN;
    NSMenuItem* mnuVNIWindows;
    
    NSMenuItem* mnuUnicodeComposite;
    NSMenuItem* mnuVietnameseLocaleCP1258;
    
    NSMenuItem* mnuQuickConvert;
    
    NSMenuItem* menuUpdateAvailable;
    NSMenuItem* menuUpdateSeparator;
    NSMenuItem* menuSecureInputWarning;
    NSMenuItem* menuSecureInputSeparator;
    NSTimer* accessibilityPollTimer;
    NSTimer* secureInputPollTimer;
    NSTimeInterval lastSecureInputTime;
    NSString* lastSecureInputAppName;
    pid_t lastSecureInputPID;
    
    NSImage* redStatusImage;
    NSTimer* secureInputFlashTimer;
    int secureInputFlashCount;
    BOOL secureInputFlashPhase;
    BOOL wasSecureInputActive;
}

-(void)askPermission {
    [self waitForAccessibilityPermission];
}

-(void)waitForAccessibilityPermission {
    MJAccessibilityOpenPanel();
    
    if (accessibilityPollTimer == nil) {
        accessibilityPollTimer = [NSTimer scheduledTimerWithTimeInterval:0.8
                                                                  target:self
                                                                selector:@selector(pollAccessibilityPermission:)
                                                                userInfo:nil
                                                                 repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:accessibilityPollTimer forMode:NSRunLoopCommonModes];
    }
}

-(void)pollAccessibilityPermission:(NSTimer *)timer {
    if (MJAccessibilityIsEnabled()) {
        [accessibilityPollTimer invalidate];
        accessibilityPollTimer = nil;
        NSLog(@"[Gox] Accessibility permission granted dynamically!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupGox];
        });
    }
}

- (void)setupGox {
    if (statusItem != nil) {
        return;
    }
    NSLog(@"[Gox] Accessibility is enabled! Proceeding to setup.");
    
    vShowIconOnDock = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"vShowIconOnDock"];
    if (vShowIconOnDock)
        [NSApp setActivationPolicy: NSApplicationActivationPolicyRegular];
    else
        [NSApp setActivationPolicy: NSApplicationActivationPolicyAccessory];
    
    if (vSwitchKeyStatus & 0x8000)
        NSBeep();

    [self createStatusBarMenu];
    
    //init
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![OpenKeyManager initEventTap]) {
            [self onControlPanelSelected];
        } else {
            NSInteger showui = [[NSUserDefaults standardUserDefaults] integerForKey:@"ShowUIOnStartup"];
            if (showui == 1) {
                [self onControlPanelSelected];
            }
        }
        [self setQuickConvertString];
    });
    
    //load default config if is first launch
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"NonFirstTime"] == 0) {
        [self loadDefaultConfig];
    }
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"NonFirstTime"];
    
    //auto update setup: 24h periodic check, staged updates
    [OpenKeyManager startAutoUpdateTimer];
    
    //correct run on startup
    NSInteger val = [[NSUserDefaults standardUserDefaults] integerForKey:@"RunOnStartup"];
    [appDelegate setRunOnStartup:val];
    
    //initialize input source state
    updateInputSourceState();
    
    // periodic secure input watcher (every 1.0s, negligible overhead)
    secureInputPollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector(checkSecureInputPeriodic:)
                                                          userInfo:nil
                                                           repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:secureInputPollTimer forMode:NSRunLoopCommonModes];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"[Gox] Launching, myPID=%d", [[NSProcessInfo processInfo] processIdentifier]);
    appDelegate = self;
    
    [self registerSupportedNotification];
    
    //set quick tooltip
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: 50]
                                              forKey: @"NSInitialToolTipDelay"];
    
    //check whether this app has been launched before that or not
    //Only check instances owned by current user (for multi-user/Fast User Switching support)
    uid_t currentUID = getuid();
    NSArray<NSRunningApplication *>* runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    pid_t myPID = [[NSProcessInfo processInfo] processIdentifier];
    BOOL alreadyRunning = NO;

    for (NSRunningApplication *app in runningApps) {
        if ([app.bundleIdentifier isEqualToString:OPENKEY_BUNDLE] &&
            app.processIdentifier != myPID &&
            !app.isTerminated) {
            pid_t pid = app.processIdentifier;
            struct proc_bsdinfo proc;
            int size = proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &proc, sizeof(proc));
            if (size == sizeof(proc) && proc.pbi_uid == currentUID && kill(pid, 0) == 0) {
                NSLog(@"[Gox] Instance already running with PID %d", pid);
                alreadyRunning = YES;
                break;
            }
        }
    }

    if (alreadyRunning) {
        NSLog(@"[Gox] Terminating because already running.");
        [NSApp terminate:nil];
        return;
    }
    
    // check if user granted Accessabilty permission
    if (!MJAccessibilityIsEnabled()) {
        NSLog(@"[Gox] Accessibility is NOT enabled, waiting for permission.");
        [self waitForAccessibilityPermission];
        return;
    }
    
    [self setupGox];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!MJAccessibilityIsEnabled()) {
        [self waitForAccessibilityPermission];
        return YES;
    }
    [self onControlPanelSelected];
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    if (accessibilityPollTimer != nil) {
        [accessibilityPollTimer invalidate];
        accessibilityPollTimer = nil;
    }
    if (secureInputPollTimer != nil) {
        [secureInputPollTimer invalidate];
        secureInputPollTimer = nil;
    }
    if (secureInputFlashTimer != nil) {
        [secureInputFlashTimer invalidate];
        secureInputFlashTimer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDistributedCenter(),
                                       (__bridge const void *)(self),
                                       kTISNotifySelectedKeyboardInputSourceChanged,
                                       NULL);
}

-(void) createStatusBarMenu {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    statusItem.button.image = [NSImage imageNamed:@"Status"];
    statusItem.button.alternateImage = [NSImage imageNamed:@"StatusHighlighted"];
    
    // Pre-create red tinted status image for secure input alert
    NSImage *statusSrc = [NSImage imageNamed:@"Status"];
    if (statusSrc) {
        redStatusImage = [statusSrc copy];
        [redStatusImage lockFocus];
        [[NSColor colorWithSRGBRed:0.95 green:0.22 blue:0.22 alpha:1.0] set];
        NSRect rect = NSMakeRect(0, 0, redStatusImage.size.width, redStatusImage.size.height);
        NSRectFillUsingOperation(rect, NSCompositingOperationSourceAtop);
        [redStatusImage unlockFocus];
        [redStatusImage setTemplate:NO];
    }
    
    theMenu = [[NSMenu alloc] initWithTitle:@""];
    [theMenu setAutoenablesItems:NO];
    [theMenu setDelegate:self];
    
    menuInputMethod = [theMenu addItemWithTitle:@"Bật Tiếng Việt"
                                                     action:@selector(onInputMethodSelected)
                                              keyEquivalent:@""];
    [theMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem* menuInputType = [theMenu addItemWithTitle:@"Kiểu gõ" action:nil keyEquivalent:@""];
    
    [theMenu addItem:[NSMenuItem separatorItem]];
    
    mnuUnicode = [theMenu addItemWithTitle:@"Unicode dựng sẵn" action:@selector(onCodeSelected:) keyEquivalent:@""];
    mnuUnicode.tag = 0;
    mnuTCVN = [theMenu addItemWithTitle:@"TCVN3 (ABC)" action:@selector(onCodeSelected:) keyEquivalent:@""];
    mnuTCVN.tag = 1;
    mnuVNIWindows = [theMenu addItemWithTitle:@"VNI Windows" action:@selector(onCodeSelected:) keyEquivalent:@""];
    mnuVNIWindows.tag = 2;
    NSMenuItem* menuCode = [theMenu addItemWithTitle:@"Bảng mã khác" action:nil keyEquivalent:@""];
    
    [theMenu addItem:[NSMenuItem separatorItem]];
    
    [theMenu addItemWithTitle:@"Công cụ chuyển mã..." action:@selector(onConvertTool) keyEquivalent:@""];
    mnuQuickConvert = [theMenu addItemWithTitle:@"Chuyển mã nhanh" action:@selector(onQuickConvert) keyEquivalent:@""];
    
    [theMenu addItem:[NSMenuItem separatorItem]];
    
    [theMenu addItemWithTitle:@"Bảng điều khiển..." action:@selector(onControlPanelSelected) keyEquivalent:@""];
    [theMenu addItemWithTitle:@"Gõ tắt..." action:@selector(onMacroSelected) keyEquivalent:@""];
    [theMenu addItemWithTitle:@"Giới thiệu" action:@selector(onAboutSelected) keyEquivalent:@""];
    [theMenu addItem:[NSMenuItem separatorItem]];
    
    [theMenu addItemWithTitle:@"Thoát" action:@selector(terminate:) keyEquivalent:@"q"];
    
    
    [self setInputTypeMenu:menuInputType];
    [self setCodeMenu:menuCode];
    
    //set menu
    [statusItem setMenu:theMenu];
    
    [self fillData];
}

-(void)updateSwitchKeyShortcut {
    if (!menuInputMethod) {
        return;
    }
    
    NSEventModifierFlags modifierMask = 0;
    if (vSwitchKeyStatus & 0x100) {
        modifierMask |= NSEventModifierFlagControl;
    }
    if (vSwitchKeyStatus & 0x200) {
        modifierMask |= NSEventModifierFlagOption;
    }
    if (vSwitchKeyStatus & 0x400) {
        modifierMask |= NSEventModifierFlagCommand;
    }
    if (vSwitchKeyStatus & 0x800) {
        modifierMask |= NSEventModifierFlagShift;
    }
    
    unsigned short k = ((vSwitchKeyStatus >> 24) & 0xFF);
    NSString *keyEquivalent = @"";
    
    if (k != 0 && k != 0xFE) {
        if (k == kVK_Space || k == ' ') {
            keyEquivalent = @" ";
        } else {
            keyEquivalent = [[NSString stringWithFormat:@"%c", k] lowercaseString];
        }
    } else if (modifierMask != 0) {
        keyEquivalent = @"\u200B";
    }
    
    [menuInputMethod setKeyEquivalent:keyEquivalent];
    [menuInputMethod setKeyEquivalentModifierMask:modifierMask];
}

extern CFDictionaryRef CGSCopyCurrentSessionDictionary(void);

#ifndef kIOMainPortDefault
#define kIOMainPortDefault MACH_PORT_NULL
#endif

static pid_t findSecureInputPIDFromIORegistry(void) {
    pid_t resultPID = 0;
    io_registry_entry_t root = IORegistryGetRootEntry(kIOMainPortDefault);
    if (root == MACH_PORT_NULL) {
        return 0;
    }
    CFTypeRef sessionInfo = IORegistryEntrySearchCFProperty(
        root,
        kIOServicePlane,
        CFSTR("IOConsoleUsers"),
        kCFAllocatorDefault,
        kIORegistryIterateRecursively
    );
    IOObjectRelease(root);
    
    if (sessionInfo) {
        if (CFGetTypeID(sessionInfo) == CFArrayGetTypeID()) {
            NSArray *sessions = (__bridge NSArray *)sessionInfo;
            for (NSDictionary *session in sessions) {
                if ([session isKindOfClass:[NSDictionary class]]) {
                    NSNumber *pidNum = session[@"kCGSSessionSecureInputPID"];
                    if (pidNum && [pidNum isKindOfClass:[NSNumber class]]) {
                        resultPID = [pidNum intValue];
                        if (resultPID > 0) {
                            break;
                        }
                    }
                }
            }
        }
        CFRelease(sessionInfo);
    }
    return resultPID;
}

static NSString* resolveApplicationNameForPID(pid_t pid) {
    if (pid <= 0) return nil;
    NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
    if (app) {
        NSString *name = app.localizedName;
        NSString *bundleID = app.bundleIdentifier;
        if ([bundleID containsString:@"com.google.Chrome"] || [name containsString:@"Chrome"]) {
            return @"Google Chrome";
        }
        if ([bundleID containsString:@"com.apple.Safari"] || [name containsString:@"Safari"]) {
            return @"Safari";
        }
        if ([bundleID containsString:@"company.thebrowser.Browser"] || [name containsString:@"Arc"]) {
            return @"Arc";
        }
        if ([bundleID containsString:@"com.brave.Browser"] || [name containsString:@"Brave"]) {
            return @"Brave";
        }
        if ([bundleID containsString:@"com.microsoft.Edge"] || [name containsString:@"Edge"]) {
            return @"Microsoft Edge";
        }
        if (name.length > 0 && ![name containsString:@"Helper"]) {
            return name;
        }
    }
    
    struct proc_bsdinfo proc;
    if (proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &proc, sizeof(proc)) == sizeof(proc)) {
        if (proc.pbi_ppid > 1) {
            NSRunningApplication *parentApp = [NSRunningApplication runningApplicationWithProcessIdentifier:proc.pbi_ppid];
            if (parentApp) {
                NSString *pName = parentApp.localizedName;
                NSString *pBundle = parentApp.bundleIdentifier;
                if ([pBundle containsString:@"com.google.Chrome"] || [pName containsString:@"Chrome"]) {
                    return @"Google Chrome";
                }
                if (pName.length > 0 && ![pName containsString:@"Helper"]) return pName;
            }
        }
    }
    
    return app.localizedName;
}

- (NSString *)detectSecureInputAppName {
    NSString *appName = nil;
    pid_t detectedPID = findSecureInputPIDFromIORegistry();
    
    if (detectedPID > 0) {
        appName = resolveApplicationNameForPID(detectedPID);
        self->lastSecureInputPID = detectedPID;
    }
    
    if (detectedPID <= 0 || !appName) {
        CFDictionaryRef dict = CGSCopyCurrentSessionDictionary();
        if (dict) {
            NSDictionary *d = (__bridge NSDictionary *)dict;
            NSNumber *pidNum = d[@"kCGSSessionSecureInputPID"];
            if (pidNum && [pidNum intValue] > 0) {
                detectedPID = [pidNum intValue];
                appName = resolveApplicationNameForPID(detectedPID);
                self->lastSecureInputPID = detectedPID;
            }
            CFRelease(dict);
        }
    }
    
    // Guarded fallback: ONLY attribute to frontmost application IF it is a known browser or password manager
    if (appName == nil || [appName containsString:@"Helper"] || [appName hasPrefix:@"PID "]) {
        NSRunningApplication *front = [[NSWorkspace sharedWorkspace] frontmostApplication];
        if (front && front.bundleIdentifier.length > 0) {
            NSString *bId = front.bundleIdentifier.lowercaseString;
            NSString *lName = front.localizedName.lowercaseString;
            BOOL isBrowserOrSecurityApp = [bId containsString:@"chrome"] ||
                                          [bId containsString:@"safari"] ||
                                          [bId containsString:@"arc"] ||
                                          [bId containsString:@"brave"] ||
                                          [bId containsString:@"edge"] ||
                                          [bId containsString:@"firefox"] ||
                                          [bId containsString:@"1password"] ||
                                          [bId containsString:@"bitwarden"] ||
                                          [bId containsString:@"keepass"] ||
                                          [lName containsString:@"chrome"] ||
                                          [lName containsString:@"safari"] ||
                                          [lName containsString:@"browser"];
            if (isBrowserOrSecurityApp) {
                detectedPID = front.processIdentifier;
                appName = resolveApplicationNameForPID(detectedPID) ?: front.localizedName;
                self->lastSecureInputPID = detectedPID;
            }
        }
    }
    
    if (appName.length > 0) {
        self->lastSecureInputAppName = appName;
    }
    return appName;
}

- (void)onOpenSecureInputAppSelected:(id)sender {
    if (self->lastSecureInputPID > 0) {
        NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:self->lastSecureInputPID];
        if (app) {
            [app activateWithOptions:NSApplicationActivateIgnoringOtherApps];
            return;
        }
    }
    if (self->lastSecureInputAppName.length > 0) {
        NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
        for (NSRunningApplication *app in apps) {
            if ([app.localizedName isEqualToString:self->lastSecureInputAppName] ||
                ([self->lastSecureInputAppName isEqualToString:@"Google Chrome"] && [app.bundleIdentifier containsString:@"Chrome"])) {
                [app activateWithOptions:NSApplicationActivateIgnoringOtherApps];
                break;
            }
        }
    }
}

- (void)updateStatusIcon {
    if (!statusItem) return;
    NSInteger grayIcon = [[NSUserDefaults standardUserDefaults] integerForKey:@"GrayIcon"];
    BOOL isSecure = IsSecureEventInputEnabled();
    
    if (vLanguage == 1) { // Vietnamese mode
        if (isSecure) {
            if (secureInputFlashTimer != nil && secureInputFlashPhase == NO) {
                // Flash off-phase: display standard icon
                statusItem.button.image = [NSImage imageNamed:@"Status"];
                [statusItem.button.image setTemplate:(grayIcon ? YES : NO)];
            } else {
                // Flash on-phase or solid red
                statusItem.button.image = redStatusImage ?: [NSImage imageNamed:@"Status"];
                [statusItem.button.image setTemplate:NO];
            }
            statusItem.button.alternateImage = [NSImage imageNamed:@"StatusHighlighted"];
            if (lastSecureInputAppName.length > 0) {
                statusItem.button.toolTip = [NSString stringWithFormat:@"⚠️ %@ đang khóa phím", lastSecureInputAppName];
            } else {
                statusItem.button.toolTip = @"⚠️ Đang bị khóa phím bởi ô mật khẩu";
            }
            return;
        }
        
        // Normal V mode
        statusItem.button.image = [NSImage imageNamed:@"Status"];
        [statusItem.button.image setTemplate:(grayIcon ? YES : NO)];
        statusItem.button.alternateImage = [NSImage imageNamed:@"StatusHighlighted"];
        statusItem.button.toolTip = nil;
    } else { // English mode: never red, never blink
        statusItem.button.image = [NSImage imageNamed:@"StatusEng"];
        [statusItem.button.image setTemplate:(grayIcon ? YES : NO)];
        statusItem.button.alternateImage = [NSImage imageNamed:@"StatusHighlightedEng"];
        statusItem.button.toolTip = nil;
    }
}

- (void)stopSecureInputFlash {
    if (secureInputFlashTimer != nil) {
        [secureInputFlashTimer invalidate];
        secureInputFlashTimer = nil;
    }
    secureInputFlashCount = 0;
    secureInputFlashPhase = NO;
}

- (void)onSecureInputFlashTick:(NSTimer *)timer {
    if (!IsSecureEventInputEnabled() || vLanguage != 1) {
        [self stopSecureInputFlash];
        [self updateStatusIcon];
        return;
    }
    
    secureInputFlashPhase = !secureInputFlashPhase;
    [self updateStatusIcon];
    
    secureInputFlashCount--;
    if (secureInputFlashCount <= 0) {
        [self stopSecureInputFlash];
        [self updateStatusIcon];
    }
}

- (void)startSecureInputFlash {
    [self stopSecureInputFlash];
    if (vLanguage != 1) return;
    
    secureInputFlashCount = 6;
    secureInputFlashPhase = YES;
    [self updateStatusIcon];
    
    secureInputFlashTimer = [NSTimer scheduledTimerWithTimeInterval:0.35
                                                             target:self
                                                           selector:@selector(onSecureInputFlashTick:)
                                                           userInfo:nil
                                                            repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:secureInputFlashTimer forMode:NSRunLoopCommonModes];
}

- (void)checkSecureInputPeriodic:(NSTimer *)timer {
    BOOL isSecure = IsSecureEventInputEnabled();
    if (isSecure) {
        self->lastSecureInputTime = [NSDate timeIntervalSinceReferenceDate];
        NSString *name = [self detectSecureInputAppName];
        if (name.length > 0) {
            self->lastSecureInputAppName = name;
        }
        
        if (!self->wasSecureInputActive) {
            self->wasSecureInputActive = YES;
            if (vLanguage == 1) {
                [self startSecureInputFlash];
            } else {
                [self updateStatusIcon];
            }
        } else if (self->secureInputFlashTimer == nil) {
            [self updateStatusIcon];
        }
    } else {
        if (self->wasSecureInputActive) {
            self->wasSecureInputActive = NO;
            [self stopSecureInputFlash];
            [self updateStatusIcon];
        }
    }
}

- (void)updateSecureInputWarning {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    Boolean isSecure = IsSecureEventInputEnabled();
    BOOL wasRecentlySecure = (now - self->lastSecureInputTime < 4.0);
    
    if (isSecure || wasRecentlySecure) {
        NSString *appName = [self detectSecureInputAppName];
        if (!appName && wasRecentlySecure) {
            appName = self->lastSecureInputAppName;
        }
        if (!appName) {
            appName = @"Google Chrome";
        }
        
        NSString *title = [NSString stringWithFormat:@"⚠️ %@ đang khóa phím: Bấm để mở & click ra ngoài ô password", appName];
        NSString *toolTip = [NSString stringWithFormat:@"macOS tự động khóa bàn phím để bảo vệ mật khẩu trên %@. Bấm vào đây để mở cửa sổ đó, sau đó click chuột ra ngoài ô password để gõ tiếng Việt bình thường.", appName];
        
        if (menuSecureInputWarning) {
            [menuSecureInputWarning setTitle:title];
            [menuSecureInputWarning setToolTip:toolTip];
        } else {
            menuSecureInputWarning = [[NSMenuItem alloc] initWithTitle:title action:@selector(onOpenSecureInputAppSelected:) keyEquivalent:@""];
            [menuSecureInputWarning setTarget:self];
            [menuSecureInputWarning setEnabled:YES];
            [menuSecureInputWarning setToolTip:toolTip];
            menuSecureInputSeparator = [NSMenuItem separatorItem];
            
            [theMenu insertItem:menuSecureInputSeparator atIndex:0];
            [theMenu insertItem:menuSecureInputWarning atIndex:0];
        }
    } else {
        if (menuSecureInputWarning) {
            [theMenu removeItem:menuSecureInputWarning];
            menuSecureInputWarning = nil;
        }
        if (menuSecureInputSeparator) {
            [theMenu removeItem:menuSecureInputSeparator];
            menuSecureInputSeparator = nil;
        }
    }
}

- (void)menuWillOpen:(NSMenu *)menu {
    if (menu == theMenu) {
        [self updateSwitchKeyShortcut];
        [self updateSecureInputWarning];
    }
}

-(void)setQuickConvertString {
    NSMutableString* hotKey = [NSMutableString stringWithString:@""];
    bool hasAdd = false;
    if (convertToolHotKey & 0x100) {
        [hotKey appendString:@"⌃"];
        hasAdd = true;
    }
    if (convertToolHotKey & 0x200) {
        if (hasAdd)
            [hotKey appendString:@" + "];
        [hotKey appendString:@"⌥"];
        hasAdd = true;
    }
    if (convertToolHotKey & 0x400) {
        if (hasAdd)
            [hotKey appendString:@" + "];
        [hotKey appendString:@"⌘"];
        hasAdd = true;
    }
    if (convertToolHotKey & 0x800) {
        if (hasAdd)
            [hotKey appendString:@" + "];
        [hotKey appendString:@"⇧"];
        hasAdd = true;
    }
    
    unsigned short k = ((convertToolHotKey>>24) & 0xFF);
    if (k != 0xFE) {
        if (hasAdd)
            [hotKey appendString:@" + "];
        if (k == kVK_Space)
            [hotKey appendFormat:@"%@", @"␣ "];
        else
            [hotKey appendFormat:@"%c", k];
    }
    [mnuQuickConvert setTitle: hasAdd ? [NSString stringWithFormat:@"Chuyển mã nhanh - [%@]", [hotKey uppercaseString]] : @"Chuyển mã nhanh"];
}

-(void)loadDefaultConfig {
    vLanguage = 1; [[NSUserDefaults standardUserDefaults] setInteger:vLanguage forKey:@"InputMethod"];
    vInputType = 0; [[NSUserDefaults standardUserDefaults] setInteger:vInputType forKey:@"InputType"];
    vFreeMark = 0; [[NSUserDefaults standardUserDefaults] setInteger:vFreeMark forKey:@"FreeMark"];
    vCheckSpelling = 1; [[NSUserDefaults standardUserDefaults] setInteger:vCheckSpelling forKey:@"Spelling"];
    vCodeTable = 0; [[NSUserDefaults standardUserDefaults] setInteger:vCodeTable forKey:@"CodeTable"];
    vSwitchKeyStatus = DEFAULT_SWITCH_STATUS; [[NSUserDefaults standardUserDefaults] setInteger:vSwitchKeyStatus forKey:@"SwitchKeyStatus"];
    vQuickTelex = 0; [[NSUserDefaults standardUserDefaults] setInteger:vQuickTelex forKey:@"QuickTelex"];
    vUseModernOrthography = 0; [[NSUserDefaults standardUserDefaults] setInteger:vUseModernOrthography forKey:@"ModernOrthography"];
    vRestoreIfWrongSpelling = 0; [[NSUserDefaults standardUserDefaults] setInteger:vRestoreIfWrongSpelling forKey:@"RestoreIfInvalidWord"];
    vFixRecommendBrowser = 1; [[NSUserDefaults standardUserDefaults] setInteger:vFixRecommendBrowser forKey:@"FixRecommendBrowser"];
    vUseMacro = 1; [[NSUserDefaults standardUserDefaults] setInteger:vUseMacro forKey:@"UseMacro"];
    vUseMacroInEnglishMode = 0; [[NSUserDefaults standardUserDefaults] setInteger:vUseMacroInEnglishMode forKey:@"UseMacroInEnglishMode"];
    vSendKeyStepByStep = 0;[[NSUserDefaults standardUserDefaults] setInteger:vUseMacroInEnglishMode forKey:@"SendKeyStepByStep"];
    vUseSmartSwitchKey = 1;[[NSUserDefaults standardUserDefaults] setInteger:vUseSmartSwitchKey forKey:@"UseSmartSwitchKey"];
    vUpperCaseFirstChar = 0;[[NSUserDefaults standardUserDefaults] setInteger:vUpperCaseFirstChar forKey:@"UpperCaseFirstChar"];
    vTempOffSpelling = 0;[[NSUserDefaults standardUserDefaults] setInteger:vTempOffSpelling forKey:@"vTempOffSpelling"];
    vAllowConsonantZFWJ = 0;[[NSUserDefaults standardUserDefaults] setInteger:vAllowConsonantZFWJ forKey:@"vAllowConsonantZFWJ"];
    vQuickStartConsonant = 0;[[NSUserDefaults standardUserDefaults] setInteger:vQuickStartConsonant forKey:@"vQuickStartConsonant"];
    vQuickEndConsonant = 0;[[NSUserDefaults standardUserDefaults] setInteger:vQuickEndConsonant forKey:@"vQuickEndConsonant"];
    vRememberCode = 1;[[NSUserDefaults standardUserDefaults] setInteger:vRememberCode forKey:@"vRememberCode"];
    vOtherLanguage = 1;[[NSUserDefaults standardUserDefaults] setInteger:vOtherLanguage forKey:@"vOtherLanguage"];
    vTempOffOpenKey = 0;[[NSUserDefaults standardUserDefaults] setInteger:vTempOffOpenKey forKey:@"vTempOffOpenKey"];
    vShowIconOnDock = 0;[[NSUserDefaults standardUserDefaults] setInteger:vShowIconOnDock forKey:@"vShowIconOnDock"];
    vFixChromiumBrowser = 0;[[NSUserDefaults standardUserDefaults] setInteger:vFixChromiumBrowser forKey:@"vFixChromiumBrowser"];
    vPerformLayoutCompat = 0;[[NSUserDefaults standardUserDefaults] setInteger:vPerformLayoutCompat forKey:@"vPerformLayoutCompat"];

    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"GrayIcon"];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"RunOnStartup"];

    [self fillData];
    [viewController fillData];
}

-(void)setRunOnStartup:(BOOL)val {
    NSString *helperPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Library/LoginItems/GoxHelper.app"];
    CFStringRef appId = (__bridge CFStringRef)@"com.tuyennq1001.goxhelper";
    if (![[NSFileManager defaultManager] fileExistsAtPath:helperPath]) {
        SMLoginItemSetEnabled(appId, NO);
        return;
    }
    SMLoginItemSetEnabled(appId, val);
}

-(void)setGrayIcon:(BOOL)val {
    [self fillData];
}

-(void)showIconOnDock:(BOOL)val {
    [NSApp setActivationPolicy: val ? NSApplicationActivationPolicyRegular : NSApplicationActivationPolicyAccessory];
}

#pragma mark -StatusBar menu data

- (void)setInputTypeMenu:(NSMenuItem*) parent {
    //sub for Kieu Go
    NSMenu *sub = [[NSMenu alloc] initWithTitle:@""];
    [sub setAutoenablesItems:NO];
    mnuTelex = [sub addItemWithTitle:@"Telex" action:@selector(onInputTypeSelected:) keyEquivalent:@""];
    mnuTelex.tag = 0;
    mnuVNI = [sub addItemWithTitle:@"VNI" action:@selector(onInputTypeSelected:) keyEquivalent:@""];
    mnuVNI.tag = 1;
    mnuSimpleTelex1 = [sub addItemWithTitle:@"Simple Telex 1" action:@selector(onInputTypeSelected:) keyEquivalent:@""];
    mnuSimpleTelex1.tag = 2;
    mnuSimpleTelex2 = [sub addItemWithTitle:@"Simple Telex 2" action:@selector(onInputTypeSelected:) keyEquivalent:@""];
    mnuSimpleTelex2.tag = 3;
    [theMenu setSubmenu:sub forItem:parent];
}

- (void)setCodeMenu:(NSMenuItem*) parent {
    //sub for Code
    NSMenu *sub = [[NSMenu alloc] initWithTitle:@""];
    [sub setAutoenablesItems:NO];
    mnuUnicodeComposite = [sub addItemWithTitle:@"Unicode tổ hợp" action:@selector(onCodeSelected:) keyEquivalent:@""];
    mnuUnicodeComposite.tag = 3;
    mnuVietnameseLocaleCP1258 = [sub addItemWithTitle:@"Vietnamese Locale CP 1258" action:@selector(onCodeSelected:) keyEquivalent:@""];
    mnuVietnameseLocaleCP1258.tag = 4;
    
    [theMenu setSubmenu:sub forItem:parent];
}

- (void) fillData {
    //fill data
    NSInteger intInputMethod = [[NSUserDefaults standardUserDefaults] integerForKey:@"InputMethod"];
    if (intInputMethod == 1) {
        [menuInputMethod setState:NSControlStateValueOn];
    } else {
        [menuInputMethod setState:NSControlStateValueOff];
    }
    vLanguage = (int)intInputMethod;
    if (vLanguage == 0 && secureInputFlashTimer != nil) {
        [self stopSecureInputFlash];
    }
    [self updateStatusIcon];
    
    NSInteger intInputType = [[NSUserDefaults standardUserDefaults] integerForKey:@"InputType"];
    [mnuTelex setState:NSControlStateValueOff];
    [mnuVNI setState:NSControlStateValueOff];
    [mnuSimpleTelex1 setState:NSControlStateValueOff];
    [mnuSimpleTelex2 setState:NSControlStateValueOff];
    if (intInputType == 0) {
        [mnuTelex setState:NSControlStateValueOn];
    } else if (intInputType == 1) {
        [mnuVNI setState:NSControlStateValueOn];
    } else if (intInputType == 2) {
        [mnuSimpleTelex1 setState:NSControlStateValueOn];
    } else if (intInputType == 3) {
        [mnuSimpleTelex2 setState:NSControlStateValueOn];
    }
    vInputType = (int)intInputType;
    
    NSInteger intSwitchKeyStatus = [[NSUserDefaults standardUserDefaults] integerForKey:@"SwitchKeyStatus"];
    vSwitchKeyStatus = (int)intSwitchKeyStatus;
    if (vSwitchKeyStatus == 0)
        vSwitchKeyStatus = DEFAULT_SWITCH_STATUS;
    [self updateSwitchKeyShortcut];
    
    NSInteger intCode = [[NSUserDefaults standardUserDefaults] integerForKey:@"CodeTable"];
    [mnuUnicode setState:NSControlStateValueOff];
    [mnuTCVN setState:NSControlStateValueOff];
    [mnuVNIWindows setState:NSControlStateValueOff];
    [mnuUnicodeComposite setState:NSControlStateValueOff];
    [mnuVietnameseLocaleCP1258 setState:NSControlStateValueOff];
    if (intCode == 0) {
        [mnuUnicode setState:NSControlStateValueOn];
    } else if (intCode == 1) {
        [mnuTCVN setState:NSControlStateValueOn];
    } else if (intCode == 2) {
        [mnuVNIWindows setState:NSControlStateValueOn];
    } else if (intCode == 3) {
        [mnuUnicodeComposite setState:NSControlStateValueOn];
    } else if (intCode == 4) {
        [mnuVietnameseLocaleCP1258 setState:NSControlStateValueOn];
    }
    vCodeTable = (int)intCode;
}

-(void)onImputMethodChanged:(BOOL)willNotify {
    NSInteger intInputMethod = [[NSUserDefaults standardUserDefaults] integerForKey:@"InputMethod"];
    if (intInputMethod == 0)
        intInputMethod = 1;
    else
        intInputMethod = 0;
    vLanguage = (int)intInputMethod;
    [[NSUserDefaults standardUserDefaults] setInteger:intInputMethod forKey:@"InputMethod"];

    [self fillData];
    [viewController fillData];
    
    if (willNotify)
        OnInputMethodChanged();
}

#pragma mark -StatusBar menu action
- (void)onInputMethodSelected {
    [self onImputMethodChanged:YES];
}

- (void)onInputTypeSelected:(id)sender {
    NSMenuItem *menuItem = (NSMenuItem*) sender;
    [self onInputTypeSelectedIndex:(int)menuItem.tag];
}

- (void)onInputTypeSelectedIndex:(int)index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"InputType"];
    vInputType = index;
    [self fillData];
    [viewController fillData];
}

- (void)onCodeTableChanged:(int)index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"CodeTable"];
    vCodeTable = index;
    [self fillData];
    [viewController fillData];
    OnTableCodeChange();
}

- (void)onCodeSelected:(id)sender {
    NSMenuItem *menuItem = (NSMenuItem*) sender;
    [self onCodeTableChanged:(int)menuItem.tag];
}

-(void)onConvertTool {
    if (_convertWC == nil) {
        _convertWC = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"ConvertWindow"];
    }
    //[OpenKeyManager showDockIcon:YES];
    if ([_convertWC.window isVisible])
        return;
    [_convertWC.window makeKeyAndOrderFront:nil];
    [_convertWC.window setLevel:NSFloatingWindowLevel];
}

-(void)onQuickConvert {
    if ([OpenKeyManager quickConvert]) {
        if (!convertToolDontAlertWhenCompleted) {
            [OpenKeyManager showMessage: nil message:@"Chuyển mã thành công!" subMsg:@"Kết quả đã được lưu trong clipboard."];
        }
    } else {
        [OpenKeyManager showMessage: nil message:@"Không có dữ liệu trong clipboard!" subMsg:@"Hãy sao chép một đoạn text để chuyển đổi!"];
    }
}

-(void) onControlPanelSelected {
    if (_mainWC == nil) {
        _mainWC = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Gox"];
    }
    //[OpenKeyManager showDockIcon:YES];
    if ([_mainWC.window isVisible]) {
        return;
    }
    [_mainWC.window makeKeyAndOrderFront:nil];
    [_mainWC.window setLevel:NSFloatingWindowLevel];
}

-(void) onMacroSelected {
    if (_macroWC == nil) {
        _macroWC = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"MacroWindow"];
    }
    //[OpenKeyManager showDockIcon:YES];
    if ([_macroWC.window isVisible])
        return;
    
    [_macroWC.window makeKeyAndOrderFront:nil];
    [_macroWC.window setLevel:NSFloatingWindowLevel];
}

-(void) onAboutSelected {
    if (_aboutWC == nil) {
        _aboutWC = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"AboutWindow"];
    }
    //[OpenKeyManager showDockIcon:YES];
    if ([_aboutWC.window isVisible])
        return;

    [_aboutWC.window makeKeyAndOrderFront:nil];
    [_aboutWC.window setLevel:NSFloatingWindowLevel];
}

#pragma mark -Short key event
-(void)onSwitchLanguage {
    [self onInputMethodSelected];
    [viewController fillData];
}

static void onCarbonInputSourceChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [(__bridge AppDelegate *)observer inputSourceChanged:nil];
}

-(void)inputSourceChanged:(NSNotification *)notification {
    RequestNewSession();
    updateInputSourceState();
}

#pragma mark Reset OpenKey after mac computer awake
-(void)receiveWakeNote: (NSNotification*)note {
    [OpenKeyManager initEventTap];
    updateInputSourceState();
    [OpenKeyManager checkDueOnWake];
}

-(void)receiveSleepNote: (NSNotification*)note {
    [OpenKeyManager stopEventTap];
}

-(void)receiveActiveSpaceChanged: (NSNotification*)note {
    RequestNewSession();
}

-(void)activeAppChanged: (NSNotification*)note {
    if ([OpenKeyManager isInited]) {
        RequestNewSession();
    }
    updateInputSourceState();
    if (vUseSmartSwitchKey && [OpenKeyManager isInited]) {
        OnActiveAppChanged();
    }
}

-(void)registerSupportedNotification {
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNote:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveActiveSpaceChanged:)
                                                               name: NSWorkspaceActiveSpaceDidChangeNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(activeAppChanged:)
                                                               name: NSWorkspaceDidActivateApplicationNotification object: NULL];

    // Cocoa notification for keyboard input source selection change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputSourceChanged:)
                                                 name:NSTextInputContextKeyboardSelectionDidChangeNotification
                                               object:nil];

    // Carbon distributed notification for selected keyboard input source change
    CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
                                    (__bridge const void *)(self),
                                    onCarbonInputSourceChanged,
                                    kTISNotifySelectedKeyboardInputSourceChanged,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

#pragma mark - In-App Auto Update Menu Item

- (void)showRestartToUpdateMenu:(NSString *)versionName {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title = [NSString stringWithFormat:@"✨ Có bản mới (v%@), nhấn để khởi động lại", versionName];
        if (self->menuUpdateAvailable) {
            [self->menuUpdateAvailable setTitle:title];
            return;
        }
        
        self->menuUpdateAvailable = [[NSMenuItem alloc] initWithTitle:title
                                                               action:@selector(onRestartToUpdateSelected:)
                                                        keyEquivalent:@""];
        [self->menuUpdateAvailable setTarget:self];
        self->menuUpdateSeparator = [NSMenuItem separatorItem];
        
        [self->theMenu insertItem:self->menuUpdateSeparator atIndex:0];
        [self->theMenu insertItem:self->menuUpdateAvailable atIndex:0];
    });
}

- (void)hideRestartToUpdateMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->menuUpdateAvailable) {
            [self->theMenu removeItem:self->menuUpdateAvailable];
            self->menuUpdateAvailable = nil;
        }
        if (self->menuUpdateSeparator) {
            [self->theMenu removeItem:self->menuUpdateSeparator];
            self->menuUpdateSeparator = nil;
        }
    });
}

- (void)onRestartToUpdateSelected:(id)sender {
    [OpenKeyManager applyUpdateAndRestart];
}

@end
