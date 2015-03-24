//
//  DownloadServerTimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "ServerTimeTableViewController.h"
#import "ServerTimeTableCell.h"
#import "DownloadServerTimeTableViewController.h"
#import "DataManager.h"

#import <Masonry/Masonry.h>

@interface ServerTimeTableViewController ()

@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) NSArray *serverTimeTables;

@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation ServerTimeTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataManager = [DataManager sharedInstance];
        _serverTimeTables = [[NSArray alloc] init];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setTitle:@"서버 시간표"];
    self.view.backgroundColor = [UIColor whiteColor];

    UIBarButtonItem *downloadServerTimeTableButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(downloadServerTimeTable)];
    self.navigationItem.rightBarButtonItem = downloadServerTimeTableButton;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView registerClass:[ServerTimeTableCell class] forCellReuseIdentifier:@"ServerTimeTableCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _emptyLabel = [[UILabel alloc] init];
    _emptyLabel.text = @"서버 시간표가 없어요! :D";
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_emptyLabel];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
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
    return _serverTimeTables.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerTimeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServerTimeTableCell"];
    if (!cell)
        cell = [[ServerTimeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServerTimeTableCell"];
    cell.textLabel.text = _serverTimeTables[indexPath.row][@"semester"];
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.delegate) return;
    self.delegate.selectedServerTimeTableId = [_serverTimeTables[indexPath.row][@"timeTableId"] integerValue];
    [self.navigationController popToViewController:self.delegate animated:YES];
}

#pragma mark - Setter

- (void)setServerTimeTables:(NSArray *)serverTimeTables
{
    _serverTimeTables = serverTimeTables;
    [self hideTableView:[self serverTimeTablesAreEmpty]];
}

#pragma mark - Instance Method

- (BOOL)serverTimeTablesAreEmpty
{
    return !_serverTimeTables.count;
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
    DownloadServerTimeTableViewController *downloadServerTimeTableViewController = [[DownloadServerTimeTableViewController alloc] init];
    [self.navigationController pushViewController:downloadServerTimeTableViewController animated:YES];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.serverTimeTables = [_dataManager downloadedTimeTables];
    [_tableView reloadData];
}

@end
