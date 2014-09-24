//
//  TRTStatsController.h
//  TorTest
//
//  Created by David Chiles on 9/24/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRTStatsController : UIViewController

@property (nonatomic, readonly) NSUInteger numberOfRecords;
@property (nonatomic, readonly) double percentageSuccesfulRecords;
@property (nonatomic, readonly) NSUInteger numberWifi;
@property (nonatomic, readonly) NSUInteger numberWWan;
@property (nonatomic, readonly) NSUInteger numberNoConnection;
@property (nonatomic, readonly) NSTimeInterval averageBackgroundTime;
@property (nonatomic, readonly) NSTimeInterval averageTorConnectionTime;
@property (nonatomic, readonly) NSTimeInterval averageURLRequestTime;
@property (nonatomic, readonly) double averageNumberOfBytes;


- (void)calculateStatsWithCompletion:(void (^)(NSError *error))completion;


@end
