//
//  DownloadServerTimeTableViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadServerTimeTableViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) UIButton *schoolButton;
@property (nonatomic, strong) UIButton *timeTableButton;

- (instancetype)init;

@end
