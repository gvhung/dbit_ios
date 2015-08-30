//
//  OPLeftDrawerViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPLeftDrawerViewController;

@protocol OPLeftDrawerViewControllerDelegate <NSObject>

- (void)leftDrawerViewController:(OPLeftDrawerViewController *)viewController didFailedToTransitionWithMessage:(NSString *)message;

@end

@interface OPLeftDrawerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<OPLeftDrawerViewControllerDelegate> delegate;

@property (nonatomic, strong) UITableView *tableView;

- (instancetype)init;

@end
