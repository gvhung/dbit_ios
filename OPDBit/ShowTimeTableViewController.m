//
//  ShowTimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 2..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AppDelegate.h"

#import "ShowTimeTableViewController.h"
#import "TimeTableView.h"
#import "DataManager.h"

#import <Masonry/Masonry.h>

@interface ShowTimeTableViewController ()

@property (nonatomic, strong) TimeTableView *timeTableView;

@property (nonatomic, strong) DataManager *dataManager;

@end

@implementation ShowTimeTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        _dataManager = [DataManager sharedInstance];
        
        self.view.backgroundColor = [UIColor whiteColor];
        _timeTableView = [[TimeTableView alloc] initWithFrame:CGRectZero
                                                     lectures:_activedTimeTable[@"lectures"]
                                                sectionTitles:[_dataManager daySectionTitles]
                                                    timeStart:[_activedTimeTable[@"timeStart"] integerValue]
                                                      timeEnd:[_activedTimeTable[@"timeEnd"] integerValue]];
        [self.view addSubview:_timeTableView];
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setTitle:@"시간표 모아보기"];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(openDrawer)];
    self.navigationItem.leftBarButtonItem = menuButton;
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_timeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 5, 0, 0));
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.activedTimeTable = _dataManager.activedTimeTable;
}

#pragma mark - Setter

- (void)setActivedTimeTable:(NSDictionary *)activedTimeTable
{
    _activedTimeTable = activedTimeTable;
    _timeTableView.lectures = _activedTimeTable[@"lectures"];
    _timeTableView.sectionTitles = [_dataManager daySectionTitles];
    _timeTableView.timeStart = [_activedTimeTable[@"timeStart"] integerValue];
    _timeTableView.timeEnd = [_activedTimeTable[@"timeEnd"] integerValue];
    [_timeTableView setNeedsDisplay];
}

#pragma mark - Bar Button Action

- (void)openDrawer
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

@end
