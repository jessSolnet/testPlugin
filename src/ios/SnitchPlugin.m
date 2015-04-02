#import "SnitchPlugin.h"
#import <CrashReporter/CrashReporter.h>


@implementation SnitchPlugin

- (void)onStartup:(CDVInvokedUrlCommand*)command
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
    NSString * encodedMessage = (NSString *)  CFBridgingRelease((NULL,
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


//
// Called to handle a pending crash report.
//
- (void) handleCrashReport {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSData *crashData;
    NSError *error;
    
    // Try loading the crash report
    crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
    if (crashData == nil) {
        NSLog(@"Could not load crash report: %@", error);
        goto finish;
        }
    
    // We could send the report from here, but we'll just print out
    // some debugging info instead
    PLCrashReport *report = [[[PLCrashReport alloc] initWithData: crashData error: &error] autorelease];
    if (report == nil) {
        NSLog(@"Could not parse crash report");
        goto finish;
        }
    
    NSString *message = [NSString stringWithFormat@"Crashed on %@\r\nCrashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.systemInfo.timestamp, report.signalInfo.name, report.signalInfo.code, report.signalInfo.address);
                         
    [self sendMessage: message];
    
    // Purge the report
    finish:
    [crashReporter purgePendingCrashReport];
    return;
    }

// from UIApplicationDelegate protocol
- (void) applicationDidFinishLaunching: (UIApplication *) application {
    [self sendMessage: @"applicationDidFinishLaunching"]
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    
    // Check if we previously crashed
    if ([crashReporter hasPendingCrashReport])
        [self handleCrashReport];
    // Enable the Crash Reporter
    if (![crashReporter enableCrashReporterAndReturnError: &error])
        NSLog(@"Warning: Could not enable crash reporter: %@", error);
    
    }



@end