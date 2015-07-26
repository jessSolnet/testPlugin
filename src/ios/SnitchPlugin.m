#import "SnitchPlugin.h"
#import "CrashReporter.h"

#define kCrashFileName @"CrashReport"

@implementation SnitchPlugin

static NSString *crashPath;
static BOOL _hasCrashReportPending;

/** getter for hasCrashReportPending */
+ (BOOL)hasCrashReportPending {
    return _hasCrashReportPending;
}

/* A custom post-crash callback */
- (void) post_crash_callback (siginfo_t *info, ucontext_t *uap, void *context) {
    // this is not async-safe, but this is a test implementation
    NSLog(@"post crash callback: signo=%d, uap=%p, context=%p", info->si_signo, uap, context);
    NSString *msg = [NSString stringWithFormat: @"post crash callback: signo=%d, uap=%p, context=%p", info->si_signo, uap, context];
    NSString* msgAndResponse = [self sendMessage: msg];

}

- (void) onStartup:(CDVInvokedUrlCommand*)command
{
    NSLog(@"           Here1");
    
    NSString* callbackId = [command callbackId];
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];

    NSString* msgAndResponse = [self sendMessage: msg];
    NSLog(@"           Here2");
    
    /* Save any existing crash report. */
    save_crash_report();
    NSLog(@"           Here3");

    /* Set up post-crash callbacks */
    PLCrashReporterCallbacks cb = {
        .version = 0,
        .context = (void *) 0xABABABAB,
        .handleSignal = [self post_crash_callback]
    };
    [[PLCrashReporter sharedReporter] setCrashCallbacks: &cb];
    
//        NSError *error = nil;
//    /* Enable the crash reporter */
//    if (![[PLCrashReporter sharedReporter] enableCrashReporterAndReturnError: &error]) {
//        NSLog(@"Could not enable crash reporter: %@", error);
//    }
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msgAndResponse];
    
    [self success:result callbackId:callbackId];
}

/* If a crash report exists, make it accessible via iTunes document sharing. This is a no-op on Mac OS X. */
- (void) save_crash_report() {
    if (![[PLCrashReporter sharedReporter] hasPendingCrashReport])
        return;
    
#if TARGET_OS_IPHONE
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (![fm createDirectoryAtPath: documentsDirectory withIntermediateDirectories: YES attributes:nil error: &error]) {
        NSLog(@"Could not create documents directory: %@", error);
        return;
    }
    
    
    NSData *data = [[PLCrashReporter sharedReporter] loadPendingCrashReportDataAndReturnError: &error];
    if (data == nil) {
        NSLog(@"Failed to load crash report data: %@", error);
        return;
    }
    
    NSString *outputPath = [documentsDirectory stringByAppendingPathComponent: @"demo.plcrash"];
    if (![data writeToFile: outputPath atomically: YES]) {
        NSLog(@"Failed to write crash report");
    }
    NSLog(@"Saved crash report to: %@", outputPath);

    NSString *msg = [NSString stringWithFormat: @"Saved crash report to: %@", outputPath];
    NSString* msgAndResponse = [self sendMessage: msg];

#endif
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