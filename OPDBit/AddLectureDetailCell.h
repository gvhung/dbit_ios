//
//  AddLectureDetailCell.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddLectureViewController.h"

@interface AddLectureDetailCell : UITableViewCell

@property (nonatomic) NSInteger lectureDetailIndex;
@property (nonatomic, strong) NSString *lectureLocation;
@property (nonatomic) NSInteger day;
@property (nonatomic) NSInteger timeStart;
@property (nonatomic) NSInteger timeEnd;

@property (nonatomic, strong) AddLectureViewController *delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
