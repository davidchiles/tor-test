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
            
            // Create a NSURLSessionConfiguration that uses the newly setup SOCKS proxy
            NSDictionary *proxyDict = @{
                                        (NSString *)kCFStreamPropertySOCKSProxyHost : @"127.0.0.1",
                                        (NSString *)kCFStreamPropertySOCKSProxyPort : @(9050)
                                        };
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            configuration.connectionProxyDictionary = proxyDict;
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            
            //NSURL *url = [NSURL URLWithString:@"https://check.torproject.org/"];
            //duckduckgo NSURL *url = [NSURL URLWithString:@"http://3g2upl4pq6kufc4m.onion/"];
            NSURL *url = [NSURL URLWithString:@"http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"];
            
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
