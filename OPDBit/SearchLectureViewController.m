//
//  SearchLectureViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

// Controller
#import "SearchLectureViewController.h"

// View
#import "SearchLectureCell.h"

// Utility
#import "DataManager.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

// Model
#import "ServerSemesterObject.h"
#import "ServerLectureObject.h"

// Library
#import <HMSegmentedControl/HMSegmentedControl.h>
#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface SearchLectureViewController () <UITextFieldDelegate>

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) UITextField *searchTextField;

@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) RLMArray *lectureResults;

@property (nonatomic, strong) ServerLectureObject *selectedServerLecture;

@end

@implementation SearchLectureViewController

static CGFloat const rowHeight = 80.0f;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lectureResults = [[RLMArray alloc] initWithObjectClassName:ServerLectureObjectID];
        _segmentedControl = [[HMSegmentedControl alloc] init];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _searchTextField = [[UITextField alloc] init];
        _emptyLabel = [[UILabel alloc] init];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *segmentedControlSectionTitles = @[@"강의명", @"학수번호", @"교수명"];
    _segmentedControl.sectionTitles = segmentedControlSectionTitles;
    _segmentedControl.borderType = HMSegmentedControlBorderTypeBottom;
    _segmentedControl.borderColor = [UIColor op_dividerDark];
    _segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor op_textSecondaryDark],
                                                 NSFontAttributeName : [UIFont op_primary]};
    _segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor op_textPrimaryDark],
                                                         NSFontAttributeName : [UIFont op_primary]};
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentedControl.selectionIndicatorBoxOpacity = 0;
    _segmentedControl.selectionIndicatorColor = [UIColor op_primary];
    _segmentedControl.selectionIndicatorHeight = 2.0f;
    
    [_segmentedControl addTarget:self
                          action:@selector(segmentedControlDidChange:)
                forControlEvents:UIControlEventValueChanged];
    
    [_tableView registerClass:[SearchLectureCell class] forCellReuseIdentifier:@"SearchLectureCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = rowHeight;
    _tableView.separatorColor = [UIColor op_dividerDark];
    
    _emptyLabel.text = @"검색결과가 없습니다! :D";
    _emptyLabel.textColor = [UIColor op_textPrimaryDark];
    _emptyLabel.font = [UIFont op_title];
    
    UIBarButtonItem *selectServerLectureButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(selectServerLectureAction)];
    _searchTextField.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    _searchTextField.center = CGPointMake(self.view.center.x, 22);
    
    _searchTextField.placeholder = @"강의 검색";
    _searchTextField.backgroundColor = [UIColor clearColor];
    _searchTextField.borderStyle = UITextBorderStyleNone;
    _searchTextField.textColor = [UIColor op_textPrimary];
    _searchTextField.tintColor = [UIColor op_textSecondary];
    _searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_searchTextField.placeholder
                                                                             attributes:@{NSForegroundColorAttributeName: [UIColor op_textSecondary]}];
    _searchTextField.font = [UIFont op_title];
    [_searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _searchTextField.delegate = self;
    
    self.navigationItem.titleView = _searchTextField;
    self.navigationItem.rightBarButtonItem = selectServerLectureButton;
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_segmentedControl];
    [self.view addSubview:_emptyLabel];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    CGFloat segmentedControlHeight = 45.0f;
    [_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(segmentedControlHeight));
    }];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(segmentedControlHeight,0,0,0));
    }];
    [_emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

#pragma mark - Bar Button Action

- (void)selectServerLectureAction
{
    if (!_selectedServerLecture) {
        [_searchTextField resignFirstResponder];
        [KVNProgress showErrorWithStatus:@"강의를 선택해주세요!"];
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(searchLectureViewController:didDoneWithServerLectureObject:)]) {
        [_delegate searchLectureViewController:self didDoneWithServerLectureObject:_selectedServerLecture];
    }
//    self.delegate.serverLectureDictionary = [self getConvertedDictionaryWithDictionary:_selectedLectureDictionary];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setter

- (void)setServerLectures:(NSArray *)serverLectures
{
    _serverLectures = serverLectures;
    _lectureResults = serverLectures;
    [self hideTableView:[self lectureResultsAreEmpty]];
    [_tableView reloadData];
}

- (void)setServerSemester:(ServerSemesterObject *)serverSemester
{
    _serverSemester = serverSemester;
}

- (void)setLectureResults:(NSArray *)lectureResults
{
    _lectureResults = lectureResults;
    [self hideTableView:[self lectureResultsAreEmpty]];
    [_tableView reloadData];
}

#pragma mark - Instance Method

- (BOOL)lectureResultsAreEmpty
{
    return !_lectureResults.count;
}

- (void)hideTableView:(BOOL)hide
{
    _tableView.hidden = hide;
    _emptyLabel.hidden = !hide;
    
    if (!hide) [_tableView reloadData];
}

#pragma mark - Getter

- (NSDictionary *)getConvertedDictionaryWithDictionary:(NSDictionary *)dictionary
{
    NSInteger detailCount = 0;
    
    NSMutableDictionary *convertedDictionary = [[NSMutableDictionary alloc] init];
    convertedDictionary[@"lectureName"] = dictionary[@"lectureName"];
    NSMutableArray *lectureDetailArray = [[NSMutableArray alloc] init];
    
    // ,로 Location 을 나눌경우 생기는 에러 (ex. 405-250(원흥관 1,3 E250 강의실))
    NSArray *lectureLocationArray = [dictionary[@"lectureLocation"] componentsSeparatedByString:@"),"];
    for (NSInteger i = 0; i < lectureLocationArray.count; i++) {
        NSString *lectureLocationString = lectureLocationArray[i];
        if (i < lectureLocationArray.count-1) {
            NSString *convertedString = [lectureLocationString stringByAppendingString:@")"];
            [(NSMutableArray *)lectureLocationArray replaceObjectAtIndex:i withObject:convertedString];
        }
    }

    
    NSArray *lectureDaytimeArray = [dictionary[@"lectureDaytime"] componentsSeparatedByString:@","];
    detailCount = lectureLocationArray.count;
    if (lectureLocationArray.count != lectureDaytimeArray.count)
        if (lectureDaytimeArray.count >= detailCount)
            detailCount = lectureDaytimeArray.count;
    
    for (NSInteger i = 0; i < detailCount; i++) {
        NSMutableDictionary *lectureDetailDictionary = [[NSMutableDictionary alloc] init];
        lectureDetailDictionary[@"lectureLocation"] = (lectureLocationArray[i] == nil) ? @"" : lectureLocationArray[i];
        lectureDetailDictionary[@"timeStart"] =
        (lectureDaytimeArray.count < i+1) ? @"" : [self timeStartWithString:lectureDaytimeArray[i]];
        lectureDetailDictionary[@"timeEnd"] =
        (lectureDaytimeArray.count < i+1) ? @"" : [self timeEndWithString:lectureDaytimeArray[i]];
        lectureDetailDictionary[@"day"] =
        (lectureDaytimeArray.count < i+1) ? @"0" : [self dayWithString:lectureDaytimeArray[i]];
        [lectureDetailArray addObject:lectureDetailDictionary];
    }
    convertedDictionary[@"lectureDetails"] = lectureDetailArray;
    
    return convertedDictionary;
}

- (NSNumber *)dayWithString:(NSString *)string
{
    NSString *pureDaytimeString = [string substringToIndex:1];
    NSArray *dayStringArray = @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"];
    NSInteger dayInteger = 0;
    for (NSString *dayString in dayStringArray)
        if ([dayString isEqualToString:pureDaytimeString])
            dayInteger = [dayStringArray indexOfObject:dayString];
    return @(dayInteger);
}

- (NSNumber *)timeStartWithString:(NSString *)string
{
    NSString *pureDaytimeString = [string componentsSeparatedByString:@"/"][1];
    NSString *timeStartString = [pureDaytimeString componentsSeparatedByString:@"-"][0];
    return @([DataManager integerFromTimeString:timeStartString]);
}

- (NSNumber *)timeEndWithString:(NSString *)string
{
    NSString *pureDaytimeString = [string componentsSeparatedByString:@"/"][1];
    NSString *timeEndString = [pureDaytimeString componentsSeparatedByString:@"-"][1];
    return @([DataManager integerFromTimeString:timeEndString]);
}

- (NSPredicate *)getPredicateWithString:(NSString *)searchString
{
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
            return [NSPredicate predicateWithFormat:@"lectureName CONTAINS[cd] %@", searchString];
        case 1:
            return [NSPredicate predicateWithFormat:@"lectureCode CONTAINS[cd] %@", searchString];
        case 2:
            return [NSPredicate predicateWithFormat:@"lectureProf CONTAINS[cd] %@", searchString];
        default:
            return [NSPredicate predicateWithFormat:@""];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _lectureResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchLectureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchLectureCell" forIndexPath:indexPath];
    if (!cell)
        cell = [[SearchLectureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchLectureCell"];
    cell.serverLectureDictionary = _lectureResults[indexPath.row];
    
    return cell;
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchTextField resignFirstResponder];
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.text.length == 0)
        self.lectureResults = _serverSemester.serverLectures;
    else
    {
#warning 검색 로직
//        NSMutableArray *searchArray = [NSMutableArray arrayWithArray:_serverLectures];
//        NSPredicate *predicate = [self getPredicateWithString:textField.text];
//        self.lectureResults = [NSMutableArray arrayWithArray:[searchArray filteredArrayUsingPredicate:predicate]];
    }
    
    [_tableView reloadData];
    
    return YES;
}

#pragma mark - Segmented Control Delegate

- (void)segmentedControlDidChange:(HMSegmentedControl *)segmentedControl
{
    _tableView.contentOffset = CGPointMake(0, 0);
    _searchTextField.text = @"";
    self.lectureResults = _serverLectures;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedLectureDictionary = _lectureResults[indexPath.row];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_searchTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_searchTextField resignFirstResponder];
}

@end
