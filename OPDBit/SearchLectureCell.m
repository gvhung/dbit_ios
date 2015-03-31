//
//  SearchLectureCell.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "SearchLectureCell.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

#import <Masonry/Masonry.h>

@implementation SearchLectureCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _lectureTitleLabel = [[UILabel alloc] init];
        _lectureCodeLabel = [[UILabel alloc] init];
        _lectureLocationLabel = [[UILabel alloc] init];
        _lectureTimeLabel = [[UILabel alloc] init];
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _lectureTitleLabel.textColor = [UIColor op_textPrimaryDark];
    _lectureTitleLabel.font = [UIFont op_primary];
    
    _lectureCodeLabel.textColor = [UIColor op_textSecondaryDark];
    _lectureCodeLabel.font = [UIFont op_secondary];
    
    _lectureLocationLabel.textColor = [UIColor op_textSecondaryDark];
    _lectureLocationLabel.font = [UIFont op_secondary];
    
    _lectureTimeLabel.textColor = [UIColor op_textSecondaryDark];
    _lectureTimeLabel.font = [UIFont op_secondary];
    
    [self.contentView addSubview:_lectureTitleLabel];
    [self.contentView addSubview:_lectureCodeLabel];
    [self.contentView addSubview:_lectureLocationLabel];
    [self.contentView addSubview:_lectureTimeLabel];
    
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    CGFloat leftAndRightPadding = 15.0f;
    [_lectureTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(5.0f);
        make.left.equalTo(self.contentView.mas_left).with.offset(leftAndRightPadding);
        make.right.equalTo(self.contentView.mas_right).with.offset(-leftAndRightPadding);
    }];
    [_lectureCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lectureTitleLabel.mas_bottom).with.offset(3.0f);
        make.left.equalTo(self.contentView.mas_left).with.offset(leftAndRightPadding);
        make.right.equalTo(self.contentView.mas_right).with.offset(-leftAndRightPadding);
    }];
    [_lectureLocationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lectureCodeLabel.mas_bottom).with.offset(1.0f);
        make.left.equalTo(self.contentView.mas_left).with.offset(leftAndRightPadding);
        make.right.equalTo(self.contentView.mas_right).with.offset(-leftAndRightPadding);
    }];
    [_lectureTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lectureLocationLabel.mas_bottom).with.offset(1.0f);
        make.left.equalTo(self.contentView).with.offset(leftAndRightPadding);
        make.right.equalTo(self.contentView).with.offset(-leftAndRightPadding);
    }];
}

- (void)setServerLectureDictionary:(NSDictionary *)serverLectureDictionary
{
    _serverLectureDictionary = serverLectureDictionary;
    [self reloadLabels];
}

- (void)reloadLabels
{
    _lectureTitleLabel.text = [self getTitleStringWithServerLectureDictionary:_serverLectureDictionary];
    _lectureCodeLabel.text = _serverLectureDictionary[@"lectureCode"];
    _lectureLocationLabel.text = _serverLectureDictionary[@"lectureLocation"];
    _lectureTimeLabel.text = _serverLectureDictionary[@"lectureDaytime"];
}

- (NSString *)getTitleStringWithServerLectureDictionary:(NSDictionary *)serverLectureDictionary
{
    return [NSString stringWithFormat:@"%@ (%@)", serverLectureDictionary[@"lectureName"], serverLectureDictionary[@"lectureProf"]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _lectureTitleLabel.text = @"";
    _lectureCodeLabel.text = @"";
    _lectureLocationLabel.text = @"";
    _lectureTimeLabel.text = @"";
}

@end
