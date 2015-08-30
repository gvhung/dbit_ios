//
//  ShowLectureViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 6. 18..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ShowLectureViewController.h"
#import "TimeTableView.h"
#import "DataManager.h"

@interface ShowLectureViewController ()

@property (strong, nonatomic) UIScrollView *scorllView;

@property (nonatomic, strong) TimeTableView *timeTableView;

@property (nonatomic, strong) DataManager *dataManager;

@end

@implementation ShowLectureViewController

#pragma mark - initialize

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _dataManager = [DataManager sharedInstance];
//        _timeTableView = [[TimeTableView alloc] initWithFrame:<#(CGRect)#> lectures:<#(NSArray *)#> sectionTitles:<#(NSArray *)#> timeStart:<#(NSInteger)#> timeEnd:<#(NSInteger)#>]
        
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    [self makeAutoLayoutContraints];
}

- (void)makeAutoLayoutContraints
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

@end
