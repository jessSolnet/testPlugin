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


//
// Called to handle a pending crash report.
//
    - (void)handleCrashReport {
    	PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    	NSData *crashData;
    	NSError *error;

    	// Try loading the crash report
    	crashData = [crashReporter loadPendingCrashReportDataAndReturnError:&error];
    	if (crashData == nil) {
    		NSLog(@"Could not load crash report: %@", error);
    		return;
    	}

    	// We could send the report from here, but we'll just print out
    	// some debugging info instead
        PLCrashReport *report = [[PLCrashReport alloc] initWithData:crashData error:&error];
    //	PLCrashReport *report = [[PLCrashReport alloc] initWithData:crashData error:&error];
    	if (report == nil) {
    		NSLog(@"Could not parse crash report");
    		return;
    	}

    	NSString *message = [NSString stringWithFormat: @"Crashed on %@\r\nCrashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.systemInfo.timestamp, report.signalInfo.name, report.signalInfo.code, report.signalInfo.address];
        
        [self sendMessage: message];
        [self saveCrashReport:crashReporter];


    	return;
    }

/** Method runs, if a crash report exists, make it accessible via iTunes document sharing. This is a no-op on Mac OS X.
 @param crashReporter:PLCrashReporter instance to be used
 */
- (void)saveCrashReport:(PLCrashReporter *)reporter {
    if (![reporter hasPendingCrashReport])
        return;
    
#if TARGET_OS_IPHONE
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (![fm createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Could not create documents directory: %@", error);
        return;
    }
    
    
    NSData *data = [[PLCrashReporter sharedReporter] loadPendingCrashReportDataAndReturnError:&error];
    if (data == nil) {
        NSLog(@"Failed to load crash report data: %@", error);
        return;
    }
    
    NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:kCrashFileName];
    if (![data writeToFile:outputPath atomically:YES]) {
        NSLog(@"Failed to write crash report");
        return;
    }
    
    crashPath = outputPath;
    [reporter purgePendingCrashReport];
    self.crashReportComplete = YES;
    
#endif
}


/**
 Method to check for any crashes, only call from UIApplicationDelegate
 */
- (void)checkForCrashes {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    
    // Check if we previously crashed
    _hasCrashReportPending = [crashReporter hasPendingCrashReport];
    if (_hasCrashReportPending) {
        self.crashReportComplete = NO;
        [self handleCrashReport];
    }
    // Enable the Crash Reporter
    if (![crashReporter enableCrashReporterAndReturnError:&error])
        NSLog(@"Warning: Could not enable crash reporter: %@", error);
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