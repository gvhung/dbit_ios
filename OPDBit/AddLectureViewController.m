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

#import "MZTimePickerView.h"
#import "MZSnackBar.h"

// Utility
#import "UIColor+OPTheme.h"
#import "DataManager.h"

// Model
#import "TimeTableObject.h"
#import "LectureObject.h"
#import "LectureDetailObject.h"

// Library
#import <Masonry/Masonry.h>

@interface AddLectureViewController () <AddLectureHeaderCellDelegate, AddLectureDetailCellDelegate, AddLectureFooterCellDelegate, SearchLectureViewControllerDelegate, MZTimePickerDelegate>

@property (strong, nonatomic) MZSnackBar *snackBar;

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) RLMArray<LectureDetailObject> *lectureDetails;
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
        _dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        _dateFormatter.locale = [NSLocale systemLocale];
        
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
    
    UIBarButtonItem *addLectureButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(addLectureAction)];
    
    if(_dataManager.activedTimeTable.serverSemesterObject) {
        UIBarButtonItem *searchLectureButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(searchLectureAction)];
        self.navigationItem.rightBarButtonItems = @[addLectureButton, searchLectureButton];
    } else {
        self.navigationItem.rightBarButtonItems = @[addLectureButton];
    }
    
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
    if (lecture) {
        LectureObject *copiedLecture = [[LectureObject alloc] init];
        copiedLecture.ulid = lecture.ulid;
        copiedLecture.lectureName = lecture.lectureName;
        copiedLecture.theme = lecture.theme;
        _lecture = copiedLecture;
        
        _isModifying = YES;
        [_lectureDetails removeAllObjects];
        for (LectureDetailObject *lectureDetail in lecture.lectureDetails) {
            LectureDetailObject *copiedLectureDetail = [[LectureDetailObject alloc] init];
            copiedLectureDetail.lectureLocation = lectureDetail.lectureLocation;
            copiedLectureDetail.timeStart = lectureDetail.timeStart;
            copiedLectureDetail.timeEnd = lectureDetail.timeEnd;
            copiedLectureDetail.day = lectureDetail.day;
            [_lectureDetails addObject:copiedLectureDetail];
        }
        [_tableView reloadData];
    } else {
        _lecture = lecture;
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
        [tableView reloadData];
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
    NSInteger index = addLectureDetailCell.lectureDetailIndex;
    NSDate *timeStart;
    NSDate *timeEnd;
    if (addLectureDetailCell.timeStart >= 0) {
        timeStart = [_dateFormatter dateFromString:[NSString stringWithFormat:@"%04ld", addLectureDetailCell.timeStart]];
    }
    if (addLectureDetailCell.timeEnd >= 0) {
        timeEnd = [_dateFormatter dateFromString:[NSString stringWithFormat:@"%04ld", addLectureDetailCell.timeEnd]];
    }
    
    if (!_timePickerView) {
        _timePickerView = [[MZTimePickerView alloc] initWithFrame:self.view.bounds];
        _timePickerView.delegate = self;
        [self.view addSubview:_timePickerView];
    }
    [_timePickerView setType:MZTimePickerTypeStart startTime:timeStart endTime:timeEnd lectureDetailIndex:index];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, UIDatePickerDefaultHeight + MZTimePickerToolbarHeight, 0);
    [_tableView setContentInset:insets];
    [_tableView setScrollIndicatorInsets:insets];
    NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:index inSection:1];
    [_tableView scrollToRowAtIndexPath:indexPathToReload atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [_timePickerView animateToAppear];
}

- (void)addLectureDetailCellDidTappedTimeEndButton:(AddLectureDetailCell *)addLectureDetailCell
{
    NSInteger index = addLectureDetailCell.lectureDetailIndex;
    NSDate *timeStart;
    NSDate *timeEnd;
    if (addLectureDetailCell.timeStart >= 0) {
        timeStart = [_dateFormatter dateFromString:[NSString stringWithFormat:@"%04ld", addLectureDetailCell.timeStart]];
        NSLog(@"%ld", addLectureDetailCell.timeStart);
    }
    if (addLectureDetailCell.timeEnd >= 0) {
        timeEnd = [_dateFormatter dateFromString:[NSString stringWithFormat:@"%04ld", addLectureDetailCell.timeEnd]];
    }
    
    if (!_timePickerView) {
        _timePickerView = [[MZTimePickerView alloc] initWithFrame:self.view.bounds];
        _timePickerView.delegate = self;
        [self.view addSubview:_timePickerView];
    }
    [_timePickerView setType:MZTimePickerTypeEnd startTime:timeStart endTime:timeEnd lectureDetailIndex:index];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, UIDatePickerDefaultHeight + MZTimePickerToolbarHeight, 0);
    [_tableView setContentInset:insets];
    [_tableView setScrollIndicatorInsets:insets];
    NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:index inSection:1];
    [_tableView scrollToRowAtIndexPath:indexPathToReload atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [_timePickerView animateToAppear];
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
    if (!_dataManager.activedTimeTable.serverSemesterObject) {
        if (!_snackBar) {
            _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        }
        _snackBar.message = @"서버 시간표가 연동되지 않았습니다.";
        [_snackBar animateToAppearInView:self.view];
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
    
    NSString *errorMessage;
    
    if (!_lecture.lectureName.length) {
        if (!_snackBar) {
            _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        }
        _snackBar.message = @"강의 이름을 입력해주세요!";
        [_snackBar animateToAppearInView:self.view];
        return;
    }
    if (_lecture.theme == -1) {
        if (!_snackBar) {
            _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        }
        _snackBar.message = @"테마를 추가해주세요!";
        [_snackBar animateToAppearInView:self.view];
        return;
    }
    
    if (_lectureDetails.count == 0){
        if (!_snackBar) {
            _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        }
        
        _snackBar.message = @"수업이 하나도 추가되지 않았습니다!";
        [_snackBar animateToAppearInView:self.view];
        return;
    }
    
    errorMessage = [_dataManager lectureAreDuplicatedOtherLecture:_lecture lectureDetails:_lectureDetails inTimeTable:_dataManager.activedTimeTable];
    if (errorMessage) {
        if (!_snackBar) {
            _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        }
        
        _snackBar.message = [errorMessage stringByAppendingString:@" 수업과 시간이 겹칩니다!"];
        [_snackBar animateToAppearInView:self.view];
        return;
    }
    
    errorMessage = [_dataManager lectureDetailTimeIsEmpty:_lecture lectureDetails:_lectureDetails];
    if (errorMessage) {
        if (!_snackBar) {
            _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        }
        
        _snackBar.message = errorMessage;
        [_snackBar animateToAppearInView:self.view];
        return;
    }
    
    [_dataManager saveOrUpdateLectureWithLecture:_lecture
                                  lectureDetails:_lectureDetails
                                      completion:^(BOOL isUpdated) {
                                          
                                          if ([_delegate respondsToSelector:@selector(addLectureViewControllerDidDone:isModfiying:)]) {
                                              [_delegate addLectureViewControllerDidDone:self isModfiying:isUpdated];
                                          }
                                          
                                          [self.navigationController popViewControllerAnimated:YES];
                                      }];
}

#pragma mark - Time Picker Delegate

- (void)timePickerView:(MZTimePickerView *)timePickerView didChangedTime:(NSDate *)newDate
{
    NSInteger selectedTime = [[_dateFormatter stringFromDate:newDate] integerValue];
    NSInteger index = timePickerView.lectureDetailIndex;
    LectureDetailObject *lectureDetail = _lectureDetails[index];
    if (timePickerView.type == MZTimePickerTypeStart) {
        NSInteger endTime = lectureDetail.timeEnd;
        
        if (endTime != -1 && selectedTime > endTime) {
            if (!_snackBar) {
                _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
            }
            _snackBar.message = @"강의종료보다 늦습니다!";
            [_snackBar animateToAppearInView:self.view];
            [timePickerView.datePicker setDate:[_dateFormatter dateFromString:[NSString stringWithFormat:@"%04ld", lectureDetail.timeEnd]] animated:YES];
        }
    } else {
        NSInteger startTime = lectureDetail.timeStart;
        
        if (startTime != -1 && selectedTime < startTime) {
            if (!_snackBar) {
                _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
            }
            _snackBar.message = @"강의시작보다 이릅니다!";
            [_snackBar animateToAppearInView:self.view];
            [timePickerView.datePicker setDate:[_dateFormatter dateFromString:[NSString stringWithFormat:@"%04ld", lectureDetail.timeStart]] animated:YES];
        }
    }
}

- (void)timePickerView:(MZTimePickerView *)timePickerView doneWithTime:(NSDate *)newDate
{
    NSInteger selectedTime = [[_dateFormatter stringFromDate:newDate] integerValue];
    NSInteger index = timePickerView.lectureDetailIndex;
    LectureDetailObject *lectureDetail = _lectureDetails[index];
    if (timePickerView.type == MZTimePickerTypeStart) {
        NSInteger endTime = lectureDetail.timeEnd;
        
        if (endTime != -1 && selectedTime > endTime) {
            return;
        }
        
        lectureDetail.timeStart = selectedTime;
    } else {
        NSInteger startTime = lectureDetail.timeStart;
        
        if (startTime != -1 && selectedTime < startTime) {
            return;
        }
        
        lectureDetail.timeEnd = selectedTime;
    }
    
    [_lectureDetails replaceObjectAtIndex:index withObject:lectureDetail];
    
    [UIView animateWithDuration:.35f animations:^{
        [_tableView setContentInset:UIEdgeInsetsZero];
        [_tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    }];
    [timePickerView animateToDisappearWithCompletion:^(BOOL finished) {
        NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:timePickerView.lectureDetailIndex inSection:1];
        [_tableView reloadRowsAtIndexPaths:@[indexPathToReload] withRowAnimation:UITableViewRowAnimationNone];
        [timePickerView removeFromSuperview];
        _timePickerView = nil;
    }];
}

- (void)timePickerViewDidCanceled:(MZTimePickerView *)timePickerView
{
    [UIView animateWithDuration:.35f animations:^{
        [_tableView setContentInset:UIEdgeInsetsZero];
        [_tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    }];
    [timePickerView animateToDisappearWithCompletion:^(BOOL finished) {
        NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:timePickerView.lectureDetailIndex inSection:1];
        [_tableView reloadRowsAtIndexPaths:@[indexPathToReload] withRowAnimation:UITableViewRowAnimationNone];
        [timePickerView removeFromSuperview];
        _timePickerView = nil;
    }];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
