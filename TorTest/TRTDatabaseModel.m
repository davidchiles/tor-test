//
//  TRTDatabaseModel.m
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTDatabaseModel.h"
#import "YapDatabaseTransaction.h"

@interface TRTDatabaseModel()

@property (nonatomic, strong) NSString *uniqueID;

@end

@implementation TRTDatabaseModel

- (id)init
{
    if (self = [super init])
    {
        self.uniqueID = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (instancetype)initWithUniqueID:(NSString *)uniqueID{
    if (self = [super init]) {
        self.uniqueID = uniqueID;
    }
    return self;
}

- (void)saveWithTransaction:(YapDatabaseReadWriteTransaction *)transaction {
    [transaction setObject:self forKey:self.uniqueID inCollection:[[self class] collection]];
}

+ (NSString *)collection {
    return NSStringFromClass(self);
}
+ (instancetype)fetchObjectWithUniqueID:(NSString*)uniqueID transaction:(YapDatabaseReadTransaction*)transaction
{
    return [transaction objectForKey:uniqueID inCollection:[self collection]];
}

@end
