//
//  ServerSemesterViewController.h
//  OPDBit
//
//  Created by 1000732 on 2015. 8. 1..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerSemesterViewController;
@class ServerSemesterObject;

@protocol ServerSemesterViewControllerDelegate <NSObject>

- (void)serverSemesterViewController:(ServerSemesterViewController *)serverSemesterViewController
           didSelectedSemesterObject:(ServerSemesterObject *)semesterObject;

@end

@interface ServerSemesterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (weak, nonatomic) id<ServerSemesterViewControllerDelegate> delegate;

- (instancetype)init;

@end
