//
//  AddTimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

// Controllers
#import "AddTimeTableViewController.h"
#import "ServerTimeTableViewController.h"

// Utility
#import "DataManager.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

// Models
#import "TimeTableObject.h"

// Library
#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface AddTimeTableViewController ()

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) ServerSemesterObject *serverSemester;
@property (nonatomic, strong) TimeTableObject *timeTable;

// UI Part
@property (nonatomic, strong) UILabel *timeTableNameLabel;
@property (nonatomic, strong) UILabel *serverTimeTableLabel;
@property (nonatomic, strong) UILabel *primaryTimeTableLabel;

@property (nonatomic, strong) UIView *textFieldBottomBorder;

@property (nonatomic, strong) UITextField *timeTableNameField;
@property (nonatomic, strong) UIButton *serverTimeTableButton;
@property (nonatomic, strong) UISwitch *primaryTimeTableSwitch;

@end

@implementation AddTimeTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataManager = [DataManager sharedInstance];
        _timeTableId = -1;
        _selectedServerTimeTableId = -1;
        
        _timeTableNameLabel = [[UILabel alloc] init];
        _serverTimeTableLabel = [[UILabel alloc] init];
        _primaryTimeTableLabel = [[UILabel alloc] init];
        
        _textFieldBottomBorder = [[UIView alloc] init];
        
        _timeTableNameField = [[UITextField alloc] initWithFrame:CGRectZero];
        _serverTimeTableButton = [[UIButton alloc] initWithFrame:CGRectZero];
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
    
    _serverTimeTableLabel.text = @"학교 시간표 연동";
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
    
    [_serverTimeTableButton setTitleColor:[UIColor op_textPrimaryDark] forState:UIControlStateNormal];
    [_serverTimeTableButton setTitle:@"여기를 눌러 유드림스로부터 강의목록을 받아주세요!" forState:UIControlStateNormal];
    _serverTimeTableButton.titleLabel.font = [UIFont op_primary];
    _serverTimeTableButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_serverTimeTableButton addTarget:self action:@selector(selectServerTimeTable) forControlEvents:UIControlEventTouchUpInside];
    
    _primaryTimeTableSwitch.on = YES;
    
    [self.view addSubview:_timeTableNameLabel];
    [self.view addSubview:_serverTimeTableLabel];
    [self.view addSubview:_primaryTimeTableLabel];
    
    [self.view addSubview:_textFieldBottomBorder];
    
    [self.view addSubview:_timeTableNameField];
    [self.view addSubview:_serverTimeTableButton];
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
        make.top.equalTo(_serverTimeTableButton.mas_bottom).with.offset(gapBetweenSections);
        make.left.equalTo(self.view.mas_left).with.offset(edgePadding);
        make.right.equalTo(self.view.mas_right).with.offset(-edgePadding);
    }];
    
    [_timeTableNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeTableNameLabel.mas_bottom).with.offset(gapBetweenLabelAndFactor);
        make.left.equalTo(self.view.mas_left).with.offset(edgePadding);
        make.right.equalTo(self.view.mas_right).with.offset(-edgePadding);
    }];
    [_serverTimeTableButton mas_makeConstraints:^(MASConstraintMaker *make) {
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

- (void)setTimeTableId:(NSInteger)timeTableId
{
    _timeTableId = timeTableId;
    [self setTitle:@"시간표 수정"];
    self.timeTable = [_dataManager timeTableWithUtid:timeTableId];
}

- (void)setTimeTable:(TimeTableObject *)timeTable
{
    _timeTable = timeTable;
    self.selectedSemesterID = timeTable.semesterID;
    _timeTableNameField.text = timeTable.timeTableName;
    [_primaryTimeTableSwitch setOn:timeTable.active];
}

#pragma mark - Bar Button Action

- (void)done
{
    if (_timeTableNameField.text.length == 0) {
        [_timeTableNameField resignFirstResponder];
        [KVNProgress showErrorWithStatus:@"시간표 이름을 입력해주세요!"];
        return;
    }
    
    if (_timeTableId != -1) {
        [_dataManager updateTimeTableWithUtid:_timeTableId
                                         name:_timeTableNameField.text
                                   semesterID:_selectedSemesterID
                                       active:_primaryTimeTableSwitch.isOn
                                   completion:^{
                                       [KVNProgress showSuccessWithStatus:@"시간표 수정 성공!"];
                                       }
                                      failure:^(NSString *reason) {
                                          [KVNProgress showErrorWithStatus:reason];
                                      }];
    } else {
        [_dataManager saveTimeTableWithName:_timeTableNameField.text
                                 semesterID:_selectedSemesterID
                                     active:_primaryTimeTableSwitch.isOn];
        [KVNProgress showSuccessWithStatus:@"시간표 추가 성공!"];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Action

- (void)setSelectedSemesterID:(NSInteger)selectedSemesterID
{
    _selectedServerTimeTableId = selectedServerTimeTableId;
    _serverTimeTableDictionary = [_dataManager serverTimeTableWithId:_selectedServerTimeTableId];
    if (!_serverTimeTableDictionary)
        return;
    NSString *schoolName = [_dataManager schoolNameWithServerTimeTableId:_selectedServerTimeTableId];
    NSString *semesterName = [_dataManager semesterString:_serverTimeTableDictionary[@"semester"]];
    NSString *buttonTitle = [NSString stringWithFormat:@"%@ %@", schoolName, semesterName];
    if (_timeTableNameField.text.length == 0) _timeTableNameField.text = buttonTitle;
    [_serverTimeTableButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)setSelectedServerTimeTableId:(NSInteger)selectedServerTimeTableId
{
}

- (void)selectServerTimeTable
{
    ServerTimeTableViewController *timeTableViewController = [[ServerTimeTableViewController alloc] init];
    timeTableViewController.delegate = self;
    [self.navigationController pushViewController:timeTableViewController animated:YES];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}
@end
