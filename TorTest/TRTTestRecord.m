//
//  TRTTestRecord.m
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTTestRecord.h"

@implementation TRTTestRecord

- (NSTimeInterval)launchTime
{
    return [self.backgroundLaunchEndDate timeIntervalSinceDate:self.backgroundLaunchStartDate];
}

- (NSTimeInterval)torConnectionTime
{
    return [self.torConnectionDate timeIntervalSinceDate:self.torStartDate];
}

- (NSTimeInterval)urlFetchTime
{
    return [self.urlEndDate timeIntervalSinceDate:self.urlStartDate];
}

@end
