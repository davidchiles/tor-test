//
//  TRTDatabaseViewManager.h
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YapDatabase;

extern NSString *TRTAllRecordsViewName;
extern NSString *TRTAllRecordsGroupName;

@interface TRTDatabaseViewManager : NSObject

+ (BOOL)setupViewsWithDatabase:(YapDatabase*)database;

@end
