//
//  DownloadServerTimeTableViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadServerTimeTableViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, retain) UIButton *schoolButton;
@property (nonatomic, retain) UIButton *timeTableButton;

- (instancetype)init;

@end
