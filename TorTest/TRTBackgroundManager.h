//
//  TRTBackgroundManager.h
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface TRTBackgroundManager : NSObject

- (void)backgroundFetchWithCompletion:(void (^)(UIBackgroundFetchResult result))completion;

@end
