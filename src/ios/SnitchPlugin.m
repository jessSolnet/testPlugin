 //
//  SnitchPlugin.m
//

#import "SnitchPlugin.h"
#import "CrashReporter.h"

@interface SnitchPlugin ()

@end

@implementation SnitchPlugin


- (void)pluginInitialize {
}


- (void)forcecrash:(CDVInvokedUrlCommand *)command {
  [self handleCrashReport];
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
         // Purge the report
         [crashReporter purgePendingCrashReport];
         return;
     }

    PLCrashReport *report = [[PLCrashReport alloc] initWithData: crashData error: &error];
    if (report == nil) {
        NSLog(@"Could not parse crash report");
        // Purge the report
        [crashReporter purgePendingCrashReport];
        return;
    }

    //NSLog(@"Crashed on %@", report.systemInfo.timestamp);
    //NSLog(@"Crashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.signalInfo.name,
    //report.signalInfo.code, report.signalInfo.address);
    //NSLog(@"Crashed");
    [self sendCrashReport: report];

}

- (void) sendCrashReport: (PLCrashReport *) report{
    NSURL *url = [NSURL URLWithString:@"http://10.1.40.159:8080/snitchspring/CrashListener"]
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/json" forHTTPHeaderField:@"Content-type"];
    
    NSString *jsonString = [NSString stringWithFormat: @"{ dateTime: '%@', signalCode: '%@', signalName: '%@'}", report.systemInfo.timestamp, report.signalInfo.signalCode, report.signalInfo.signalName];

    [request setValue:[[NSString stringWithFormat:@"%d", [jsonString length]]
                       forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[NSURLConnection alloc]
     initWithRequest:request
     delegate:self];
}


// from UIApplicationDelegate protocol
- (void) applicationDidFinishLaunching: (UIApplication *) application {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    // Check if we previously crashed
    if ([crashReporter hasPendingCrashReport])
        [self handleCrashReport];
    // Enable the Crash Reporter
    if (![crashReporter enableCrashReporterAndReturnError: &error])
       NSLog(@"Warning: Could not enable crash reporter: %@", error);
    NSLog(@"Launched");

}
@end