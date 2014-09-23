//
//  TRTDatabaseManager.m
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTDatabaseManager.h"
#import "YapDatabase.h"
#import "YapDatabaseConnection.h"

NSString *TRTUIDatabaseConnectionWillUpdateNotification = @"TRTUIDatabaseConnectionWillUpdateNotification";
NSString *TRTUIDatabaseConnectionDidUpdateNotification = @"TRTUIDatabaseConnectionDidUpdateNotification";

@interface TRTDatabaseManager ()

@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *mainThreadReadOnlyConnection;
@property (nonatomic, strong) YapDatabaseConnection *readWriteConnection;
@property (nonatomic, strong) id <NSObject> yapDatabaseObserver;

@end

@implementation TRTDatabaseManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.yapDatabaseObserver];
}

- (NSString *)yapDatabaseDirectory {
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    NSString *directory = [applicationSupportDirectory stringByAppendingPathComponent:applicationName];
    return directory;
}

- (NSString *)yapDatabasePathWithName:(NSString *)name
{
    
    return [[self yapDatabaseDirectory] stringByAppendingPathComponent:name];
}

- (BOOL)setupDatabaseWithName:(NSString *)name
{
    YapDatabaseOptions *options = [[YapDatabaseOptions alloc] init];
    options.corruptAction = YapDatabaseCorruptAction_Fail;
    
    NSString *databaseDirectory = [self yapDatabaseDirectory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:databaseDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:databaseDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *databasePath = [self yapDatabasePathWithName:name];
    
    self.database = [[YapDatabase alloc] initWithPath:databasePath
                                     objectSerializer:NULL
                                   objectDeserializer:NULL
                                   metadataSerializer:NULL
                                 metadataDeserializer:NULL
                                      objectSanitizer:NULL
                                    metadataSanitizer:NULL
                                              options:options];
    self.database.defaultObjectPolicy = YapDatabasePolicyShare;
    self.database.defaultObjectCacheEnabled = YES;
    self.database.defaultObjectCacheLimit = 10000;
    self.database.defaultMetadataCacheEnabled = NO;
    self.readWriteConnection = [self.database newConnection];
    self.readWriteConnection.objectPolicy = YapDatabasePolicyShare;
    self.readWriteConnection.name = @"readWriteDatabaseConnection";
    self.mainThreadReadOnlyConnection = [self.database newConnection];
    self.mainThreadReadOnlyConnection.name = @"mainThreadReadOnlyDatabaseConnection";
    [self.mainThreadReadOnlyConnection enableExceptionsForImplicitlyEndingLongLivedReadTransaction];
    
    [self.mainThreadReadOnlyConnection beginLongLivedReadTransaction];
    
    __weak TRTDatabaseManager *welf = self;
    self.yapDatabaseObserver = [[NSNotificationCenter defaultCenter] addObserverForName:YapDatabaseModifiedNotification object:self.database queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [welf yapDatabaseModified:note];
    }];
    
    if (self.database) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)yapDatabaseModified:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TRTUIDatabaseConnectionWillUpdateNotification
                                                        object:self];
    
    NSArray *notifications = [self.mainThreadReadOnlyConnection beginLongLivedReadTransaction];
    
    NSDictionary *userInfo = @{ @"notifications": notifications };
    [[NSNotificationCenter defaultCenter] postNotificationName:TRTUIDatabaseConnectionDidUpdateNotification
                                                        object:self
                                                      userInfo:userInfo];
}


+ (instancetype)sharedInstance
{
    static id databaseManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseManager = [[[self class] alloc] init];
    });
    
    return databaseManager;
}

@end
