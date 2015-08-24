//
//  LectureViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AppDelegate.h"

// Controller
#import "LectureViewController.h"
#import "AddLectureViewController.h"

// Utility
#import "DataManager.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

// Model
#import "TimeTableObject.h"

// View
#import "LectureTableViewCell.h"

// Library
#import <Masonry/Masonry.h>

@interface LectureViewController ()

@property (nonatomic, strong) UIView *clockLine;
@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) RLMArray *lectureDetails;

@end

@implementation LectureViewController

static CGFloat const LectureCellHeight = 68.0f;

static NSString * const LectureCellIdentifier = @"LectureCell";

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataManager = [DataManager sharedInstance];
        
        _lectureDetails = [[RLMArray alloc] initWithObjectClassName:LectureDetailObjectID];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setTitle:_dataManager.activedTimeTable.timeTableName];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *addLectureButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                        target:self
                                                                        action:@selector(addLectureAction)];
    addLectureButton.tintColor = [UIColor op_textPrimary];
    self.navigationItem.rightBarButtonItem = addLectureButton;
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(openDrawer)];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    _lectureTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_lectureTableView registerClass:[LectureTableViewCell class] forCellReuseIdentifier:LectureCellIdentifier];
    _lectureTableView.delegate = self;
    _lectureTableView.dataSource = self;
    _lectureTableView.backgroundColor = [UIColor clearColor];
    _lectureTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _clockLine = [[UIView alloc] init];
    _clockLine.backgroundColor = [UIColor op_dividerDark];
    
    _emptyLabel = [[UILabel alloc] init];
    _emptyLabel.textColor = [UIColor op_textPrimaryDark];
    _emptyLabel.font = [UIFont op_title];
    _emptyLabel.text = @"수업이 없어요! :D";
    
    _daySegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:[_dataManager daySectionTitles]];
    _daySegmentedControl.borderType = HMSegmentedControlBorderTypeBottom;
    _daySegmentedControl.borderColor = [UIColor op_dividerDark];
    _daySegmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor op_textSecondaryDark],
                                                            NSFontAttributeName : [UIFont op_primary]};
    _daySegmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor op_textPrimaryDark],
                                                                    NSFontAttributeName : [UIFont op_primary]};
    _daySegmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    _daySegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _daySegmentedControl.selectionIndicatorBoxOpacity = 0;
    _daySegmentedControl.selectionIndicatorColor = [UIColor op_primary];
    _daySegmentedControl.selectionIndicatorHeight = 2.0f;
    [_daySegmentedControl addTarget:self
                             action:@selector(changeDay:)
                   forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_emptyLabel];
    [self.view addSubview:_clockLine];
    [self.view addSubview:_daySegmentedControl];
    [self.view addSubview:_lectureTableView];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_daySegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view);
        make.height.equalTo(@45.0);
    }];
    [_lectureTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(_daySegmentedControl.mas_bottom);
    }];
    [_clockLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_daySegmentedControl.mas_bottom);
        make.left.equalTo(self.view).with.offset(20.5f);
        make.bottom.equalTo(self.view);
        make.width.equalTo(@1.0f);
    }];
    [_emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_lectureTableView);
    }];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _lectureDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LectureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LectureCellIdentifier];
    if (!cell)
        cell = [[LectureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LectureCellIdentifier];
    
    LectureDetailObject *lectureDetail = _lectureDetails[indexPath.row];
    NSLog(@"lectureDetail: %@", lectureDetail);
    cell.lectureDetail = lectureDetail;
    cell.lecture = [lectureDetail lecture];

    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LectureCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LectureCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LectureTableViewCell *cell = (LectureTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    AddLectureViewController *editLectureViewController = [[AddLectureViewController alloc] init];
    editLectureViewController.lecture = cell.lecture;
    [self.navigationController pushViewController:editLectureViewController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LectureDetailObject *lectureDetail = _lectureDetails[indexPath.row];
        [_dataManager deleteLectureWithUlid:lectureDetail.lecture.ulid];
//        [KVNProgress showSuccessWithStatus:@"강의 삭제 성공!"];
        
        self.lectureDetails = [_dataManager lectureDetailsWithDay:_daySegmentedControl.selectedSegmentIndex];
        if (_daySegmentedControl.selectedSegmentIndex > 4) _daySegmentedControl.selectedSegmentIndex = 4;
        _daySegmentedControl.sectionTitles = [_dataManager daySectionTitles];
        [_daySegmentedControl setNeedsDisplay];
    }
}

#pragma mark - Segmented Control Delegate

- (void)changeDay:(HMSegmentedControl *)segmentedControl
{
    self.lectureDetails = [_dataManager lectureDetailsWithDay:segmentedControl.selectedSegmentIndex];
}

#pragma mark - Setter

- (void)setLectureDetails:(RLMArray *)lectureDetails
{

    _lectureDetails = lectureDetails;
    [self hideTableView:[self lectureDetailsAreEmpty]];
}

#pragma mark - Instance Method

- (BOOL)lectureDetailsAreEmpty
{
    return !_lectureDetails.count;
}

- (void)hideTableView:(BOOL)hide
{
    _lectureTableView.hidden = hide;
    _clockLine.hidden = hide;
    _emptyLabel.hidden = !hide;
    
    if (!hide) [_lectureTableView reloadData];
}

#pragma mark - Bar Button Action

- (void)addLectureAction
{
    if (_dataManager.activedTimeTable == nil) {
//        [KVNProgress showErrorWithStatus:@"기본 시간표가\n선택되지 않았습니다!"];
        return;
    }
    
    AddLectureViewController *addLectureViewController = [[AddLectureViewController alloc] init];
    [self.navigationController pushViewController:addLectureViewController animated:YES];
}

- (void)openDrawer
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.lectureDetails = [_dataManager lectureDetailsWithDay:_daySegmentedControl.selectedSegmentIndex];
    if (_daySegmentedControl.selectedSegmentIndex > 4) _daySegmentedControl.selectedSegmentIndex = 4;
    _daySegmentedControl.sectionTitles = [_dataManager daySectionTitles];
    [_daySegmentedControl setNeedsDisplay];
}

@end
