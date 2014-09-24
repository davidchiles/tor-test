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
    return MAX([self.backgroundLaunchEndDate timeIntervalSinceDate:self.backgroundLaunchStartDate], 0);
}

- (NSTimeInterval)torConnectionTime
{
    return MAX([self.torConnectionDate timeIntervalSinceDate:self.torStartDate], 0);
}

- (NSTimeInterval)urlFetchTime
{
    return MAX([self.urlEndDate timeIntervalSinceDate:self.urlStartDate], 0);
}

@end
