 //
//  SnitchPlugin.m
//

#import "SnitchPlugin.h"
#import <CrashReporter/CrashReporter.h>

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
//    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
//    NSData *crashData;
//    NSError *error;
//
//     // Try loading the crash report
//     crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
//     if (crashData == nil) {
//         NSLog(@"Could not load crash report: %@", error);
//         // Purge the report
//         [crashReporter purgePendingCrashReport];
//         return;
//     }
//
//    // We could send the report from here, but we'll just print out
//    // some debugging info instead
//    PLCrashReport *report = [[PLCrashReport alloc] initWithData: crashData error: &error];
//    if (report == nil) {
//        NSLog(@"Could not parse crash report");
//        // Purge the report
//        [crashReporter purgePendingCrashReport];
//        return;
//    }
//
//    NSLog(@"Crashed on %@", report.systemInfo.timestamp);
//    NSLog(@"Crashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.signalInfo.name,
//    report.signalInfo.code, report.signalInfo.address);
    NSLog(@"Crashed");

}

// from UIApplicationDelegate protocol
- (void) applicationDidFinishLaunching: (UIApplication *) application {
//    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
//    NSError *error;
//    // Check if we previously crashed
//    if ([crashReporter hasPendingCrashReport])
//        [self handleCrashReport];
//    // Enable the Crash Reporter
//    if (![crashReporter enableCrashReporterAndReturnError: &error])
//       NSLog(@"Warning: Could not enable crash reporter: %@", error);
    NSLog(@"Launched");

}
@end