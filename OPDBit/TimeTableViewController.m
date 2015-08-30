//
//  TimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AppDelegate.h"

// View
#import "MZSnackBar.h"

// Controller
#import "TimeTableViewController.h"
#import "TimeTableCell.h"
#import "AddTimeTableViewController.h"
#import "ServerSemesterViewController.h"
#import "LectureViewController.h"

// Utility
#import "UIFont+OPTheme.h"
#import "UIColor+OPTheme.h"
#import "DataManager.h"

// Model
#import "TimeTableObject.h"

// Library
#import <Masonry/Masonry.h>
#import <Realm/Realm.h>

@interface TimeTableViewController () <AddTimeTableViewControllerDelegate>

@property (nonatomic, strong) RLMArray *timeTables;
@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) UILabel *emptyLabel;
@property (strong, nonatomic) MZSnackBar *snackBar;

@end

@implementation TimeTableViewController

static NSString * const TimeTableCellIdentifier = @"TimeTableCell";
static CGFloat const TimeTableCellHeight = 75.0f;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataManager = [DataManager sharedInstance];
        _timeTables = [[RLMArray alloc] initWithObjectClassName:TimeTableObjectID];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setTitle:@"시간표"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *addTimeTableButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                          target:self
                                                                          action:@selector(addTimeTable)];
    UIBarButtonItem *downloadServerTimeTableButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"download"]
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(downloadServerTimeTable)];
    
    self.navigationItem.rightBarButtonItems = @[downloadServerTimeTableButton, addTimeTableButton];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(openDrawer)];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView registerClass:[TimeTableCell class] forCellReuseIdentifier:TimeTableCellIdentifier];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.minimumPressDuration = 0.5f; //seconds
    longPressRecognizer.delegate = self;
    [_tableView addGestureRecognizer:longPressRecognizer];
    
    _emptyLabel = [[UILabel alloc] init];
    _emptyLabel.textColor = [UIColor op_textPrimaryDark];
    _emptyLabel.font = [UIFont op_title];
    _emptyLabel.text = @"시간표가 없어요! :D";

    [self.view addSubview:_tableView];
    [self.view addSubview:_emptyLabel];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [_emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_tableView);
    }];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _timeTables.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TimeTableCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[TimeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeTableCellIdentifier];
    }
    
    cell.timeTable = _timeTables[indexPath.row];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TimeTableObject *timeTable = _timeTables[indexPath.row];
    
    [_dataManager setActiveWithUtid:timeTable.utid];
    self.timeTables = [_dataManager timeTables];
    
    LectureViewController *lectureViewController = [[LectureViewController alloc] init];
    [self.navigationController setViewControllers:@[lectureViewController] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TimeTableCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TimeTableCellHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TimeTableObject *timeTableToDelete = _timeTables[indexPath.row];
        [_dataManager deleteTimeTableWithUtid:timeTableToDelete.utid];
        if (!_snackBar) {
            _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        }
        _snackBar.message = @"시간표 삭제 성공!";
        [_snackBar animateToAppearInView:self.view];
        self.timeTables = [_dataManager timeTables];
    }
}

#pragma mark - Gesture Recognizer

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:_tableView];
    
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:p];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self editTimeTableWithIndexPath:indexPath];
    }
}

#pragma mark - Setter

- (void)setTimeTables:(RLMArray *)timeTables
{
    _timeTables = timeTables;
    [self hideTableView:[self timeTablesAreEmpty]];
}

#pragma mark - Instance Method

- (BOOL)timeTablesAreEmpty
{
    return !_timeTables.count;
}

- (void)hideTableView:(BOOL)hide
{
    _tableView.hidden = hide;
    _emptyLabel.hidden = !hide;
    
    if (!hide) [_tableView reloadData];
}

#pragma mark - Bar Button Action

- (void)downloadServerTimeTable
{
    ServerSemesterViewController *serverSemesterViewController = [[ServerSemesterViewController alloc] init];
    [self.navigationController pushViewController:serverSemesterViewController animated:YES];
}

- (void)addTimeTable
{
    AddTimeTableViewController *addTimeTableViewController = [[AddTimeTableViewController alloc] init];
    addTimeTableViewController.delegate = self;
    [self.navigationController pushViewController:addTimeTableViewController animated:YES];
}

- (void)openDrawer
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)editTimeTableWithIndexPath:(NSIndexPath *)indexPath
{
    AddTimeTableViewController *editTimeTableViewController = [[AddTimeTableViewController alloc] init];
    editTimeTableViewController.timeTable = _timeTables[indexPath.row];
    editTimeTableViewController.delegate = self;
    [self.navigationController pushViewController:editTimeTableViewController animated:YES];
}

#pragma mark - Add Time Table Delegate

- (void)addTimeTableViewController:(AddTimeTableViewController *)addTimeTableViewController didDoneWithIsModifying:(BOOL)isModifying
{
    if (isModifying) {
        if (!_snackBar) {
            _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        }
        _snackBar.message = @"시간표 수정 성공!";
        [_snackBar animateToAppearInView:self.view];
    } else {
        if (!_snackBar) {
            _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        }
        _snackBar.message = @"시간표 추가 성공!";
        [_snackBar animateToAppearInView:self.view];
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.timeTables = [_dataManager timeTables];
}

@end
