//
//  TRTLabelValueViewObject.m
//  TorTest
//
//  Created by David Chiles on 9/24/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTLabelValueViewObject.h"

@implementation TRTLabelValueViewObject

- (instancetype)initWithLabelString:(NSString *)labelString valueString:(NSString *)valueString
{
    if (self = [self init]) {
        self.labelString = labelString;
        self.valueString = valueString;
    }
    return self;
}

+ (instancetype)labelViewObjectWithLabelString:(NSString *)labelString valueString:(NSString *)valueString
{
    return [[self alloc] initWithLabelString:labelString valueString:valueString];
}

@end
