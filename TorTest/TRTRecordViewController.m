//
//  TRTRecordViewController.m
//  TorTest
//
//  Created by David Chiles on 9/24/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTRecordViewController.h"
#import "TRTTestRecord.h"
#import "TRTLabelValueViewObject.h"
#import "NSDateFormatter+TorTest.h"

@interface TRTRecordViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)TRTTestRecord *testRecord;
@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, strong)NSDateFormatter *dateFormatter;

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
    self.dateFormatter = [NSDateFormatter trt_defaultDateFormatter];
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.title = [self.dateFormatter stringFromDate:self.testRecord.backgroundLaunchStartDate];
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
    [self loadData];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
}

- (void)loadData
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSString *connectionString = @"No Connection";
    if (self.testRecord.networkType == ReachableViaWiFi) {
        connectionString = @"Wifi";
    }
    else if (self.testRecord.networkType == ReachableViaWWAN) {
        connectionString = @"Cell";
    }
    
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Network Type"
                                                                     valueString:connectionString]];
    
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Background Start"
                                                                     valueString:[self.dateFormatter stringFromDate:self.testRecord.backgroundLaunchStartDate]]];
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Background End"
                                                                     valueString:[self.dateFormatter stringFromDate:self.testRecord.backgroundLaunchEndDate]]];
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Background Time"
                                                                     valueString:[NSString stringWithFormat:@"%1.2f s",[self.testRecord launchTime]]]];
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Tor Connection Start"
                                                                     valueString:[self.dateFormatter stringFromDate:self.testRecord.torStartDate]]];
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Tor Connected"
                                                                     valueString:[self.dateFormatter stringFromDate:self.testRecord.torConnectionDate]]];
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Tor Connection Time"
                                                                     valueString:[NSString stringWithFormat:@"%1.2f s",[self.testRecord torConnectionTime]]]];
    
    
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Bytes"
                                                                     valueString:[NSString stringWithFormat:@"%@",self.testRecord.numberOfBytes]]];
    
    
    self.dataArray = tempArray;
}

#pragma - mark UITableViewDataSource Methods

////// Required //////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    TRTLabelValueViewObject *dataView = self.dataArray[indexPath.row];
    cell.textLabel.text = dataView.labelString;
    cell.detailTextLabel.text = dataView.valueString;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
