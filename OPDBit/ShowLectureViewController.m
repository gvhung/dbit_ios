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

#import "MZSnackBar.h"

@interface ShowLectureViewController ()

@property (nonatomic, strong) TimeTableView *timeTableView;

@property (nonatomic, strong) DataManager *dataManager;
@property (strong, nonatomic) MZSnackBar *snackBar;

@end

@implementation ShowLectureViewController

#pragma mark - initialize

- (id)init
{
    return [self initWithServerLecture:nil currentLecture:nil];
}

- (instancetype)initWithServerLecture:(ServerLectureObject *)serverLecture currentLecture:(LectureObject *)currentLecture
{
    self = [super init];
    
    if (self)
    {
        _dataManager = [DataManager sharedInstance];
        _activedTimeTable = _dataManager.activedTimeTable;
        
        // 수정 시 TimeTable에 보이지 않도록 변경
        TimeTableObject *copiedTimeTable = [[TimeTableObject alloc] init];
        copiedTimeTable.timeStart = _activedTimeTable.timeStart;
        copiedTimeTable.timeEnd = _activedTimeTable.timeEnd;
        copiedTimeTable.workAtWeekend = _activedTimeTable.workAtWeekend;

        for (LectureObject *lecture in _activedTimeTable.lectures) {
            if (lecture.ulid != currentLecture.ulid) {
                [copiedTimeTable.lectures addObject:lecture];
            }
        }
        _activedTimeTable = copiedTimeTable;
        
        _serverLecture = serverLecture;
        _currentLecture = currentLecture;
        if (serverLecture) {
            _timeTableView = [[TimeTableView alloc] initWithFrame:CGRectZero
                                                        timetable:_activedTimeTable
                                                    serverLecture:serverLecture
                                                          lecture:currentLecture];
        } else {
            _timeTableView = [[TimeTableView alloc] initWithFrame:CGRectZero
                                                        timetable:_activedTimeTable];
        }
        _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        
        [self.view addSubview:_timeTableView];
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = @"강의 세부 내용";
        
        UIBarButtonItem *selectServerLectureButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done"]
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(selectServerLectureAction)];
        self.navigationItem.rightBarButtonItem = selectServerLectureButton;
        
        [self makeAutoLayoutContraints];
    }
    
    return self;
}

- (void)makeAutoLayoutContraints
{
    [_timeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 5, 0, 0));
    }];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Bar Button Action

- (void)selectServerLectureAction
{
    LectureObject *copiedLecture = [[LectureObject alloc] init];
    copiedLecture.ulid = _currentLecture.ulid;
    copiedLecture.theme = _currentLecture.theme;
    copiedLecture.lectureName = _currentLecture.lectureName;
    copiedLecture.lectureDetails = nil;
    
    [copiedLecture lectureFromServerLecture:_serverLecture];
    NSString *message = [_dataManager lectureAreDuplicatedOtherLecture:copiedLecture
                                                        lectureDetails:copiedLecture.lectureDetails
                                                           inTimeTable:_activedTimeTable];
    if (message) {
        _snackBar.message = [NSString stringWithFormat:@"%@ 강의와 겹칩니다!", message];
        [_snackBar animateToAppearInView:self.view];
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(showLectureViewController:didDoneWithLectureObject:)]) {
        [_delegate showLectureViewController:self didDoneWithLectureObject:copiedLecture];
    }
    
    [self.navigationController popToViewController:(UIViewController *)_delegate animated:YES];
}

@end
