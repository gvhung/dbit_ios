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

#import <Masonry/Masonry.h>

@interface TimeTableViewController ()

@property (nonatomic, strong) NSArray *timeTables;
@property (nonatomic, strong) DataManager *dataManager;

@end

@implementation TimeTableViewController

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
    
    UIBarButtonItem *addTimeTableButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTimeTable)];
    UIBarButtonItem *downloadServerTimeTableButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(downloadServerTimeTable)];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView registerClass:[TimeTableCell class] forCellReuseIdentifier:@"TimeTableCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.navigationItem.rightBarButtonItems = @[downloadServerTimeTableButton, addTimeTableButton];
    [self.view addSubview:_tableView];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

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
    TimeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeTableCell" forIndexPath:indexPath];
    if (!cell)
        cell = [[TimeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TimeTableCell"];
    cell.textLabel.text = _timeTables[indexPath.row][@"timeTableName"];
    
    return cell;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _timeTables = [_dataManager timeTables];
    [_tableView reloadData];
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
