//
//  SearchLectureViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "SearchLectureViewController.h"

#import <HMSegmentedControl/HMSegmentedControl.h>
#import <Masonry/Masonry.h>

@interface SearchLectureViewController ()

@property (nonatomic, retain) HMSegmentedControl *segmentedControl;

@end

@implementation SearchLectureViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegate = nil;
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *segmentedControlSectionTitles = @[@"강의명", @"과목코드", @"교수명"];
    _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:segmentedControlSectionTitles];
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentedControl.selectionIndicatorBoxOpacity = 0;
    [_segmentedControl addTarget:self
                          action:@selector(segmentedControlDidChanged:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_segmentedControl];
    
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
}

#pragma mark - Segmented Control Delegate

- (void)segmentedControlDidChanged:(HMSegmentedControl *)segmentedControl
{
    
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
