//
//  TimeTableCell.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeTableViewController.h"

@interface TimeTableCell : UITableViewCell

@property (nonatomic, strong) TimeTableViewController *delegate;
@property (nonatomic, strong) NSDictionary *timeTableDictionary;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
