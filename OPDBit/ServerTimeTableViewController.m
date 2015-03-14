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
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView registerClass:[ServerTimeTableCell class] forCellReuseIdentifier:@"ServerTimeTableCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UIBarButtonItem *downloadServerTimeTableButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(downloadServerTimeTable)];
    self.navigationItem.rightBarButtonItem = downloadServerTimeTableButton;
    
    [self.view addSubview:_tableView];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)downloadServerTimeTable
{
    DownloadServerTimeTableViewController *downloadServerTimeTableViewController = [[DownloadServerTimeTableViewController alloc] init];
    [self.navigationController pushViewController:downloadServerTimeTableViewController animated:YES];
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

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _serverTimeTables = [_dataManager getDownloadedTimeTables];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    self.delegate = nil;
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
