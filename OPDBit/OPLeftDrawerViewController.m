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
#import "AppDelegate.h"
#import "DataManager.h"

#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface OPLeftDrawerViewController ()

@property (nonatomic, strong) DataManager *dataManager;

@end

@implementation OPLeftDrawerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OPLeftDrawerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[OPLeftDrawerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = indexPath.row ? @"시간표" : @"수업";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (indexPath.row) {
        TimeTableViewController *timeTableViewController = [[TimeTableViewController alloc] init];
        appDelegate.centerNavigationController.viewControllers = @[timeTableViewController];
    } else {
        if (!_dataManager.activedTimeTable) {
            [KVNProgress showErrorWithStatus:@"기본 시간표가 설정되지 않았습니다!"];
            [appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
            return;
        }
        LectureViewController *lectureViewController = [[LectureViewController alloc] init];
        appDelegate.centerNavigationController.viewControllers = @[lectureViewController];
    }
    [appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
}

@end
