//
//  OPLeftDrawerViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "OPLeftDrawerViewController.h"
#import "OPLeftDrawerTableViewCell.h"
#import "TimeTableViewController.h"
#import "LectureViewController.h"
#import "ShowTimeTableViewController.h"
#import "AppDelegate.h"
#import "DataManager.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface OPLeftDrawerViewController ()

@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) NSArray *cellName;

@end

@implementation OPLeftDrawerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellName = @[@"시간표 모아보기", @"수업", @"시간표"];
        
        _dataManager = [DataManager sharedInstance];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView registerClass:[OPLeftDrawerTableViewCell class] forCellReuseIdentifier:@"cell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_tableView];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(20, 0, 0, 0));
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OPLeftDrawerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[OPLeftDrawerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.textColor = [UIColor op_textPrimaryDark];
    cell.textLabel.font = [UIFont op_title];
    cell.textLabel.text = _cellName[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (indexPath.row == 0) {
        if ([_dataManager lecturesIsEmptyInActivedTimeTable]) {
            [KVNProgress showErrorWithStatus:@"아직 수업이 없습니다!"];
            [appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
            return;
        }
        if (!_dataManager.activedTimeTable) {
            [KVNProgress showErrorWithStatus:@"기본 시간표가 설정되지 않았습니다!"];
            [appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
            return;
        }
        ShowTimeTableViewController *showTimeTableViewController = [[ShowTimeTableViewController alloc] init];
        appDelegate.centerNavigationController.viewControllers = @[showTimeTableViewController];
    }
    if (indexPath.row == 1) {
        if (!_dataManager.activedTimeTable) {
            [KVNProgress showErrorWithStatus:@"기본 시간표가 설정되지 않았습니다!"];
            [appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
            return;
        }
        LectureViewController *lectureViewController = [[LectureViewController alloc] init];
        appDelegate.centerNavigationController.viewControllers = @[lectureViewController];
    } else if (indexPath.row == 2) {
        TimeTableViewController *timeTableViewController = [[TimeTableViewController alloc] init];
        appDelegate.centerNavigationController.viewControllers = @[timeTableViewController];
    }
    [appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
}

@end
