//
//  SnitchPlugin.m
//

#import <HockeySDK/HockeySDK.h>

#import "SnitchPlugin.h"

@interface SnitchPlugin ()

@end

@implementation SnitchPlugin

#pragma mark Initialization

- (void)pluginInitialize {

}

#pragma mark Plugin methods

- (void)forcecrash:(CDVInvokedUrlCommand *)command {
  __builtin_trap();
}

#pragma mark Logging methods

// get the log content with a maximum byte size
- (NSString *) getLogFilesContentWithMaxSize:(NSInteger)maxSize {
    NSMutableString *description = [NSMutableString string];
    
    return description;
}


#pragma mark - BITCrashManagerDelegate

- (NSString *)applicationLogForCrashManager:(BITCrashManager *)crashManager {
    NSString *description = [self getLogFilesContentWithMaxSize:5000]; // 5000 bytes should be enough!
    if ([description length] == 0) {
        return nil;
    } else {
        return description;
    }
}

@end
