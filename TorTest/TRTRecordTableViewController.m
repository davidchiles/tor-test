//
//  TRTRecordTableViewController.m
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTRecordTableViewController.h"
#import "PureLayout.h"
#import "TRTDatabaseViewManager.h"
#import "TRTDatabaseManager.h"
#import "YapDatabaseViewMappings.h"
#import "YapDatabaseConnection.h"
#import "YapDatabaseViewConnection.h"
#import "TRTTestRecord.h"
#import "YapDatabaseTransaction.h"
#import "YapDatabaseViewTransaction.h"
#import "TRTStatsViewController.h"

@interface TRTRecordTableViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YapDatabaseViewMappings *tableViewMappings;
@property (nonatomic, strong) YapDatabaseConnection *databaseConnection;
@property (nonatomic, weak) id<NSObject> databaseObserver;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic) BOOL addedConstraints;

@end

@implementation TRTRecordTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addedConstraints = NO;
    self.title = @"Records";
    
    ////// Database //////
    self.databaseConnection = [TRTDatabaseManager sharedInstance].mainThreadReadOnlyConnection;
    self.tableViewMappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[TRTAllRecordsGroupName] view:TRTAllRecordsViewName];
    [self.databaseConnection beginLongLivedReadTransaction];
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [self.tableViewMappings updateWithTransaction:transaction];
    }];
    
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [transaction enumerateKeysAndObjectsInAllCollectionsUsingBlock:^(NSString *collection, NSString *key, id object, BOOL *stop) {
            NSLog(@"%@ %@",collection,key);
        }];
    }];
    
    __weak TRTRecordTableViewController *welf = self;
    self.databaseObserver = [[NSNotificationCenter defaultCenter] addObserverForName:TRTUIDatabaseConnectionDidUpdateNotification object:[TRTDatabaseManager sharedInstance].database queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [welf yapDatabaseModified:note];
    }];
    
    ////// Nav Bar //////
    
    UIBarButtonItem *statsBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"Stats" style:UIBarButtonItemStylePlain target:self action:@selector(statsButtonPressed:)];
    self.navigationItem.rightBarButtonItem = statsBarButtonItem;
    
    ////// TableView //////
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self.view addSubview:self.tableView];
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        
    }
    return _dateFormatter;
}

- (void)updateViewConstraints
{
    if (!self.addedConstraints) {
        [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        self.addedConstraints = YES;
    }
    [super updateViewConstraints];
}

- (void)statsButtonPressed:(id)sender
{
    TRTStatsViewController *viewController = [[TRTStatsViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (TRTTestRecord *)recordForIndexPath:(NSIndexPath *)indexPath
{
    __block TRTTestRecord *record = nil;
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        record = [[transaction extension:TRTAllRecordsViewName] objectAtIndexPath:indexPath withMappings:self.tableViewMappings];
    }];
    
    return record;
}

#pragma - mark UITableViewDataSource Methods

////// Required //////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableViewMappings numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    TRTTestRecord *record = [self recordForIndexPath:indexPath];
    NSString *dateString = [self.dateFormatter stringFromDate:record.backgroundLaunchStartDate];
    cell.textLabel.text = dateString;
    if (record.backgroundLaunchEndDate) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

////// Optional //////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableViewMappings numberOfSections];
}


#pragma - mark UITableViewDelegate Methods

////// Optional //////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma - mark YapDatabase Methods

- (void)yapDatabaseModified:(NSNotification *)notification
{
    NSArray *notifications = notification.userInfo[@"notifications"];
    if ([notifications count]) {
        NSArray *sectionChanges = nil;
        NSArray *rowChanges = nil;
        
        [[self.databaseConnection ext:TRTAllRecordsViewName] getSectionChanges:&sectionChanges
                                                                    rowChanges:&rowChanges
                                                              forNotifications:notifications
                                                                  withMappings:self.tableViewMappings];
        
        if ([sectionChanges count] || [rowChanges count]) {
            [self.tableView beginUpdates];
            
            for (YapDatabaseViewSectionChange *sectionChange in sectionChanges)
            {
                switch (sectionChange.type)
                {
                    case YapDatabaseViewChangeDelete :
                    {
                        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;
                    }
                    case YapDatabaseViewChangeInsert :
                    {
                        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;
                    }
                    case YapDatabaseViewChangeUpdate:
                    case YapDatabaseViewChangeMove:
                        break;
                }
            }
            
            for (YapDatabaseViewRowChange *rowChange in rowChanges)
            {
                switch (rowChange.type)
                {
                    case YapDatabaseViewChangeDelete :
                    {
                        [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;
                    }
                    case YapDatabaseViewChangeInsert :
                    {
                        [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;
                    }
                    case YapDatabaseViewChangeMove :
                    {
                        [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                        [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;
                    }
                    case YapDatabaseViewChangeUpdate :
                    {
                        [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ]
                                              withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    }
                }
            }
            
            [self.tableView endUpdates];
        }
        
        
    }
}


@end
