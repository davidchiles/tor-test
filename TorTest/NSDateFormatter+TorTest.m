//
//  NSDateFormatter+TorTest.m
//  TorTest
//
//  Created by David Chiles on 9/24/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "NSDateFormatter+TorTest.h"

@implementation NSDateFormatter (TorTest)


+ (instancetype)trt_defaultDateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    return dateFormatter;
}

@end
