//
//  AddLectureViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//


// Controller
#import "SearchLectureViewController.h"
#import "AddLectureViewController.h"

// View
#import "AddLectureHeaderCell.h"
#import "AddLectureDetailCell.h"
#import "AddLectureFooterCell.h"

// Utility
#import "UIColor+OPTheme.h"
#import "DataManager.h"

// Model
#import "TimeTableObject.h"
#import "LectureObject.h"
#import "LectureDetailObject.h"

// Library
#import <Masonry/Masonry.h>

@interface AddLectureViewController () <AddLectureHeaderCellDelegate, AddLectureDetailCellDelegate, AddLectureFooterCellDelegate, SearchLectureViewControllerDelegate>

@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) RLMArray *lectureDetails;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic) BOOL isModifying;

@end

@implementation AddLectureViewController

static NSInteger const headerCellSection = 0;
static NSInteger const detailCellSection = 1;
static NSInteger const footerCellSection = 2;

static CGFloat const headerCellHeight = 150.0f;
static CGFloat const detailCellHeight = 255.0f;
static CGFloat const footerCellHeight = 55.0f;

static NSString * const headerCellIdentifier = @"AddLectureHeaderCell";
static NSString * const detailCellIdentifier = @"AddLectureDetailCell";
static NSString * const footerCellIdentifier = @"AddLectureFooterCell";

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _timePickerViewController = [RMDateSelectionViewController dateSelectionController];
        _lecture = [[LectureObject alloc] init];
        [_lecture setDefaultProperties];
        
        _dataManager = [DataManager sharedInstance];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _lectureDetails = [[RLMArray alloc] initWithObjectClassName:LectureDetailObjectID];
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.view.backgroundColor = [UIColor whiteColor];
    _isModifying = NO;
    
    _dateFormatter.dateFormat = @"HHmm";
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
    _dateFormatter.locale = locale;
    
    _timePickerViewController.hideNowButton = YES;
    _timePickerViewController.disableBouncingWhenShowing = YES;
    _timePickerViewController.datePicker.locale = locale;
    _timePickerViewController.datePicker.datePickerMode = UIDatePickerModeTime;
    _timePickerViewController.datePicker.minuteInterval = 5;
    _timePickerViewController.datePicker.timeZone = [NSTimeZone localTimeZone];
    
    UIBarButtonItem *searchLectureButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(searchLectureAction)];
    UIBarButtonItem *addLectureButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(addLectureAction)];
    
    self.navigationItem.rightBarButtonItems = @[addLectureButton, searchLectureButton];
    
    [_tableView registerClass:[AddLectureHeaderCell class] forCellReuseIdentifier:headerCellIdentifier];
    [_tableView registerClass:[AddLectureDetailCell class] forCellReuseIdentifier:detailCellIdentifier];
    [_tableView registerClass:[AddLectureFooterCell class] forCellReuseIdentifier:footerCellIdentifier];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.allowsSelection = NO;
    _tableView.rowHeight = UITableViewRowAnimationAutomatic;

    LectureDetailObject *lectureDetail = [[LectureDetailObject alloc] init];
    [lectureDetail setDefaultProperties];
    [_lectureDetails addObject:lectureDetail];
    
    [self.view addSubview:_tableView];
    
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated
{
    if (_isModifying) {
        self.title = @"강의 수정";
    } else {
        self.title = @"강의 추가";
    }
}

#pragma mark - Setter

- (void)setLecture:(LectureObject *)lecture
{
    _lecture = lecture;
    if (lecture) {
        _isModifying = YES;
        _lectureDetails = [[RLMArray alloc] initWithObjectClassName:LectureDetailObjectID];
        for (LectureDetailObject *lectureDetail in lecture.lectureDetails) {
            LectureDetailObject *copiedLectureDetail = [[LectureDetailObject alloc] init];
            copiedLectureDetail.lectureLocation = lectureDetail.lectureLocation;
            copiedLectureDetail.timeStart = lectureDetail.timeStart;
            copiedLectureDetail.timeEnd = lectureDetail.timeEnd;
            copiedLectureDetail.day = lectureDetail.day;
            [_lectureDetails addObject:copiedLectureDetail];
        }
        [_tableView reloadData];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == headerCellSection || section == footerCellSection)
        return 1;
    return _lectureDetails.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == headerCellSection)
        return headerCellHeight;
    if (indexPath.section == detailCellSection)
        return detailCellHeight;
    return footerCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == headerCellSection) {
        AddLectureHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:headerCellIdentifier forIndexPath:indexPath];
        if (!cell)
            cell = [[AddLectureHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerCellIdentifier];
        
        cell.delegate = self;
        
        cell.lectureName = _lecture.lectureName;
        cell.lectureTheme = _lecture.theme;
        
        return cell;
    } else if (indexPath.section == detailCellSection) {
        AddLectureDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:detailCellIdentifier forIndexPath:indexPath];
        if (!cell)
            cell = [[AddLectureDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailCellIdentifier];
        
        cell.delegate = self;
        
        LectureDetailObject *lectureDetail = _lectureDetails[indexPath.row];
        
        cell.lectureDetailIndex = indexPath.row;
        cell.lectureLocation = lectureDetail.lectureLocation;
        cell.timeStart = lectureDetail.timeStart;
        cell.timeEnd = lectureDetail.timeEnd;
        cell.day = lectureDetail.day;
        
        return cell;
    } else {
        AddLectureFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:footerCellIdentifier forIndexPath:indexPath];
        if (!cell)
            cell = [[AddLectureFooterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:footerCellIdentifier];

        cell.delegate = self;

        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (indexPath.section == detailCellSection)
        return YES;
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_lectureDetails removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Header Cell Delegate

- (void)addLectureHeaderCell:(AddLectureHeaderCell *)addLectureHeaderCell didChangedName:(NSString *)name
{
    _lecture.lectureName = name;
}

- (void)addLectureHeaderCell:(AddLectureHeaderCell *)addLectureHeaderCell didChangedTheme:(NSInteger)themeID
{
    _lecture.theme = themeID;
}

#pragma mark - Detail Cell Delegate

- (void)addLectureDetailCell:(AddLectureDetailCell *)addLectureDetailCell didChangedLocation:(NSString *)location
{
    NSInteger index = addLectureDetailCell.lectureDetailIndex;
    LectureDetailObject *lectureDetail = _lectureDetails[index];
    lectureDetail.lectureLocation = location;
    [_lectureDetails replaceObjectAtIndex:index withObject:lectureDetail];
}

- (void)addLectureDetailCell:(AddLectureDetailCell *)addLectureDetailCell didChangedDay:(NSInteger)day
{
    NSInteger index = addLectureDetailCell.lectureDetailIndex;
    LectureDetailObject *lectureDetail = _lectureDetails[index];
    lectureDetail.day = day;
    [_lectureDetails replaceObjectAtIndex:index withObject:lectureDetail];
}

- (void)addLectureDetailCellDidTappedTimeStartButton:(AddLectureDetailCell *)addLectureDetailCell
{
    [_timePickerViewController showWithSelectionHandler:^(RMDateSelectionViewController *vc, NSDate *aDate) {
        NSInteger selectedStartTime = [[_dateFormatter stringFromDate:aDate] integerValue];
        NSInteger index = addLectureDetailCell.lectureDetailIndex;
        
        LectureDetailObject *lectureDetail = _lectureDetails[index];
        NSInteger endTime = lectureDetail.timeEnd;
        
        if (endTime && selectedStartTime > endTime) {
//            [KVNProgress showErrorWithStatus:@"강의종료보다 늦습니다!"];
            return;
        }
        
        lectureDetail.timeStart = selectedStartTime;
        [_lectureDetails replaceObjectAtIndex:index withObject:lectureDetail];
        
        NSIndexPath *indexPathToReload = [_tableView indexPathForCell:addLectureDetailCell];
        [_tableView reloadRowsAtIndexPaths:@[indexPathToReload] withRowAnimation:UITableViewRowAnimationNone];
    } andCancelHandler:nil];
}

- (void)addLectureDetailCellDidTappedTimeEndButton:(AddLectureDetailCell *)addLectureDetailCell
{
    [_timePickerViewController showWithSelectionHandler:^(RMDateSelectionViewController *vc, NSDate *aDate) {
        NSInteger selectedEndTime = [[_dateFormatter stringFromDate:aDate] integerValue];
        NSInteger index = addLectureDetailCell.lectureDetailIndex;
        
        LectureDetailObject *lectureDetail = _lectureDetails[index];
        NSInteger startTime = lectureDetail.timeStart;
        
        if (startTime && selectedEndTime < startTime) {
//            [KVNProgress showErrorWithStatus:@"강의시작보다 이릅니다!"];
            return;
        }
        
        lectureDetail.timeEnd = selectedEndTime;
        [_lectureDetails replaceObjectAtIndex:index withObject:lectureDetail];
        
        NSIndexPath *indexPathToReload = [_tableView indexPathForCell:addLectureDetailCell];
        [_tableView reloadRowsAtIndexPaths:@[indexPathToReload] withRowAnimation:UITableViewRowAnimationNone];
    } andCancelHandler:nil];
}

#pragma mark - Footer Cell Delegate

- (void)addLectureFooterCellDidTapped:(AddLectureFooterCell *)addLectureFooterCell
{
    LectureDetailObject *newLectureDetail = [[LectureDetailObject alloc] init];
    [newLectureDetail setDefaultProperties];
    [_lectureDetails addObject:newLectureDetail];
    
    NSIndexPath *newCellIndexPath = [NSIndexPath indexPathForRow:_lectureDetails.count-1 inSection:1];
    [_tableView endEditing:YES];
    [_tableView insertRowsAtIndexPaths:@[newCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [_tableView scrollToRowAtIndexPath:newCellIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Search Lecture View Controller Delegate

- (void)searchLectureViewController:(SearchLectureViewController *)searchLectureViewController didDoneWithLectureObject:(LectureObject *)lectureObject
{
    _lecture = lectureObject;
    _lectureDetails = lectureObject.lectureDetails;
    
    [_tableView reloadData];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [scrollView endEditing:YES];
}

#pragma mark - Bar Button Action

- (void)searchLectureAction
{
    if(!_dataManager.activedTimeTable.serverSemesterObject) {
//        [KVNProgress showErrorWithStatus:@"선택한 시간표가 서버 시간표와\n연동되지 않았습니다!"];
        return;
    }
    
    SearchLectureViewController *searchLectureViewController = [[SearchLectureViewController alloc] initWithLecture:_lecture];
    searchLectureViewController.serverSemester = _dataManager.activedTimeTable.serverSemesterObject;
    searchLectureViewController.delegate = self;
    [self setTitle:@""];
    [self.navigationController pushViewController:searchLectureViewController animated:YES];
}

- (void)addLectureAction
{
    [_tableView endEditing:YES];
    if (!_lecture.lectureName.length) {
//        [KVNProgress showErrorWithStatus:@"강의 이름을 입력해주세요!"];
        return;
    }
    if (_lecture.theme == -1) {
//        [KVNProgress showErrorWithStatus:@"테마를 입력해주세요!"];
        return;
    }
    
    if (_lectureDetails.count == 0){
//        [KVNProgress showErrorWithStatus:@"수업이 하나도 추가되지 않았습니다!"];
        return;
    }
    
    if ([_dataManager lectureAreDuplicatedOtherLecture:_lecture inTimeTable:_dataManager.activedTimeTable]) {
//        [KVNProgress showErrorWithStatus:@"다른 수업과 시간이 겹칩니다!"];
        return;
    }
    
    [_dataManager saveOrUpdateLectureWithLecture:_lecture
                                  lectureDetails:_lectureDetails
                                      completion:^(BOOL isUpdated) {
                                          if (isUpdated) {
//                                              [KVNProgress showSuccessWithStatus:@"강의 수정 성공!"];
                                          } else {
//                                              [KVNProgress showSuccessWithStatus:@"강의 추가 성공!"];
                                          }
                                      }];
    if ([_delegate respondsToSelector:@selector(addLectureViewControllerDidDone:)]) {
        [_delegate addLectureViewControllerDidDone:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
