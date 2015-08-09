//
//  SearchLectureCell.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class ServerLectureObject;

#import <UIKit/UIKit.h>

@interface SearchLectureCell : UITableViewCell

@property (nonatomic, strong) ServerLectureObject *serverLecture;

@property (nonatomic, strong) UILabel *lectureTitleLabel;
@property (nonatomic, strong) UILabel *lectureCodeLabel;
@property (nonatomic, strong) UILabel *lectureLocationLabel;
@property (nonatomic, strong) UILabel *lectureTimeLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
