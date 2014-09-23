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
    
    YapDatabaseViewBlockType groupingBlockType;
    YapDatabaseViewGroupingWithKeyBlock groupingBlock;
    
    YapDatabaseViewBlockType sortingBlockType;
    YapDatabaseViewSortingWithObjectBlock sortingBlock;
    
    groupingBlockType = YapDatabaseViewBlockTypeWithKey;
    groupingBlock = ^NSString *(NSString *collection, NSString *key){
        if ([collection isEqualToString:[TRTTestRecord collection]]) {
            return TRTAllRecordsGroupName;
        }
        return nil;
    };
    
    sortingBlockType = YapDatabaseViewBlockTypeWithObject;
    sortingBlock = ^(NSString *group, NSString *collection1, NSString *key1, id obj1,
                                    NSString *collection2, NSString *key2, id obj2){
        
        if ([obj1 isKindOfClass:[TRTTestRecord class]] && [obj2 isKindOfClass:[TRTTestRecord class]]) {
            TRTTestRecord *record1 = (TRTTestRecord *)obj1;
            TRTTestRecord *record2 = (TRTTestRecord *)obj2;
            
            return [record1.backgroundLaunchStartDate compare:record2.backgroundLaunchStartDate];
        }
        return NSOrderedSame;
    };
    
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    options.isPersistent = YES;
    options.allowedCollections = [NSSet setWithObject:[TRTTestRecord collection]];
    
    YapDatabaseView *databaseView =
    [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock
                                 groupingBlockType:groupingBlockType
                                      sortingBlock:sortingBlock
                                  sortingBlockType:sortingBlockType
                                        versionTag:@""
                                           options:options];
    return [database registerExtension:databaseView withName:TRTAllRecordsViewName];
    
}

@end
