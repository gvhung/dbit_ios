//
//  AddLectureViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AddLectureViewController.h"
#import "AddLectureHeaderCell.h"
#import "AddLectureDetailCell.h"
#import "AddLectureFooterCell.h"

#import "SearchLectureViewController.h"
#import "DataManager.h"

#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface AddLectureViewController ()

@property (nonatomic, strong) NSArray *lectureDetails;

@property (nonatomic, strong) DataManager *dataManager;

@end

@implementation AddLectureViewController

static CGFloat const detailCellHeight = 200.0f;
static CGFloat const headerCellHeight = 200.0f;
static CGFloat const footerCellHeight = 200.0f;

static NSString * const headerCellIdentifier = @"AddLectureHeaderCell";
static NSString * const detailCellIdentifier = @"AddLectureDetailCell";
static NSString * const footerCellIdentifier = @"AddLectureFooterCell";

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataManager = [DataManager sharedInstance];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _lectureDetails = [[NSMutableArray alloc] init];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *searchLectureButton = [[UIBarButtonItem alloc] initWithTitle:@"찾기"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(searchLectureAction)];
    UIBarButtonItem *addLectureButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                      target:self
                                                                                      action:@selector(addLectureAction)];;
    
    self.navigationItem.rightBarButtonItems = @[addLectureButton, searchLectureButton];
    
    [_tableView registerClass:[AddLectureHeaderCell class] forCellReuseIdentifier:headerCellIdentifier];
    [_tableView registerClass:[AddLectureDetailCell class] forCellReuseIdentifier:detailCellIdentifier];
    [_tableView registerClass:[AddLectureFooterCell class] forCellReuseIdentifier:footerCellIdentifier];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = UITableViewRowAnimationAutomatic;
    
    [self.view addSubview:_tableView];
    
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

#pragma mark - Setter

- (void)setLectureDictionary:(NSDictionary *)lectureDictionary
{
    _lectureDictionary = lectureDictionary;
    _lectureDetails = lectureDictionary[@"lectureDetails"];
    [_tableView reloadData];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 2)
        return 1;
    return _lectureDetails.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return headerCellHeight;
    if (indexPath.section == 1)
        return detailCellHeight;
    return footerCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
//        AddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddLectureCell" forIndexPath:indexPath];
        AddLectureHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddLectureHeader" forIndexPath:<#(NSIndexPath *)#>]
        if (!cell)
            cell = [[AddLectureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddLectureCell"];
    } else if (indexPath.section == 1) {
        
    } else {
        
    }
    
    
    return cell;
}

#pragma mark - Bar Button Action

- (void)searchLectureAction
{
    if (_dataManager.activedTimeTable == nil) {
        [KVNProgress showErrorWithStatus:@"기본 시간표가\n선택되지 않았습니다!"];
        return;
    }
    if([_dataManager.activedTimeTable[@"serverId"] integerValue] == -1) {
        [KVNProgress showErrorWithStatus:@"선택한 시간표가 서버 시간표와\n연동되지 않았습니다!"];
        return;
    }
    SearchLectureViewController *searchLectureViewController = [[SearchLectureViewController alloc] init];
    searchLectureViewController.serverLectures = [_dataManager getServerLecturesWithServerTimeTableId:[_dataManager.activedTimeTable[@"serverId"] integerValue]];
    searchLectureViewController.delegate = self;
    [self.navigationController pushViewController:searchLectureViewController animated:YES];
}

- (void)addLectureAction
{
    
}

#pragma mark - Life Cycle

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
