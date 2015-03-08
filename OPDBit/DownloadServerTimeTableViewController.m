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

#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface DownloadServerTimeTableViewController ()

@property (nonatomic, retain) NetworkManager *networkManager;
@property (nonatomic, retain) DataManager *dataManager;

@property (nonatomic, retain) NSArray *schools;
@property (nonatomic, retain) NSArray *timeTables;
@property (nonatomic) NSInteger selectedSchoolId;
@property (nonatomic) NSInteger selectedTimeTable;

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
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setTitle:@"서버 시간표 다운로드"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _schoolButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _schoolButton.backgroundColor = [UIColor lightGrayColor];
    [_schoolButton setTitle:@"학교를 선택해주세요." forState:UIControlStateNormal];
    [_schoolButton addTarget:self action:@selector(selectSchool) forControlEvents:UIControlEventTouchUpInside];
    
    _timeTableButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _timeTableButton.backgroundColor = [UIColor lightGrayColor];
    [_timeTableButton setTitle:@"시간표를 선택해주세요." forState:UIControlStateNormal];
    [_timeTableButton addTarget:self action:@selector(selectTimeTable) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(downloadTimeTable)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    [self.view addSubview:_schoolButton];
    [self.view addSubview:_timeTableButton];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_schoolButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50.0f);
        make.width.equalTo(@200.0f);
        make.bottom.lessThanOrEqualTo(self.view.mas_centerY).with.offset(10.0f);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_timeTableButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50.0f);
        make.width.equalTo(@200.0f);
        make.top.greaterThanOrEqualTo(self.view.mas_centerY).with.offset(10.0f);
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
         
         UIAlertView *schoolSelectAlertView = [[UIAlertView alloc] initWithTitle:@"학교선택" message:@"" delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
         schoolSelectAlertView.tag = 1;
         
         [_dataManager saveServerSchoolsWithResponse:response];
         _schools = [_dataManager getSchools];
         
         for (NSDictionary *schoolDictionary in _schools) {
             [schoolSelectAlertView addButtonWithTitle:schoolDictionary[@"schoolName"]];
         }
         
         [schoolSelectAlertView show];
     } failure:^(NSError *error) {
         [KVNProgress showErrorWithStatus:@"내려받는 도중에 오류가 발생했습니다!"];
         NSLog(@"%@", error);
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
         
         UIAlertView *timeTableSelectAlertView = [[UIAlertView alloc] initWithTitle:@"시간표 선택" message:@"" delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
         timeTableSelectAlertView.tag = 2;
         
         
         [_dataManager saveServerTimeTablesWithResponse:response];
         _timeTables = [_dataManager getServerTimeTablesWithSchoolId:_selectedSchoolId];
         
         for (NSDictionary *serverTimeTableDictionary in _timeTables) {
             [timeTableSelectAlertView addButtonWithTitle:[self getSemesterString:serverTimeTableDictionary[@"semester"]]];
         }
         
         [timeTableSelectAlertView show];
         
    } failure:^(NSError *error) {
        [KVNProgress showErrorWithStatus:@"내려받는 도중에 오류가 발생했습니다!"];
        NSLog(@"%@", error);
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
     getServerLecuturesWithTimeTableID:_selectedTimeTable completion:^(id response) {
         [KVNProgress dismiss];
         NSInteger totalCount = [response count];
         [_dataManager saveServerLecturesWithResponse:response update:^(NSInteger progressIndex) {
             [KVNProgress showProgress:progressIndex/totalCount status:[NSString stringWithFormat:@"%ld/%ld", progressIndex, totalCount]];
             if (progressIndex == totalCount) {
                 [KVNProgress showSuccessWithStatus:[NSString stringWithFormat:@"총 %ld개 강의 내려받기 성공!", totalCount]];
                 [_dataManager setDownloadedWithTimeTableId:_selectedTimeTable];
                 [self.navigationController popViewControllerAnimated:YES];
             }
         }];
     } failure:^(NSError *error) {
         [KVNProgress showErrorWithStatus:@"내려받는 도중에 오류가 발생했습니다!"];
         NSLog(@"%@", error);
     }];
}

#pragma mark - Utils

- (NSString *)getSemesterString:(NSString *)semester
{
    NSArray *titleArray = [semester componentsSeparatedByString:@"-0"];
    return [NSString stringWithFormat:@"%@년 %@학기", titleArray[0], titleArray[1]];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) return;
    if (alertView.tag == 1) {
        _selectedSchoolId = [_schools[buttonIndex-1][@"schoolId"] integerValue];
        [_schoolButton setTitle:_schools[buttonIndex-1][@"schoolName"] forState:UIControlStateNormal];
    } else if (alertView.tag == 2) {
        _selectedTimeTable = [_timeTables[buttonIndex-1][@"timeTableId"] integerValue];
        [_timeTableButton setTitle:[self getSemesterString:_timeTables[buttonIndex-1][@"semester"]] forState:UIControlStateNormal];
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
