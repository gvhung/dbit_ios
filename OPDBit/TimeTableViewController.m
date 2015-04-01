//
//  TimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "TimeTableViewController.h"
#import "TimeTableCell.h"
#import "AddTimeTableViewController.h"
#import "ServerTimeTableViewController.h"
#import "DataManager.h"
#import "UIFont+OPTheme.h"

#import "UIColor+OPTheme.h"

#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface TimeTableViewController ()

@property (nonatomic, strong) NSArray *timeTables;
@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIActionSheet *actionSheet;

@end

@implementation TimeTableViewController

static NSString * const TimeTableCellIdentifier = @"TimeTableCell";
static CGFloat const TimeTableCellHeight = 75.0f;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataManager = [DataManager sharedInstance];
        _timeTables = [[NSArray alloc] init];
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
    addTimeTableButton.tintColor = [UIColor op_textPrimary];
    UIBarButtonItem *downloadServerTimeTableButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                                   target:self
                                                                                                   action:@selector(downloadServerTimeTable)];
    
    self.navigationItem.rightBarButtonItems = @[downloadServerTimeTableButton, addTimeTableButton];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView registerClass:[TimeTableCell class] forCellReuseIdentifier:TimeTableCellIdentifier];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _emptyLabel = [[UILabel alloc] init];
    _emptyLabel.textColor = [UIColor op_textPrimaryDark];
    _emptyLabel.font = [UIFont op_title];
    _emptyLabel.text = @"시간표가 없어요! :D";
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                               delegate:self
                                      cancelButtonTitle:@"취소"
                                 destructiveButtonTitle:@"기본 시간표 설정"
                                      otherButtonTitles:@"수정하기", @"삭제하기", nil];

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
    if (!cell)
        cell = [[TimeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeTableCellIdentifier];
    cell.timeTableDictionary = _timeTables[indexPath.row];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _actionSheet.title = _timeTables[indexPath.row][@"timeTableName"];
    _actionSheet.tag = indexPath.row;
    [_actionSheet showInView:self.view];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TimeTableCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TimeTableCellHeight;
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [_dataManager setActiveWithUtid:actionSheet.tag];
        [KVNProgress showSuccessWithStatus:[NSString stringWithFormat:@"기본 시간표가\n'%@'\n(으)로 설정되었습니다.", _timeTables[actionSheet.tag][@"timeTableName"]]];
        [_tableView reloadData];
    } else if (buttonIndex == 1) {
        AddTimeTableViewController *editTimeTableViewController = [[AddTimeTableViewController alloc] init];
        editTimeTableViewController.timeTableId = [_timeTables[actionSheet.tag][@"utid"] integerValue];
        [self.navigationController pushViewController:editTimeTableViewController animated:YES];
    } else if (buttonIndex == 2) {
        [_dataManager deleteTimeTableWithUtid:[_timeTables[actionSheet.tag][@"utid"] integerValue]];
        [KVNProgress showSuccessWithStatus:@"시간표 삭제 성공!"];
        [_tableView reloadData];
    }
}

#pragma mark - Setter

- (void)setTimeTables:(NSArray *)timeTables
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
    ServerTimeTableViewController *serverTimeTableViewController = [[ServerTimeTableViewController alloc] init];
    [self.navigationController pushViewController:serverTimeTableViewController animated:YES];
}

- (void)addTimeTable
{
    AddTimeTableViewController *addTimeTableViewController = [[AddTimeTableViewController alloc] init];
    [self.navigationController pushViewController:addTimeTableViewController animated:YES];
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
    [_tableView reloadData];
}

@end
