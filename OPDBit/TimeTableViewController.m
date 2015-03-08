//
//  TimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "TimeTableViewController.h"
#import "TimeTableCell.h"

#import <Masonry/Masonry.h>

@interface TimeTableViewController ()

@end

@implementation TimeTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView registerClass:[TimeTableCell class] forCellReuseIdentifier:@"TimeTableCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeTableCell" forIndexPath:indexPath];
    if (!cell)
        cell = [[TimeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TimeTableCell"];
    
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
