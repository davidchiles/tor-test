//
//  TRTRecordViewController.m
//  TorTest
//
//  Created by David Chiles on 9/24/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTRecordViewController.h"
#import "TRTTestRecord.h"

@interface TRTRecordViewController ()

@property (nonatomic, strong)TRTTestRecord *testRecord;

@end

@implementation TRTRecordViewController

- (instancetype)initWithRecord:(TRTTestRecord *)record
{
    if (self = [self init]) {
        self.testRecord = record;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

@end
