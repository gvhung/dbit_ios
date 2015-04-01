//
//  ShowTimeTableViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 2..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "ShowTimeTableViewController.h"
#import "TimeTableView.h"

#import <Masonry/Masonry.h>

@interface ShowTimeTableViewController ()

@property (nonatomic, strong) TimeTableView *timeTableView;

@end

@implementation ShowTimeTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        _timeTableView = [[TimeTableView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_timeTableView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
