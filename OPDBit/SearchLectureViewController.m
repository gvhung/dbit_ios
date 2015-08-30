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
#import "MZSnackBar.h"

// Utility
#import "DataManager.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

// Model
#import "ServerSemesterObject.h"
#import "ServerLectureObject.h"
#import "LectureObject.h"
#import "LectureDetailObject.h"

// Library
#import <HMSegmentedControl/HMSegmentedControl.h>
#import <Masonry/Masonry.h>

@interface SearchLectureViewController ()

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) UITextField *searchTextField;

@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) RLMArray *lectureResults;

@property (nonatomic, strong) ServerLectureObject *selectedServerLecture;

@property (strong, nonatomic) MZSnackBar *snackBar;

@end

@implementation SearchLectureViewController

static CGFloat const rowHeight = 80.0f;

- (instancetype)initWithLecture:(LectureObject *)lecture
{
    self = [super init];
    if (self) {
        _lectureResults = [[RLMArray alloc] initWithObjectClassName:ServerLectureObjectID];
        _segmentedControl = [[HMSegmentedControl alloc] init];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _searchTextField = [[UITextField alloc] init];
        _emptyLabel = [[UILabel alloc] init];
        
        _currentLecture = lecture;
        
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
    [_searchTextField addTarget:self
                         action:@selector(textFieldDidChange:)
               forControlEvents:UIControlEventEditingChanged];
    
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
        
        if (!_snackBar) {
            _snackBar = [[MZSnackBar alloc] initWithFrame:self.view.bounds];
        }
        _snackBar.message = @"강의를 선택해주세요!";
        [_snackBar animateToAppearInView:self.view];
        return;
    }
    
    [_currentLecture lectureFromServerLecture:_selectedServerLecture];
    
    if ([_delegate respondsToSelector:@selector(searchLectureViewController:didDoneWithLectureObject:)]) {
        [_delegate searchLectureViewController:self didDoneWithLectureObject:_currentLecture];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setter

- (void)setServerSemester:(ServerSemesterObject *)serverSemester
{
    _serverSemester = serverSemester;
    _lectureResults = serverSemester.serverLectures;
    
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

- (NSPredicate *)predicateWithString:(NSString *)searchString
{
//    searchString = [NSString stringWithFormat:@"*%@*", searchString];
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
            return [NSPredicate predicateWithFormat:@"%K CONTAINS %@", @"lectureName", searchString];
        case 1:
            return [NSPredicate predicateWithFormat:@"%K CONTAINS %@", @"lectureKey", searchString];
        case 2:
            return [NSPredicate predicateWithFormat:@"%K CONTAINS %@", @"lectureProf", searchString];
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
    
    cell.serverLecture = _lectureResults[indexPath.row];
    
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
    NSString *keyword = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"%@", keyword);
    
    if(keyword.length == 0) {
        _lectureResults = _serverSemester.serverLectures;
        [self hideTableView:[self lectureResultsAreEmpty]];
    }
    else {
        NSPredicate *predicate = [self predicateWithString:keyword];
        RLMResults *searchResults = [_serverSemester.serverLectures objectsWithPredicate:predicate];
        _lectureResults = [DataManager realmArrayFromResult:searchResults className:ServerLectureObjectID];
        [self hideTableView:[self lectureResultsAreEmpty]];
    }
    
    [_tableView reloadData];
}

#pragma mark - Segmented Control Delegate

- (void)segmentedControlDidChange:(HMSegmentedControl *)segmentedControl
{
    _tableView.contentOffset = CGPointMake(0, 0);
    _searchTextField.text = @"";
    _lectureResults = _serverSemester.serverLectures;
    
    [self hideTableView:[self lectureResultsAreEmpty]];
    [_tableView reloadData];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedServerLecture = _lectureResults[indexPath.row];
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
