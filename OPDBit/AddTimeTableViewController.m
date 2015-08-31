//
//  AddTimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

// Controllers
#import "AddTimeTableViewController.h"
#import "ServerSemesterViewController.h"

// View
#import "MZSnackBar.h"

// Utility
#import "DataManager.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

// Models
#import "TimeTableObject.h"

// Library
#import <Masonry/Masonry.h>

@interface AddTimeTableViewController () <ServerSemesterViewControllerDelegate>

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) ServerSemesterObject *serverSemester;

// UI Part
@property (nonatomic, strong) UILabel *timeTableNameLabel;
@property (nonatomic, strong) UILabel *serverTimeTableLabel;
@property (nonatomic, strong) UILabel *primaryTimeTableLabel;

@property (nonatomic, strong) UIView *textFieldBottomBorder;

@property (nonatomic, strong) UITextField *timeTableNameField;
@property (nonatomic, strong) UIButton *serverSemesterButton;
@property (nonatomic, strong) UISwitch *primaryTimeTableSwitch;

@property (strong, nonatomic) MZSnackBar *snackBar;

@end

@implementation AddTimeTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataManager = [DataManager sharedInstance];
        _timeTable = [[TimeTableObject alloc] init];
        [_timeTable setDefaultProperties];
        
        _timeTableNameLabel = [[UILabel alloc] init];
        _serverTimeTableLabel = [[UILabel alloc] init];
        _primaryTimeTableLabel = [[UILabel alloc] init];
        
        _textFieldBottomBorder = [[UIView alloc] init];
        
        _timeTableNameField = [[UITextField alloc] initWithFrame:CGRectZero];
        _serverSemesterButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _primaryTimeTableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        
        [_timeTableNameField becomeFirstResponder];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setTitle:@"시간표 추가"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    //Labels
    _timeTableNameLabel.text = @"시간표 이름";
    _timeTableNameLabel.textColor = [UIColor op_primary];
    _timeTableNameLabel.font = [UIFont op_secondary];
    
    _serverTimeTableLabel.text = @"유드림스 종합강의시간표";
    _serverTimeTableLabel.textColor = [UIColor op_textSecondaryDark];
    _serverTimeTableLabel.font = [UIFont op_secondary];
    
    _primaryTimeTableLabel.text = @"기본 시간표 설정";
    _primaryTimeTableLabel.textColor = [UIColor op_textPrimaryDark];
    _primaryTimeTableLabel.font = [UIFont op_primary];
    
    _textFieldBottomBorder.backgroundColor = [UIColor op_primary];
    
    _timeTableNameField.borderStyle = UITextBorderStyleNone;
    _timeTableNameField.font = [UIFont op_title];
    _timeTableNameField.textColor = [UIColor op_textPrimaryDark];
    _timeTableNameField.backgroundColor = [UIColor clearColor];
    _timeTableNameField.placeholder = @"시간표 이름";
    _timeTableNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _timeTableNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_timeTableNameField setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [_serverSemesterButton setTitleColor:[UIColor op_textPrimaryDark] forState:UIControlStateNormal];
    [_serverSemesterButton setTitle:@"여기를 눌러 유드림스 강의목록을 받아주세요!" forState:UIControlStateNormal];
    _serverSemesterButton.titleLabel.font = [UIFont op_primary];
    _serverSemesterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_serverSemesterButton addTarget:self action:@selector(selectServerSemester) forControlEvents:UIControlEventTouchUpInside];
    
    _primaryTimeTableSwitch.on = YES;
    
    [self.view addSubview:_timeTableNameLabel];
    [self.view addSubview:_serverTimeTableLabel];
    [self.view addSubview:_primaryTimeTableLabel];
    
    [self.view addSubview:_textFieldBottomBorder];
    
    [self.view addSubview:_timeTableNameField];
    [self.view addSubview:_serverSemesterButton];
    [self.view addSubview:_primaryTimeTableSwitch];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    CGFloat gapForSuperViewTop = 0.0f;
    CGFloat gapBetweenSections = 40.0f;
    CGFloat gapBetweenLabelAndFactor = 5.0f;
    CGFloat edgePadding = 15.0f;
    
    //Labels
    
    [_timeTableNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(gapForSuperViewTop + edgePadding);
        make.left.equalTo(self.view.mas_left).with.offset(edgePadding);
        make.right.equalTo(self.view.mas_right).with.offset(-edgePadding);
    }];
    [_serverTimeTableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeTableNameField.mas_bottom).with.offset(gapBetweenSections);
        make.left.equalTo(self.view.mas_left).with.offset(edgePadding);
        make.right.equalTo(self.view.mas_right).with.offset(-edgePadding);
    }];
    [_primaryTimeTableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_serverSemesterButton.mas_bottom).with.offset(gapBetweenSections);
        make.left.equalTo(self.view.mas_left).with.offset(edgePadding);
        make.right.equalTo(self.view.mas_right).with.offset(-edgePadding);
    }];
    
    [_timeTableNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeTableNameLabel.mas_bottom).with.offset(gapBetweenLabelAndFactor);
        make.left.equalTo(self.view.mas_left).with.offset(edgePadding);
        make.right.equalTo(self.view.mas_right).with.offset(-edgePadding);
    }];
    [_serverSemesterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_serverTimeTableLabel.mas_bottom).with.offset(gapBetweenLabelAndFactor);
        make.left.equalTo(self.view.mas_left).with.offset(edgePadding);
        make.right.equalTo(self.view.mas_right).with.offset(-edgePadding);
    }];
    [_primaryTimeTableSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_primaryTimeTableLabel);
        make.right.equalTo(self.view.mas_right).with.offset(-edgePadding);
    }];
    
    [_textFieldBottomBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeTableNameField.mas_bottom);
        make.left.equalTo(_timeTableNameField);
        make.right.equalTo(_timeTableNameField);
        make.height.equalTo(@0.5f);
    }];
}

#pragma mark - Setter

- (void)setTimeTable:(TimeTableObject *)timeTable
{
    TimeTableObject *copiedTimeTable = [[TimeTableObject alloc] init];
    copiedTimeTable.timeTableName = timeTable.timeTableName;
    copiedTimeTable.timeStart = timeTable.timeStart;
    copiedTimeTable.timeEnd = timeTable.timeEnd;
    copiedTimeTable.serverSemesterObject = timeTable.serverSemesterObject;
    copiedTimeTable.utid = timeTable.utid;
    copiedTimeTable.active = timeTable.active;
    copiedTimeTable.workAtWeekend = timeTable.workAtWeekend;
    copiedTimeTable.lectures = timeTable.lectures;
    
    _timeTable = copiedTimeTable;
    self.serverSemester = timeTable.serverSemesterObject;
    
    [self setTitle:@"시간표 수정"];
    
    _timeTableNameField.text = timeTable.timeTableName;
    [_primaryTimeTableSwitch setOn:timeTable.active];
}

- (void)setServerSemester:(ServerSemesterObject *)serverSemester
{
    _serverSemester = serverSemester;
    
    if (!serverSemester) {
        return;
    }
    
    _timeTable.serverSemesterObject = serverSemester;
    NSString *buttonTitle = [NSString stringWithFormat:@"동국대학교 %@", serverSemester.semesterName];
    if (_timeTableNameField.text.length == 0)
        _timeTableNameField.text = buttonTitle;
    [_serverSemesterButton setTitle:serverSemester.semesterName forState:UIControlStateNormal];
}

#pragma mark - Bar Button Action

- (void)done
{
    if (_timeTableNameField.text.length == 0) {
        [_timeTableNameField resignFirstResponder];
        
        if (!_snackBar) {
            _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        }
        _snackBar.message = @"시간표 이름을 입력해주세요!";
        [_snackBar animateToAppearInView:self.view];
        
        return;
    }
    
    _timeTable.timeTableName = (NSString *)_timeTableNameField.text;
    _timeTable.active = _primaryTimeTableSwitch.isOn;
    
    [_dataManager saveOrUpdateTimeTable:_timeTable
                             completion:^(BOOL isUpdated)
    {
        if ([_delegate respondsToSelector:@selector(addTimeTableViewController:didDoneWithIsModifying:)]) {
            [_delegate addTimeTableViewController:self didDoneWithIsModifying:isUpdated];
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

#pragma mark - Action

- (void)selectServerSemester
{
    ServerSemesterViewController *serverSemesterViewController = [[ServerSemesterViewController alloc] init];
    serverSemesterViewController.delegate = self;
    [self.navigationController pushViewController:serverSemesterViewController animated:YES];
}

#pragma mark - Server Semester Delegate

- (void)serverSemesterViewController:(ServerSemesterViewController *)serverSemesterViewController didSelectedSemesterObject:(ServerSemesterObject *)semesterObject
{
    self.serverSemester = semesterObject;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}
@end
