//
//  TRTDatabaseModel.h
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "MTLModel+NSCoding.h"

@class YapDatabaseReadWriteTransaction,YapDatabaseReadTransaction;

@interface TRTDatabaseModel : MTLModel

@property (nonatomic, strong, readonly) NSString *uniqueID;

- (instancetype)initWithUniqueID:(NSString *)uniqueID;
- (void)saveWithTransaction:(YapDatabaseReadWriteTransaction *)transaction;

+ (NSString *)collection;
+ (instancetype)fetchObjectWithUniqueID:(NSString*)uniqueID transaction:(YapDatabaseReadTransaction*)transaction;

@end
