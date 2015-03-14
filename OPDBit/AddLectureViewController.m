//
//  AddLectureViewController.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AddLectureViewController.h"
#import "SearchLectureViewController.h"

#import <Masonry/Masonry.h>

@interface AddLectureViewController ()

@end

@implementation AddLectureViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *searchLectureButton = [[UIBarButtonItem alloc] initWithTitle:@"찾기"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(searchLectureAction)];
    self.navigationItem.rightBarButtonItem = searchLectureButton;
    
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    
}

- (void)searchLectureAction
{
    SearchLectureViewController *searchLectureViewController = [[SearchLectureViewController alloc] init];
    searchLectureViewController.delegate = self;
    [self.navigationController pushViewController:searchLectureViewController animated:YES];
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
