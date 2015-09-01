//
//  TodayViewController.m
//  TimeTableWidget
//
//  Created by Kweon Min Jun on 2015. 4. 4..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "TodayViewController.h"
#import "TimeTableViewForWidget.h"

#import <NotificationCenter/NotificationCenter.h>

#define TimeTableViewWidth [UIScreen mainScreen].bounds.size.width

@interface TodayViewController () <NCWidgetProviding, UIGestureRecognizerDelegate>

@property (nonatomic, strong) TimeTableViewForWidget *timeTableView;
@property (nonatomic, strong) UIButton *emptyButton;

@property (nonatomic, strong) NSDictionary *activedTimeTable;

@property (nonatomic, strong) NSArray *lectures;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic) NSInteger timeStart;
@property (nonatomic) NSInteger timeEnd;

@property (nonatomic) NSInteger blockStart;
@property (nonatomic) NSInteger blockEnd;
@property (nonatomic) CGFloat sectionWidth;
@property (nonatomic) CGFloat timeHeight;
@property (nonatomic) NSInteger timeBlockCount;

@end

@implementation TodayViewController

static CGFloat const TimeTableViewHeight = 400.0f;

static CGFloat const EmptyButtonHeight = 20.0f;
static CGFloat const EmptyButtonPadding = 10.0f;

- (void)initializeWidget
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openDBitApp)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    if (!_activedTimeTable || [_activedTimeTable[@"timeStart"] integerValue] == -1) {
        _emptyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, EmptyButtonPadding, [UIScreen mainScreen].bounds.size.width, EmptyButtonHeight)];
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, EmptyButtonPadding+EmptyButtonHeight);
        [_emptyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _emptyButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:20];
        [_emptyButton addTarget:self action:@selector(openDBitApp) forControlEvents:UIControlEventTouchUpInside];
        
        [_emptyButton setTitle:@"시간표를 등록하세요!" forState:UIControlStateNormal];
        if ([_activedTimeTable[@"timeStart"] integerValue] == -1)
            [_emptyButton setTitle:@"수업을 추가하세요!" forState:UIControlStateNormal];
        
        [self.view addSubview:_emptyButton];
        
    } else {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, TimeTableViewHeight+100.0f);
        if (!_timeTableView) {
            _timeTableView = [[TimeTableViewForWidget alloc] initForWidgetWithFrame:CGRectMake(0, 0, TimeTableViewWidth, TimeTableViewHeight) timetable:_activedTimeTable];
            _timeTableView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:_timeTableView];
        }
        
        [self updateTimeTable];
    }
}

- (void)updateTimeTable
{
    _timeTableView.timetableForWidget = _activedTimeTable;
}

- (void)openDBitApp
{
    NSExtensionContext *context = self.extensionContext;
    NSURL *dbitURL;
    if ([_activedTimeTable[@"timeStart"] integerValue] == -1)
        dbitURL = [NSURL URLWithString:@"dbit://widget/lecture"];
    else if (_activedTimeTable)
        dbitURL = [NSURL URLWithString:@"dbit://widget/show"];
    else
        dbitURL = [NSURL URLWithString:@"dbit://widget"];
    [context openURL:dbitURL completionHandler:nil];
}


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect frame = self.view.superview.frame;
    frame = CGRectMake(0, CGRectGetMinY(frame), CGRectGetWidth(frame) + CGRectGetMinX(frame), CGRectGetHeight(frame));
    self.view.superview.frame = frame;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
    _activedTimeTable = [defaults objectForKey:@"ActivedTimeTable"];

    [self initializeWidget];
    completionHandler(NCUpdateResultNewData);
}

@end
