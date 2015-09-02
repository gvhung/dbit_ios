//
//  ShowLectureViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 6. 18..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "TimeTableObject.h"
#import "ServerLectureObject.h"

#import "ShowLectureViewController.h"
#import "TimeTableView.h"
#import "DataManager.h"

@interface ShowLectureViewController ()

@property (nonatomic, strong) TimeTableView *timeTableView;

@property (nonatomic, strong) DataManager *dataManager;

@end

@implementation ShowLectureViewController

#pragma mark - initialize

- (id)init
{
    return [self initWithServerLecture:nil];
}

- (instancetype)initWithServerLecture:(ServerLectureObject *)serverLecture
{
    self = [super init];
    
    if (self)
    {
        _dataManager = [DataManager sharedInstance];
        _activedTimeTable = _dataManager.activedTimeTable;
        _serverLecture = serverLecture;
        if (serverLecture) {
            _timeTableView = [[TimeTableView alloc] initWithFrame:CGRectZero
                                                        timetable:_activedTimeTable
                                                    serverLecture:serverLecture];
        } else {
            _timeTableView = [[TimeTableView alloc] initWithFrame:CGRectZero
                                                        timetable:_activedTimeTable];
        }
        [self.view addSubview:_timeTableView];
        
        self.view.backgroundColor = [UIColor whiteColor];
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    [self makeAutoLayoutContraints];
}

- (void)makeAutoLayoutContraints
{
    [_timeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 5, 0, 0));
    }];
}

#pragma mark - Setter

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
