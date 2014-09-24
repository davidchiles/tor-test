//
//  TorManager.h
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRTTorManager : NSObject

- (void)startTorWithCompletion:(void (^)(NSError *error))completion;
- (BOOL)isTorRunning;

- (NSString *)hostname;
- (NSNumber *)port;

+ (instancetype)sharedInstance;

@end
