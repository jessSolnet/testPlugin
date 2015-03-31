#import "HWPHello.h"

@implementation HWPHello

- (void)greet:(CDVInvokedUrlCommand*)command
{

    NSString* callbackId = [command callbackId];
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msg];

    [self sendMessage: msg];
    
    [self success:result callbackId:callbackId];
}

- (void) sendMessage: (NSString *)message
{
    NSString *urlString = [NSString stringWithFormat: "%@%@", "http://10.1.40.159:8080/snitchspring/CrashListener?data=", message];
    NSURL *url = [NSURL URLWithString:urlString];
    [NSURLRequest requestWithURL:url];
}

@end