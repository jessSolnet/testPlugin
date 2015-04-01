#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface SnitchPlugin : CDVPlugin

- (void) greet:(CDVInvokedUrlCommand*)command;

@end