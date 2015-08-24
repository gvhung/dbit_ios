//
//  LectureTableViewCell.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class LectureObject;
@class LectureDetailObject;

#import <UIKit/UIKit.h>

@interface LectureTableViewCell : UITableViewCell

@property (nonatomic, strong) LectureObject *lecture;
@property (nonatomic, strong) LectureDetailObject *lectureDetail;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
