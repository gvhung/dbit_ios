//
//  LectureViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "LectureViewController.h"
#import "LectureTableViewCell.h"
#import "AddLectureViewController.h"

#import <Masonry/Masonry.h>

@interface LectureViewController ()

@end

@implementation LectureViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setTitle:@"강의"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *addLectureButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLectureAction)];
    self.navigationItem.rightBarButtonItem = addLectureButton;
    
    _lectureTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_lectureTableView registerClass:[LectureTableViewCell class] forCellReuseIdentifier:@"LectureCell"];
    _lectureTableView.delegate = self;
    _lectureTableView.dataSource = self;
    
    NSArray *segmentedAttributes = @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"];
    _daySegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:segmentedAttributes];
    _daySegmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    _daySegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _daySegmentedControl.selectionIndicatorBoxOpacity = 0;
    [_daySegmentedControl addTarget:self
                             action:@selector(changeDay:)
                   forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_daySegmentedControl];
    [self.view addSubview:_lectureTableView];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_daySegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view).with.offset(64.0f);
        make.height.equalTo(@60);
    }];
    [_lectureTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(_daySegmentedControl.mas_bottom);
    }];
}

- (void)addLectureAction
{
    AddLectureViewController *addLectureViewController = [[AddLectureViewController alloc] init];
    [self.navigationController pushViewController:addLectureViewController animated:YES];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LectureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LectureCell"];
    if (!cell)
        cell = [[LectureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LectureCell"];
    return cell;
}

#pragma mark - Segmented Control Delegate

- (void)changeDay:(HMSegmentedControl *)segmentedControl
{
    NSLog(@"%ld", segmentedControl.selectedSegmentIndex);
}


- (void)viewDidLoad
{
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
