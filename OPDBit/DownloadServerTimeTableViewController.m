//
//  DownloadServerTimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "DownloadServerTimeTableViewController.h"
#import "NetworkManager.h"
#import "DataManager.h"

#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface DownloadServerTimeTableViewController ()

@property (nonatomic, strong) NetworkManager *networkManager;
@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) UILabel *schoolLabel;
@property (nonatomic, strong) UILabel *timeTableLabel;

@property (nonatomic, strong) UIButton *schoolButton;
@property (nonatomic, strong) UIButton *timeTableButton;

@end

@implementation DownloadServerTimeTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _networkManager = [NetworkManager sharedInstance];
        _dataManager    = [DataManager sharedInstance];
        _schools = [[NSArray alloc] init];
        _timeTables = [[NSArray alloc] init];
        _selectedSchoolId = 0;
        _selectedTimeTable = 0;
        
        _schoolButton = [[UIButton alloc] init];
        _timeTableButton = [[UIButton alloc] init];
        
        _schoolLabel = [[UILabel alloc] init];
        _timeTableLabel = [[UILabel alloc] init];
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setTitle:@"서버 시간표 다운로드"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [_schoolButton setTitleColor:[UIColor op_textPrimaryDark] forState:UIControlStateNormal];
    _schoolButton.titleLabel.font = [UIFont op_title];
    [_schoolButton setTitle:@"학교를 선택해주세요." forState:UIControlStateNormal];
    [_schoolButton addTarget:self action:@selector(selectSchool) forControlEvents:UIControlEventTouchUpInside];
    
    [_timeTableButton setTitleColor:[UIColor op_textPrimaryDark] forState:UIControlStateNormal];
    _timeTableButton.titleLabel.font = [UIFont op_title];
    [_timeTableButton setTitle:@"시간표를 선택해주세요." forState:UIControlStateNormal];
    [_timeTableButton addTarget:self action:@selector(selectTimeTable) forControlEvents:UIControlEventTouchUpInside];
    
    _schoolLabel.text = @"학교 선택";
    _schoolLabel.textAlignment = NSTextAlignmentCenter;
    _schoolLabel.textColor = [UIColor op_textSecondaryDark];
    _schoolLabel.font = [UIFont op_primary];
    
    _timeTableLabel.text = @"시간표 선택";
    _timeTableLabel.textAlignment = NSTextAlignmentCenter;
    _timeTableLabel.textColor = [UIColor op_textSecondaryDark];
    _timeTableLabel.font = [UIFont op_primary];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(downloadTimeTable)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [self.view addSubview:_schoolButton];
    [self.view addSubview:_timeTableButton];
    
    [self.view addSubview:_schoolLabel];
    [self.view addSubview:_timeTableLabel];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    CGFloat padding = 15.0f;
    CGFloat margin = 100.0f;
    CGFloat gap = 10.0f;
    
    [_schoolButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(padding);
        make.right.equalTo(self.view.mas_right).with.offset(-padding);
        make.bottom.equalTo(self.view.mas_centerY).with.offset(-margin);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_timeTableButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(padding);
        make.right.equalTo(self.view.mas_right).with.offset(-padding);
        make.top.equalTo(self.view.mas_centerY).with.offset(padding);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [_schoolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_schoolButton.mas_top).with.offset(-gap);
        make.left.equalTo(self.view.mas_left).with.offset(padding);
        make.right.equalTo(self.view.mas_right).with.offset(-padding);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_timeTableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_timeTableButton.mas_top).with.offset(-gap);
        make.left.equalTo(self.view.mas_left).with.offset(padding);
        make.right.equalTo(self.view.mas_right).with.offset(-padding);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - Button Action

- (void)selectSchool
{
    [KVNProgress showWithStatus:@"학교목록 내려받는 중.."];
    [_networkManager
     getServerSchoolsWithCompletion:^(id response) {
         [KVNProgress dismiss];
         
         [_dataManager saveServerSchoolsWithResponse:response];
         _schools = [_dataManager schools];
         
         UIActionSheet *schoolSelectActionSheet = [[UIActionSheet alloc] initWithTitle:@"학교를 선택해주세요!"
                                                                              delegate:self
                                                                     cancelButtonTitle:@"취소"
                                                                destructiveButtonTitle:nil
                                                                     otherButtonTitles:nil];
         schoolSelectActionSheet.tag = 1;
         for (NSDictionary *schoolDictionary in _schools) {
             [schoolSelectActionSheet addButtonWithTitle:schoolDictionary[@"schoolName"]];
         }
         [schoolSelectActionSheet showInView:self.view];
     } failure:^(NSError *error) {
         
         NSString *errorMessage;
         
         if (error.code == -1003 || error.code == -1009)
             errorMessage = @"인터넷 연결을 확인해주세요!";
         else
             errorMessage = @"내려받는 도중에\n오류가 발생했습니다!";
         
         [KVNProgress showErrorWithStatus:errorMessage];
         NSLog(@"Failed To Get Server Schools\n%@", error);
    }];
}

- (void)selectTimeTable
{
    if (_selectedSchoolId == 0) {
        [KVNProgress showErrorWithStatus:@"학교를 먼저 선택해주세요."];
        return;
    }
    [KVNProgress showWithStatus:@"시간표목록 내려받는 중.."];
    [_networkManager
     getServerTimeTableWithWithSchoolID:_selectedSchoolId
     completion:^(id response) {
         [KVNProgress dismiss];
         
         [_dataManager saveServerTimeTablesWithResponse:response];
         _timeTables = [_dataManager serverTimeTablesWithSchoolId:_selectedSchoolId];
         
         UIActionSheet *timeTableSelectActionSheet = [[UIActionSheet alloc] initWithTitle:@"시간표를 선택해주세요!"
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"취소"
                                                                   destructiveButtonTitle:nil
                                                                        otherButtonTitles:nil];
         timeTableSelectActionSheet.tag = 2;
         for (NSDictionary *serverTimeTableDictionary in _timeTables) {
             [timeTableSelectActionSheet addButtonWithTitle:[_dataManager semesterString:serverTimeTableDictionary[@"semester"]]];
         }
         [timeTableSelectActionSheet showInView:self.view];
    } failure:^(NSError *error) {
        
        NSString *errorMessage;
        
        if (error.code == -1003 || error.code == -1009)
            errorMessage = @"인터넷 연결을 확인해주세요!";
        else
            errorMessage = @"내려받는 도중에\n오류가 발생했습니다!";
        
        [KVNProgress showErrorWithStatus:errorMessage];
        
        NSLog(@"Failed to Get Server Time Table With School ID (%ld)\n%@", _selectedSchoolId, error);
    }];
}

- (void)downloadTimeTable
{
    if (_selectedTimeTable == 0 || _selectedSchoolId == 0) {
        [KVNProgress showErrorWithStatus:@"학교와 시간표를 선택해주세요!"];
        return;
    }
    [KVNProgress showWithStatus:@"시간표 내려받는 중.."];
    [_networkManager
     getServerLecturesWithTimeTableID:_selectedTimeTable completion:^(id response) {
         [KVNProgress dismiss];
         NSInteger totalCount = [response count];
         [_dataManager saveServerLecturesWithResponse:response serverTimeTableId:_selectedTimeTable update:^(NSInteger progressIndex) {
             [KVNProgress showProgress:progressIndex/totalCount status:[NSString stringWithFormat:@"%ld/%ld", progressIndex, totalCount]];
             if (progressIndex == totalCount) {
                 [KVNProgress showSuccessWithStatus:[NSString stringWithFormat:@"총 %ld개 강의 내려받기 성공!", totalCount]];
                 [self.navigationController popViewControllerAnimated:YES];
             }
         }];
     } failure:^(NSError *error) {
         NSString *errorMessage;
         
         if (error.code == -1009 || error.code == -1003)
             errorMessage = @"인터넷 연결을 확인해주세요!";
         else
             errorMessage = @"내려받는 도중에\n오류가 발생했습니다!";
         
         [KVNProgress showErrorWithStatus:errorMessage];
         NSLog(@"Failed to Get Server Lectures With Time Table ID (%ld)\n%@", _selectedSchoolId, error);
     }];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) return;
    if (actionSheet.tag == 1) {
        _selectedSchoolId = [_schools[buttonIndex-1][@"schoolId"] integerValue];
        _selectedTimeTable = 0;
        [_schoolButton setTitle:_schools[buttonIndex-1][@"schoolName"] forState:UIControlStateNormal];
        [_timeTableButton setTitle:@"시간표를 선택해주세요." forState:UIControlStateNormal];
    } else if (actionSheet.tag == 2) {
        _selectedTimeTable = [_timeTables[buttonIndex-1][@"timeTableId"] integerValue];
        [_timeTableButton setTitle:[_dataManager semesterString:_timeTables[buttonIndex-1][@"semester"]] forState:UIControlStateNormal];
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [KVNProgress setConfiguration:[KVNProgressConfiguration defaultConfiguration]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

@end
