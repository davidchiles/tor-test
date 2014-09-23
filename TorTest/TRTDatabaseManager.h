//
//  TRTDatabaseManager.h
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YapDatabase;
@class YapDatabaseConnection;

extern NSString *TRTUIDatabaseConnectionWillUpdateNotification;
extern NSString *TRTUIDatabaseConnectionDidUpdateNotification;

@interface TRTDatabaseManager : NSObject

@property (nonatomic, strong, readonly) YapDatabase *database;
@property (nonatomic, strong, readonly) YapDatabaseConnection *mainThreadReadOnlyConnection;
@property (nonatomic, strong, readonly) YapDatabaseConnection *readWriteConnection;

- (BOOL)setupDatabaseWithName:(NSString *)name;

+ (instancetype) sharedInstance;

@end
