//
//  SnitchPlugin.h
//

#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>

@interface SnitchPlugin : CDVPlugin
- (void)forcecrash:(CDVInvokedUrlCommand*)command;

@end
