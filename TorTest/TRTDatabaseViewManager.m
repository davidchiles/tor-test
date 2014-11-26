//
//  TRTDatabaseViewManager.m
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTDatabaseViewManager.h"
#import "YapDatabase.h"
#import "YapDatabaseView.h"
#import "TRTTestRecord.h"

NSString *TRTAllRecordsViewName = @"TRTAllRecordsViewName";
NSString *TRTAllRecordsGroupName = @"TRTAllRecordsGroupName";

@implementation TRTDatabaseViewManager

+ (BOOL)setupViewsWithDatabase:(YapDatabase*)database
{
    BOOL success = YES;
    if (success) success = [self setupAllRecordsViewWithDatabase:database];
    
    return success;
}

+ (BOOL)setupAllRecordsViewWithDatabase:(YapDatabase *)database
{
    if ([database registeredExtension:TRTAllRecordsViewName]) {
        return YES;
    }
    
    YapDatabaseViewGrouping *grouping = [YapDatabaseViewGrouping withKeyBlock:^NSString *(NSString *collection, NSString *key) {
        if ([collection isEqualToString:[TRTTestRecord collection]]) {
            return TRTAllRecordsGroupName;
        }
        return nil;
    }];
    
    YapDatabaseViewSorting *sorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        
        if ([object1 isKindOfClass:[TRTTestRecord class]] && [object2 isKindOfClass:[TRTTestRecord class]]) {
            TRTTestRecord *record1 = (TRTTestRecord *)object1;
            TRTTestRecord *record2 = (TRTTestRecord *)object2;
            
            return [record1.backgroundLaunchStartDate compare:record2.backgroundLaunchStartDate];
        }
        return NSOrderedSame;
    }];
    
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    options.isPersistent = YES;
    options.allowedCollections = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:[TRTTestRecord collection]]];
    
    YapDatabaseView *databaseView =
    [[YapDatabaseView alloc] initWithGrouping:grouping
                                      sorting:sorting
                                   versionTag:@"1"
                                      options:options];
    return [database registerExtension:databaseView withName:TRTAllRecordsViewName];
    
}

@end
