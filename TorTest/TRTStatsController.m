//
//  TRTStatsController.m
//  TorTest
//
//  Created by David Chiles on 9/24/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTStatsController.h"
#import "TRTDatabaseManager.h"
#import "YapDatabaseConnection.h"
#import "YapDatabaseTransaction.h"
#import "TRTTestRecord.h"

@interface TRTStatsController ()

@property (nonatomic) NSUInteger numberOfRecords;
@property (nonatomic) NSUInteger numberWifi;
@property (nonatomic) NSUInteger numberWWan;
@property (nonatomic) NSUInteger numberNoConnection;
@property (nonatomic) NSTimeInterval averageBackgroundTime;
@property (nonatomic) NSTimeInterval averageTorConnectionTime;
@property (nonatomic) NSTimeInterval averageURLRequestTime;
@property (nonatomic) double averageNumberOfBytes;

@end


@implementation TRTStatsController


- (void)calculateStatsWithCompletion:(void (^)(NSError *error))completion
{
    
    __block NSUInteger tempNumberOfRecords = 0;
    __block NSUInteger tempNumberWifi = 0;
    __block NSUInteger tempNumberWWan = 0;
    __block NSUInteger tempNumberNoConnection = 0;
    __block NSTimeInterval totalBackgroundTime = 0;
    __block NSTimeInterval totalTorConnectionTime = 0;
    __block NSTimeInterval totalUrlRequestTime = 0;
    __block NSUInteger totalNumberOfBytes = 0;
    
    [[TRTDatabaseManager sharedInstance].readWriteConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
    
        [transaction enumerateKeysAndObjectsInCollection:[TRTTestRecord collection] usingBlock:^(NSString *key, id object, BOOL *stop) {
            if ([object isKindOfClass:[TRTTestRecord class]]) {
                TRTTestRecord *record = (TRTTestRecord *)object;
                
                tempNumberOfRecords++;
                switch (record.networkType) {
                    case ReachableViaWiFi:
                        tempNumberWifi++;
                        break;
                    case ReachableViaWWAN:
                        tempNumberWWan++;
                        break;
                    case NotReachable:
                        tempNumberNoConnection++;
                        break;
                }
                
                totalBackgroundTime += [record launchTime];
                totalTorConnectionTime += [record torConnectionTime];
                totalUrlRequestTime += [record urlFetchTime];
                totalNumberOfBytes += record.numberOfBytes.unsignedIntegerValue;
            }
        }];
        
    } completionBlock:^{
        
        self.numberOfRecords = tempNumberOfRecords;
        self.numberWifi = tempNumberWifi;
        self.numberWWan = tempNumberWWan;
        self.numberNoConnection = tempNumberNoConnection;
        
        if (self.numberOfRecords > 0) {
            self.averageBackgroundTime = totalBackgroundTime/self.numberOfRecords;
            self.averageTorConnectionTime = totalTorConnectionTime/self.numberOfRecords;
            self.averageURLRequestTime = totalUrlRequestTime/self.numberOfRecords;
            self.averageNumberOfBytes = totalNumberOfBytes/self.numberOfRecords;
        }
        else {
            self.averageBackgroundTime = 0;
            self.averageTorConnectionTime = 0;
            self.averageURLRequestTime = 0;
            self.averageNumberOfBytes = 0;
        }
        
        
        if (completion) {
            completion(nil);
        }
    }];
}

@end
