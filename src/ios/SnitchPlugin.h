#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface SnitchPlugin : CDVPlugin

- (void) onStartup:(CDVInvokedUrlCommand*)command;
@property BOOL crashReportComplete;

@end