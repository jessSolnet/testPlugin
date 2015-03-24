//
//  SnitchPlugin.m
//

#import <CrashReporter/CrashReporter.h>

#import "SnitchPlugin.h"

@interface SnitchPlugin ()

//@property (nonatomic) DDFileLogger *fileLogger;

@end

@implementation SnitchPlugin


- (void)pluginInitialize {
/*    NSString * hockeyAppKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"HockeyApp App ID"];
    if( hockeyAppKey!=nil && [hockeyAppKey isEqualToString:@""]==NO && [hockeyAppKey rangeOfString:@"HOCKEY_APP_KEY"].location == NSNotFound ){

        // initialize before HockeySDK, so the delegate can access the file logger
        self.fileLogger = [[DDFileLogger alloc] init];
        self.fileLogger.maximumFileSize = (1024 * 64); // 64 KByte
        self.fileLogger.logFileManager.maximumNumberOfLogFiles = 1;
        [self.fileLogger rollLogFileWithCompletionBlock:nil];
        [DDLog addLogger:self.fileLogger];

        [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:hockeyAppKey
                                                             liveIdentifier:hockeyAppKey
                                                                   delegate:self];

        [[BITHockeyManager sharedHockeyManager] startManager];
        [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    }

    DDLogInfo(@"HockeyApp Plugin initialized");*/
}


- (void)forcecrash:(CDVInvokedUrlCommand *)command {
  handleCrashReport();
}

/
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

    NSLog(@"Crashed on %@", report.systemInfo.timestamp);
    NSLog(@"Crashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.signalInfo.name,
    report.signalInfo.code, report.signalInfo.address);

    // Purge the report
    finish:
    [crashReporter purgePendingCrashReport];
    return;
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
}

#pragma mark Logging methods

// get the log content with a maximum byte size
- (NSString *) getLogFilesContentWithMaxSize:(NSInteger)maxSize {
    NSMutableString *description = [NSMutableString string];

    NSArray *sortedLogFileInfos = [[_fileLogger logFileManager] sortedLogFileInfos];
    NSInteger count = [sortedLogFileInfos count];

    // we start from the last one
    for (NSInteger index = count - 1; index >= 0; index--) {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:index];

        NSData *logData = [[NSFileManager defaultManager] contentsAtPath:[logFileInfo filePath]];
        if ([logData length] > 0) {
            NSString *result = [[NSString alloc] initWithBytes:[logData bytes]
                                                        length:[logData length]
                                                      encoding: NSUTF8StringEncoding];

            [description appendString:result];
        }
    }

    if ([description length] > maxSize) {
        description = (NSMutableString *)[description substringWithRange:NSMakeRange([description length]-maxSize-1, maxSize)];
    }

    return description;
}
@end