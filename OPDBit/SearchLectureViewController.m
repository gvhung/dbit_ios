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

@interface SearchLectureViewController ()

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) UITextField *searchTextField;

@property (nonatomic, strong) NSArray *lectureResults;

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

#pragma mark - Setter

- (void)setServerLectures:(NSArray *)serverLectures
{
    _serverLectures = serverLectures;
    _lectureResults = serverLectures;
    [_tableView reloadData];
}

#pragma mark - Bar Button Action

- (void)selectServerLectureAction
{
    NSLog(@"%@", _lectureResults);
    [_tableView reloadData];
//    [self.navigationController popToViewController:self.delegate animated:YES];
}

#pragma mark - Getter

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
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

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
