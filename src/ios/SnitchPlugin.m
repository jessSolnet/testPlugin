#import "SnitchPlugin.h"

@implementation SnitchPlugin

- (void)greet:(CDVInvokedUrlCommand*)command
{

    NSString* callbackId = [command callbackId];
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];

    NSString* msgAndResponse = [self sendMessage: msg];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msgAndResponse];
    
    [self success:result callbackId:callbackId];
}

- (NSString *) sendMessage: (NSString *)message
{
    NSString *urlString = [NSString stringWithFormat: @"%@%@", @"http://10.1.40.159:8080/snitchspring/CrashListener?data=", message];
    NSURL *url = [NSURL URLWithString:urlString];
    NSError* error = nil;
    NSString *response =  [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
    return [NSString stringWithFormat: @"%@: %@", message, response];
}

@end