#import "SnitchPlugin.h"
#import "CrashReporter.h"

#define kCrashFileName @"CrashReport"

@implementation SnitchPlugin

- (void) onStartup:(CDVInvokedUrlCommand*)command
{
    NSLog(@"           Here1");
    
    NSString* callbackId = [command callbackId];
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];

    NSString* msgAndResponse = [self sendMessage: msg];
    NSLog(@"           Here2");
}



- (NSString *) sendMessage: (NSString *)message
{
    
    NSString * encodedMessage = (NSString *)  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) message, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    
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