//
//  TRTTestRecord.h
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTDatabaseModel.h"
#import "Reachability.h"

@interface TRTTestRecord : TRTDatabaseModel

@property (nonatomic, strong) NSDate *backgroundLaunchStartDate;
@property (nonatomic, strong) NSDate *backgroundLaunchEndDate;
@property (nonatomic, strong) NSDate *torStartDate;
@property (nonatomic, strong) NSDate *torConnectionDate;
@property (nonatomic, strong) NSDate *urlStartDate;
@property (nonatomic, strong) NSDate *urlEndDate;
@property (nonatomic, strong) NSNumber *numberOfBytes;
@property (nonatomic) NetworkStatus networkType;

- (NSTimeInterval)launchTime;
- (NSTimeInterval)torConnectionTime;
- (NSTimeInterval)urlFetchTime;

@end
