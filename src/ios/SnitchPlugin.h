//
//  SnitchPlugin.h
//

#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>

@interface SnitchPlugin : CDVPlugin <BITHockeyManagerDelegate, BITUpdateManagerDelegate,BITCrashManagerDelegate>

- (void)forcecrash:(CDVInvokedUrlCommand*)command;

@end