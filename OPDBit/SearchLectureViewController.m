//
//  SearchLectureViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "SearchLectureViewController.h"
#import "SearchLectureCell.h"

#import <HMSegmentedControl/HMSegmentedControl.h>
#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>

@interface SearchLectureViewController ()

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) UITextField *searchTextField;

@property (nonatomic, strong) NSArray *lectureResults;

@property (nonatomic, strong) NSDictionary *selectedLectureDictionary;

@end

@implementation SearchLectureViewController

static CGFloat const rowHeight = 105.0f;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lectureResults = [[NSArray alloc] init];
        _delegate = nil;
        _segmentedControl = [[HMSegmentedControl alloc] init];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _searchTextField = [[UITextField alloc] init];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *segmentedControlSectionTitles = @[@"강의명", @"과목코드", @"교수명"];
    _segmentedControl.sectionTitles = segmentedControlSectionTitles;
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentedControl.selectionIndicatorBoxOpacity = 0;
    [_segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
    
    [_tableView registerClass:[SearchLectureCell class] forCellReuseIdentifier:@"SearchLectureCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = rowHeight;
    
    UIBarButtonItem *selectServerLectureButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectServerLectureAction)];
    
    _searchTextField.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    _searchTextField.center = CGPointMake(self.view.center.x, 22);
    
    _searchTextField.placeholder = @"강의 검색";
    _searchTextField.backgroundColor = [UIColor clearColor];
    _searchTextField.borderStyle = UITextBorderStyleNone;
    [_searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.navigationItem.titleView = _searchTextField;
    self.navigationItem.rightBarButtonItem = selectServerLectureButton;
    
    [self.view addSubview:_segmentedControl];
    [self.view addSubview:_tableView];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@64.0f);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@60.0f);
    }];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_segmentedControl.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - Bar Button Action

- (void)selectServerLectureAction
{
    if (_selectedLectureDictionary == nil) {
        [_searchTextField resignFirstResponder];
        [KVNProgress showErrorWithStatus:@"강의를 선택해주세요!"];
        return;
    }
    self.delegate.lectureDictionary = [self getConvertedDictionaryWithDictionary:_selectedLectureDictionary];
    [self.navigationController popToViewController:self.delegate animated:YES];
}

#pragma mark - Setter

- (void)setServerLectures:(NSArray *)serverLectures
{
    _serverLectures = serverLectures;
    _lectureResults = serverLectures;
    [_tableView reloadData];
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
    return @([self integerFromTimeString:timeStartString]);
}

- (NSNumber *)timeEndWithString:(NSString *)string
{
    NSString *pureDaytimeString = [string componentsSeparatedByString:@"/"][1];
    NSString *timeEndString = [pureDaytimeString componentsSeparatedByString:@"-"][1];
    return @([self integerFromTimeString:timeEndString]);
}

- (NSString *)stringFromTimeInteger:(NSInteger)timeInteger
{
    NSInteger hours = timeInteger/100;
    NSInteger minutes = timeInteger%100;
    return [NSString stringWithFormat:@"%ld:%02ld", hours, minutes];
}

- (NSInteger)integerFromTimeString:(NSString *)timeString
{
    NSArray *timeStringComponents = [timeString componentsSeparatedByString:@":"];
    NSInteger hours = [timeStringComponents[0] integerValue];
    NSInteger minutes = [timeStringComponents[1] integerValue];
    return hours*100 + minutes;
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

- (void)textFieldDidChange:(UITextField *)textField
{
    if(textField.text.length == 0)
        _lectureResults = _serverLectures;
    else
    {
        NSMutableArray *searchArray = [NSMutableArray arrayWithArray:_serverLectures];
        NSPredicate *predicate = [self getPredicateWithString:textField.text];
        _lectureResults = [NSMutableArray arrayWithArray:[searchArray filteredArrayUsingPredicate:predicate]];
    }
    
    [_tableView reloadData];
}

#pragma mark - Segmented Control Delegate

- (void)segmentedControlDidChange:(HMSegmentedControl *)segmentedControl
{
    _tableView.contentOffset = CGPointMake(0, 0);
    _searchTextField.text = @"";
    _lectureResults = _serverLectures;
    [_tableView reloadData];
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
