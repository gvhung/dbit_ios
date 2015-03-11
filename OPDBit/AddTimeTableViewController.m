//
//  AddTimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AddTimeTableViewController.h"

#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface AddTimeTableViewController ()

@property (nonatomic) NSInteger selectedServerTimeTableId;

// UI Part
@property (nonatomic, retain) UILabel *timeTableNameLabel;
@property (nonatomic, retain) UILabel *serverTimeTableLabel;
@property (nonatomic, retain) UILabel *primaryTimeTableLabel;

@property (nonatomic, retain) UITextField *timeTableNameField;
@property (nonatomic, retain) UIButton *serverTimeTableButton;
@property (nonatomic, retain) UISwitch *primaryTimeTableSwitch;

@end

@implementation AddTimeTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
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

- (void)done
{
    if (!_timeTableNameField.text) {
        [KVNProgress showErrorWithStatus:@"시간표 이름을 입력해주세요!"];
        return;
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
@end
