//
//  AddTimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AddTimeTableViewController.h"

#import <Masonry/Masonry.h>

@interface AddTimeTableViewController ()

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
        _timeTableNameLabel = [[UILabel alloc] init];
        _serverTimeTableLabel = [[UILabel alloc] init];
        _primaryTimeTableLabel = [[UILabel alloc] init];
        
        _timeTableNameField = [[UITextField alloc] init];
        _serverTimeTableButton = [[UIButton alloc] init];
        _primaryTimeTableSwitch = [[UISwitch alloc] init];
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
    
    _timeTableNameField.borderStyle = UITextBorderStyleLine;
    _timeTableNameField.placeholder = @"시간표 이름";
    _timeTableNameField.clearsOnBeginEditing = YES;
    
    
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
    //Labels
    
    [_timeTableNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(20.0f);
    }];
    [_serverTimeTableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(20.0f);
    }];
    [_primaryTimeTableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
    }];
    
    // Factors
    
    [_timeTableNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        
    }];
    [_serverTimeTableButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
    }];
    [_primaryTimeTableSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        
    }];
}

- (void)done
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
@end
