//
//  TodayViewController.m
//  OPDBit Widget
//
//  Created by Kweon Min Jun on 2015. 4. 3..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>



@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    DataManager *dataManager = [DataManager sharedInstance];
//    _timeTableView.lectures = dataManager.activedTimeTable[@"lectures"];
//    _timeTableView.sectionTitles = [dataManager daySectionTitles];
//    _timeTableView.timeStart = [dataManager.activedTimeTable[@"timeStart"] integerValue];
//    _timeTableView.timeEnd = [dataManager.activedTimeTable[@"timeEnd"] integerValue];
    
    
    _timeTableView.lectures = [[NSArray alloc] init];
    _timeTableView.sectionTitles = @[@"월", @"화", @"수", @"목", @"금"];
    _timeTableView.timeStart = 800;
    _timeTableView.timeEnd = 2300;
    
    [_timeTableView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    NSLog(@"d");
    
    completionHandler(NCUpdateResultNewData);
}

@end
