//
//  TRTBackgroundManager.m
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTBackgroundManager.h"
#import "TRTTorManager.h"
#import "TRTTestRecord.h"
#import "YapDatabaseConnection.h"
#import "TRTDatabaseManager.h"
#import "Reachability.h"

@implementation TRTBackgroundManager

- (void)backgroundFetchWithCompletion:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Background Fetch Started";
    notification.alertAction = @"OK";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    
    TRTTorManager *torManager = [TRTTorManager sharedInstance];
    TRTTestRecord *record = [[TRTTestRecord alloc] init];
    record.backgroundLaunchStartDate = [NSDate date];
    record.torStartDate = [NSDate date];
    [[TRTDatabaseManager sharedInstance].readWriteConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [record saveWithTransaction:transaction];
    }];
    [torManager startTorWithCompletion:^(NSError *error) {
        record.torConnectionDate = [NSDate date];
        [[TRTDatabaseManager sharedInstance].readWriteConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [record saveWithTransaction:transaction];
        }];
        
        if (!error) {
            Reachability *reachability = [Reachability reachabilityForInternetConnection];
            [reachability startNotifier];
            
            NetworkStatus status = [reachability currentReachabilityStatus];
            record.networkType = status;
            
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
            
            NSURL *url = [[NSURL alloc] initWithString:@"http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"];
            
            record.urlStartDate = [NSDate date];
            [[TRTDatabaseManager sharedInstance].readWriteConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                [record saveWithTransaction:transaction];
            }];
            NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                record.urlEndDate = [NSDate date];
                record.numberOfBytes = @([data length]);
                
                record.backgroundLaunchEndDate = [NSDate date];
                [[TRTDatabaseManager sharedInstance].readWriteConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    [record saveWithTransaction:transaction];
                } completionBlock:^{
                    if (completionHandler) {
                        if (error) {
                            completionHandler(UIBackgroundFetchResultFailed);
                        }
                        else {
                            completionHandler(UIBackgroundFetchResultNewData);
                        }
                        
                    }
                }];
            }];
            [task resume];
        }
        else if (completionHandler){
            completionHandler(UIBackgroundFetchResultFailed);
        }
        
        
        
    }];
}

@end
