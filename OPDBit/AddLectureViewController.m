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
#import "LectureObject.h"
#import "LectureDetailObject.h"

// Library
#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface AddLectureViewController () <AddLectureHeaderCellDelegate, AddLectureDetailCellDelegate, AddLectureFooterCellDelegate>

@property (nonatomic) NSInteger lectureDetailCount;
@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) RLMArray *lectureDetails;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation AddLectureViewController

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
    [self setTitle:@"강의 추가"];
    
    _dateFormatter.dateFormat = @"HHmm";
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
    _dateFormatter.locale = locale;
    
    _timePickerViewController.delegate = self;
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

- (void)setServerLectureDictionary:(NSDictionary *)serverLectureDictionary
{
    _serverLectureDictionary = serverLectureDictionary;
    _lectureDictionary[@"lectureName"] = serverLectureDictionary[@"lectureName"];
    self.lectureDetails = serverLectureDictionary[@"lectureDetails"];
    [_tableView reloadData];
}

- (void)setLectureDetails:(NSArray *)lectureDetails
{
    _lectureDetails = lectureDetails;
    _lectureDetailCount = lectureDetails.count;
}

- (void)setUlidToEdit:(NSInteger)ulidToEdit
{
    _ulidToEdit = ulidToEdit;
    [self setTitle:@"강의 수정"];
    
    NSDictionary *lectureDictionary = [_dataManager lectureWithUlid:ulidToEdit];
    _lectureDictionary[@"lectureName"] = lectureDictionary[@"lectureName"];
    _lectureDictionary[@"theme"] = lectureDictionary[@"theme"];
    self.lectureDetails = lectureDictionary[@"lectureDetails"];
    
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
        AddLectureHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:headerCellIdentifier forIndexPath:indexPath];
        if (!cell)
            cell = [[AddLectureHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerCellIdentifier];
        
        cell.delegate = self;
        
        cell.lectureName = _lectureDictionary[@"lectureName"];
        cell.lectureTheme = [_lectureDictionary[@"theme"] integerValue];
        
        return cell;
    } else if (indexPath.section == 1) {
        AddLectureDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:detailCellIdentifier forIndexPath:indexPath];
        if (!cell)
            cell = [[AddLectureDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailCellIdentifier];
        
        cell.delegate = self;
        
        _lectureDetails[indexPath.row][@"index"] = @(indexPath.row+1);
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (indexPath.section == 1)
        return YES;
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *lectureDetailMutableArray = [[NSMutableArray alloc] initWithArray:_lectureDetails];
        [lectureDetailMutableArray removeObjectAtIndex:indexPath.row];
        _lectureDetails = lectureDetailMutableArray;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Header Cell Delegate

- (void)addLectureHeaderCell:(AddLectureHeaderCell *)addLectureHeaderCell didChangedName:(NSString *)name
{
    
}

- (void)addLectureHeaderCell:(AddLectureHeaderCell *)addLectureHeaderCell didChangedTheme:(NSInteger)themeID
{
    
}

#pragma mark - Detail Cell Delegate

- (void)addLectureDetailCell:(AddLectureDetailCell *)addLectureDetailCell didChangedLocation:(NSString *)location
{
    
}

- (void)addLectureDetailCell:(AddLectureDetailCell *)addLectureDetailCell didChangedDay:(NSInteger)day
{
    
}

- (void)addLectureDetailCellDidTappedTimeStartButton:(AddLectureDetailCell *)addLectureDetailCell
{
    
}

- (void)addLectureDetailCellDidTappedTimeEndButton:(AddLectureDetailCell *)addLectureDetailCell
{
    
}

#pragma mark - Footer Cell Delegate

- (void)addLectureFooterCellDidTapped:(AddLectureFooterCell *)addLectureFooterCell
{
    
}

/*
#pragma mark - Text Field Delegate

- (void)textFieldDidChanged:(UITextField *)textField
{
    if (textField.tag == -1) {
        _lectureDictionary[@"lectureName"] = textField.text;
    } else {
        _lectureDetails[textField.tag-1][@"lectureLocation"] = textField.text;
    }
}

#pragma mark - Segmented Control Delegate

- (void)segmentedControlDidChanged:(HMSegmentedControl *)segmentedControl
{
    if (segmentedControl.tag == -1)
        _lectureDictionary[@"theme"] = @(segmentedControl.selectedSegmentIndex);
    else
        _lectureDetails[segmentedControl.tag-1][@"day"] = @(segmentedControl.selectedSegmentIndex);
    [_tableView reloadData];
}

#pragma mark - Time Change Method

- (void)timeButtonTapped:(UIButton *)button
{
    _timePickerViewController.datePicker.tag = button.tag;
    [_timePickerViewController show];
}
*/

#pragma mark - RMDateSelectionViewController Delegate

- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate
{
    NSInteger lectureDetailIndex = labs(vc.datePicker.tag)-1;
    NSString *timeString = [_dateFormatter stringFromDate:aDate];
    NSString *timeKey = (vc.datePicker.tag > 0) ? @"timeStart" : @"timeEnd";
    if (vc.datePicker.tag < 0 && _lectureDetails[lectureDetailIndex][@"timeStart"]) {
        if ([_lectureDetails[lectureDetailIndex][@"timeStart"] integerValue] > [timeString integerValue]) {
            [KVNProgress showErrorWithStatus:@"강의시작보다 이릅니다!"];
            return;
        }
    }

    if (vc.datePicker.tag > 0 && _lectureDetails[lectureDetailIndex][@"timeEnd"]) {
        if ([_lectureDetails[lectureDetailIndex][@"timeEnd"] integerValue] < [timeString integerValue]) {
            [KVNProgress showErrorWithStatus:@"강의종료보다 늦습니다!"];
            return;
        }
    }

    _lectureDetails[lectureDetailIndex][timeKey] = timeString;
    NSIndexPath *newCellIndexPath = [NSIndexPath indexPathForRow:lectureDetailIndex inSection:1];
    [_tableView reloadRowsAtIndexPaths:@[newCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    [_tableView endEditing:YES];
    [_tableView insertRowsAtIndexPaths:@[newCellIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    [_tableView scrollToRowAtIndexPath:newCellIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Bar Button Action

- (void)searchLectureAction
{
    if([_dataManager.activedTimeTable[@"serverId"] integerValue] == -1) {
        [KVNProgress showErrorWithStatus:@"선택한 시간표가 서버 시간표와\n연동되지 않았습니다!"];
        return;
    }
    
    SearchLectureViewController *searchLectureViewController = [[SearchLectureViewController alloc] init];
    searchLectureViewController.serverLectures = [_dataManager serverLecturesWithServerTimeTableId:[_dataManager.activedTimeTable[@"serverId"] integerValue]];
    searchLectureViewController.delegate = self;
    [self setTitle:@""];
    [self.navigationController pushViewController:searchLectureViewController animated:YES];
}

- (void)addLectureAction
{
    [_tableView endEditing:YES];
    if (!_lectureDictionary[@"lectureName"]) {
        [KVNProgress showErrorWithStatus:@"강의 이름을 입력해주세요!"];
        return;
    }
    if (!_lectureDictionary[@"theme"]) {
        [KVNProgress showErrorWithStatus:@"테마를 입력해주세요!"];
        return;
    }
    
    if (_lectureDetails.count == 0){
        [KVNProgress showErrorWithStatus:@"수업이 하나도 추가되지 않았습니다!"];
        return;
    }
    
    for (NSInteger i = 0; i < _lectureDetails.count; i++) {
        if (!_lectureDetails[i][@"lectureLocation"]) {
            _lectureDetails[i][@"lectureLocation"] = @"";
        }
    }
    
    if (_ulidToEdit == -1) {
        if ([_dataManager lectureDetailsAreDuplicatedOtherLectureDetails:_lectureDetails]) {
            [KVNProgress showErrorWithStatus:@"다른 수업과 시간이 겹칩니다!"];
            return;
        }
        [_dataManager saveLectureWithLectureName:_lectureDictionary[@"lectureName"]
                                           theme:[_lectureDictionary[@"theme"] integerValue]
                                  lectureDetails:_lectureDetails];
        [KVNProgress showSuccessWithStatus:@"강의 추가 성공!"];
    } else {
        [_dataManager updateLectureWithUlid:_ulidToEdit
                                       name:_lectureDictionary[@"lectureName"]
                                      theme:[_lectureDictionary[@"theme"] integerValue]
                             lectureDetails:_lectureDetails];
        [KVNProgress showSuccessWithStatus:@"강의 수정 성공!"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_ulidToEdit == -1)
        [self setTitle:@"강의 추가"];
    else
        [self setTitle:@"강의 수정"];
}

@end
