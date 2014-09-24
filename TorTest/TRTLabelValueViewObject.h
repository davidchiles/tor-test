//
//  TRTLabelValueViewObject.h
//  TorTest
//
//  Created by David Chiles on 9/24/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRTLabelValueViewObject : NSObject

@property (nonatomic, strong) NSString *labelString;
@property (nonatomic, strong) NSString *valueString;

- (instancetype)initWithLabelString:(NSString *)labelString valueString:(NSString *)valueString;

+ (instancetype)labelViewObjectWithLabelString:(NSString *)labelString valueString:(NSString *)valueString;

@end
