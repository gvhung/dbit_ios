//
//  AddTimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AddTimeTableViewController.h"
#import "ServerTimeTableViewController.h"
#import "DataManager.h"

#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface AddTimeTableViewController ()

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSDictionary *serverTimeTableDictionary;
@property (nonatomic, strong) NSDictionary *timeTableDictionary;

// UI Part
@property (nonatomic, strong) UILabel *timeTableNameLabel;
@property (nonatomic, strong) UILabel *serverTimeTableLabel;
@property (nonatomic, strong) UILabel *primaryTimeTableLabel;

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
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    //Labels
    _timeTableNameLabel.text = @"시간표 이름";
    _serverTimeTableLabel.text = @"학교 시간표 연동";
    _primaryTimeTableLabel.text = @"기본 시간표 설정";
    
    //Factors
    _timeTableNameField.borderStyle = UITextBorderStyleRoundedRect;
    _timeTableNameField.placeholder = @"시간표 이름";
    _timeTableNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    _serverTimeTableButton.backgroundColor = [UIColor lightGrayColor];
    [_serverTimeTableButton setTitle:@"서버 연동 안함" forState:UIControlStateNormal];
    [_serverTimeTableButton addTarget:self action:@selector(selectServerTimeTable) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_timeTableNameLabel];
    [self.view addSubview:_serverTimeTableLabel];
    [self.view addSubview:_primaryTimeTableLabel];
    
    [self.view addSubview:_timeTableNameField];
    [self.view addSubview:_serverTimeTableButton];
    [self.view addSubview:_primaryTimeTableSwitch];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    CGFloat gapForSuperViewTop = 64.0f;
    CGFloat gapBetweenSections = 40.0f;
    CGFloat gapBetweenLabelAndFactor = 2.0f;
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
    
    
    //Factors
    
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
        make.top.equalTo(_serverTimeTableButton.mas_bottom).with.offset(gapBetweenSections);
        make.right.equalTo(self.view.mas_right).with.offset(-edgePadding);
    }];
}

#pragma mark - Setter

- (void)setTimeTableId:(NSInteger)timeTableId
{
    _timeTableId = timeTableId;
    [self setTitle:@"시간표 수정"];
    UIBarButtonItem *deleteTimeTableButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTimeTable)];
    NSMutableArray *barButtonItems = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    [barButtonItems addObject:deleteTimeTableButton];
    self.navigationItem.rightBarButtonItems = barButtonItems;
    self.timeTableDictionary = [_dataManager timeTableWithId:timeTableId];
}

- (void)deleteTimeTable
{
    
}

- (void)setTimeTableDictionary:(NSDictionary *)timeTableDictionary
{
    _timeTableDictionary = timeTableDictionary;
    self.selectedServerTimeTableId = [timeTableDictionary[@"serverId"] integerValue];
    _timeTableNameField.text = timeTableDictionary[@"timeTableName"];
    [_primaryTimeTableSwitch setOn:timeTableDictionary[@"active"]];
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
                                   serverId:_selectedServerTimeTableId
                                     active:_primaryTimeTableSwitch.isOn
                                      failure:^(NSString *reason){
                                          [KVNProgress showErrorWithStatus:reason];
                                          return;
                                       }];
        [KVNProgress showSuccessWithStatus:@"시간표 수정 성공!"];
    } else {
        [_dataManager saveTimeTableWithName:_timeTableNameField.text
                                   serverId:_selectedServerTimeTableId
                                     active:_primaryTimeTableSwitch.isOn];
        [KVNProgress showSuccessWithStatus:@"시간표 추가 성공!"];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Action

- (void)setSelectedServerTimeTableId:(NSInteger)selectedServerTimeTableId
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
