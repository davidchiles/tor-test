//
//  TorManager.h
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRTTorManager : NSObject

@property (nonatomic, strong, readonly) NSString *hostname;
@property (nonatomic, readonly) NSUInteger port;

- (void)startTorWithCompletion:(void (^)(NSString *host,NSUInteger port,NSError *error))completion;

+ (instancetype)sharedInstance;

@end
