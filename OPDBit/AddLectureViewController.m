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

@property (nonatomic) NSInteger lectureDetailCount;
@property (nonatomic, strong) DataManager *dataManager;

@end

@implementation AddLectureViewController

static CGFloat const headerCellHeight = 150.0f;
static CGFloat const detailCellHeight = 295.0f;
static CGFloat const footerCellHeight = 60.0f;

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
    
    [self setTitle:@"강의 추가"];
    
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
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.allowsSelection = NO;
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
    self.lectureDetails = lectureDictionary[@"lectureDetails"];
    [_tableView reloadData];
}

- (void)setLectureDetails:(NSArray *)lectureDetails
{
    _lectureDetails = lectureDetails;
    _lectureDetailCount = lectureDetails.count;
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
        AddLectureHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:headerCellIdentifier forIndexPath:indexPath];
        if (!cell)
            cell = [[AddLectureHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerCellIdentifier];
        
        cell.lectureName = _lectureDictionary[@"lectureName"];
        cell.lectureTheme = _lectureDictionary[@"theme"];
        
        return cell;
    } else if (indexPath.section == 1) {
        AddLectureDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:detailCellIdentifier forIndexPath:indexPath];
        if (!cell)
            cell = [[AddLectureDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailCellIdentifier];
        
        _lectureDetails[indexPath.row][@"index"] = @(indexPath.row);
        cell.lectureDetailIndex = [_lectureDetails[indexPath.row][@"index"] integerValue];
        cell.lectureLocation = _lectureDetails[indexPath.row][@"lectureLocation"];
        cell.timeStart = [_lectureDetails[indexPath.row][@"timeStart"] integerValue];
        cell.timeEnd = [_lectureDetails[indexPath.row][@"timeEnd"] integerValue];
        cell.day = [_lectureDetails[indexPath.row][@"day"] integerValue];
        
        return cell;
    } else {
        AddLectureFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:footerCellIdentifier forIndexPath:indexPath];
        if (!cell)
            cell = [[AddLectureFooterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:footerCellIdentifier];
        
        cell.delegate = self;
        
        return cell;
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView endEditing:YES];
}

#pragma mark - Add Action

- (void)addLectureDetailAction
{
    NSMutableDictionary *dummyLectureDetail = [[NSMutableDictionary alloc] init];
    NSMutableArray *lectureDetailMutableArray = [[NSMutableArray alloc] initWithArray:_lectureDetails];
    [lectureDetailMutableArray addObject:dummyLectureDetail];
    self.lectureDetails = lectureDetailMutableArray;
    NSIndexPath *newCellIndexPath = [NSIndexPath indexPathForRow:_lectureDetailCount-1 inSection:1];
    [_tableView insertRowsAtIndexPaths:@[newCellIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    [_tableView scrollToRowAtIndexPath:newCellIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    NSLog(@"%@", _lectureDetails);
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
