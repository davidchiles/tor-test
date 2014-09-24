//
//  TRTStatsViewController.m
//  TorTest
//
//  Created by David Chiles on 9/24/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTStatsViewController.h"
#import "TRTStatsController.h"
#import "TRTLabelValueViewObject.h"

@interface TRTStatsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) TRTStatsController *statsController;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation TRTStatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataArray = [NSArray array];
    
    self.statsController = [TRTStatsController new];
    __block UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    [self.statsController calculateStatsWithCompletion:^(NSError *error) {
        [self loadData];
        [tableView reloadData];
    }];
    
    
}

- (void)loadData
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Number Of Records"
                                                                     valueString:[NSString stringWithFormat:@"%ld",self.statsController.numberOfRecords]]];
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Wifi"
                                                           valueString:[NSString stringWithFormat:@"%ld",self.statsController.numberWifi]]];
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Cell"
                                                           valueString:[NSString stringWithFormat:@"%ld",self.statsController.numberWWan]]];
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"No Connection"
                                                           valueString:[NSString stringWithFormat:@"%ld",self.statsController.numberNoConnection]]];
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Average Total Time"
                                                           valueString:[NSString stringWithFormat:@"%1.2f s",self.statsController.averageBackgroundTime]]];
    [tempArray addObject:[TRTLabelValueViewObject labelViewObjectWithLabelString:@"Average Tor Connection Time"
                                                           valueString:[NSString stringWithFormat:@"%1.2f s",self.statsController.averageTorConnectionTime]]];
    
    
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
    
    TRTLabelValueViewObject *dataView = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = dataView.labelString;
    cell.detailTextLabel.text = dataView.valueString;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
