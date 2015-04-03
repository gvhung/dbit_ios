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

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        NSLog(@"init");
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 300.0f);
        [self updateTimeTable];
    }
    return self;
}

- (void)userDefaultsDidChange:(NSNotification *)notification
{
    [self updateTimeTable];
}

- (void)updateTimeTable
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
    NSDictionary *activedTimeTable = [defaults objectForKey:@"ActivedTimeTable"];
    NSLog(@"%@", activedTimeTable);
    
    _timeTableView.lectures = activedTimeTable[@"lectures"];
    _timeTableView.sectionTitles = ([activedTimeTable[@"sat"] boolValue] && [activedTimeTable[@"sun"] boolValue]) ? @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"] : @[@"월", @"화", @"수", @"목", @"금"];
    _timeTableView.timeStart = [activedTimeTable[@"timeStart"] integerValue];
    _timeTableView.timeEnd = [activedTimeTable[@"timeEnd"] integerValue];
    
//    _timeTableView.lectures = [[NSArray alloc] init];
//    _timeTableView.sectionTitles = @[@"월", @"화", @"수", @"목", @"금"];
//    _timeTableView.timeStart = 800;
//    _timeTableView.timeEnd = 1500;
    
    NSLog(@"%ld",[activedTimeTable[@"timeEnd"] integerValue]);
    NSLog(@"%ld", _timeTableView.timeEnd);
    [_timeTableView setNeedsDisplay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

//    _timeTableView.frame = self.view.frame;
//    [_timeTableView setNeedsDisplay];
//    NSLog(@"widget Perform update : %@", NSStringFromCGRect(self.view.frame));
    
    completionHandler(NCUpdateResultNewData);
}

@end
