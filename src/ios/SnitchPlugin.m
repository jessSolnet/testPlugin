#import "SnitchPlugin.h"

@implementation SnitchPlugin

- (id)init
{
    self = [super init];
    if (self)
    {
        [self sendMessage: @"plugin initialised"];
    }
    return self;
}

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
    NSString * encodedMessage = (NSString *)  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                        (CFStringRef) message,
                                                                                                        NULL,
                                                                                                        (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                                                        kCFStringEncodingUTF8));
    NSString *urlString = [NSString stringWithFormat: @"%@%@", @"http://10.1.40.159:8080/snitchspring/CrashListener?data=", encodedMessage];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", urlString, (long)[responseCode statusCode]);
        return nil;
    }
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

@end