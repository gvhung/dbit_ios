//
//  TimeTableCell.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "TimeTableCell.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"
#import "DataManager.h"

#import <Masonry/Masonry.h>

@interface TimeTableCell ()

@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) UIImageView *switchImageView;

@property (nonatomic, strong) UILabel *timeTableNameLabel;
@property (nonatomic, strong) UILabel *serverTimeTableNameLabel;
@property (nonatomic, strong) UILabel *subLabel;

@property (nonatomic, strong) UIView *separatorView;

@end

@implementation TimeTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _dataManager = [DataManager sharedInstance];
        
        _timeTableDictionary = [[NSDictionary alloc] init];
        
        _switchImageView = [[UIImageView alloc] init];
        
        _timeTableNameLabel = [[UILabel alloc] init];
        _serverTimeTableNameLabel = [[UILabel alloc] init];
        _subLabel = [[UILabel alloc] init];
        
        _separatorView = [[UIView alloc] init];
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _timeTableNameLabel.textColor = [UIColor op_textPrimaryDark];
    _timeTableNameLabel.font = [UIFont op_primary];
    
    _serverTimeTableNameLabel.textColor = [UIColor op_textSecondaryDark];
    _serverTimeTableNameLabel.font = [UIFont op_secondary];
    
    _subLabel.textColor = [UIColor op_textSecondaryDark];
    _subLabel.font = [UIFont op_secondary];
    
    _separatorView.backgroundColor = [UIColor op_dividerDark];
    
    [self.contentView addSubview:_switchImageView];
    [self.contentView addSubview:_timeTableNameLabel];
    [self.contentView addSubview:_serverTimeTableNameLabel];
    [self.contentView addSubview:_subLabel];
    [self.contentView addSubview:_separatorView];
    
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    CGFloat imageViewMargin = 15.0f;
    CGFloat padding = 10.0f;
    CGFloat gap = 3.0f;
    CGFloat switchImageViewWidth = 10.0f;
    CGFloat leftMargin = imageViewMargin + switchImageViewWidth + imageViewMargin;
    
    [_switchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(imageViewMargin);
        make.width.equalTo(@(switchImageViewWidth));
        
        make.height.equalTo(@(switchImageViewWidth));
        make.centerY.equalTo(self.contentView);
    }];
    [_timeTableNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(leftMargin);
        make.top.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(padding);
    }];
    [_serverTimeTableNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(leftMargin);
        make.top.equalTo(_timeTableNameLabel.mas_bottom).with.offset(gap);
        make.right.equalTo(self.contentView).with.offset(padding);
    }];
    [_subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(leftMargin);
        make.top.equalTo(_serverTimeTableNameLabel.mas_bottom).with.offset(gap);
        make.right.equalTo(self.contentView).with.offset(padding);
    }];
    [_separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).with.offset(-0.5f);
        make.left.equalTo(self.contentView).with.offset(15.0f);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@0.5f);
    }];
}

#pragma mark - Setter

- (void)setTimeTableDictionary:(NSDictionary *)timeTableDictionary
{
    _timeTableDictionary = timeTableDictionary;
    
    UIImage *switchImage = ([timeTableDictionary[@"active"] integerValue]) ? [UIImage imageNamed:@"on.png"] : [UIImage imageNamed:@"off.png"];
    _switchImageView.image = switchImage;
    
    _timeTableNameLabel.text = timeTableDictionary[@"timeTableName"];
    if ([timeTableDictionary[@"serverId"] integerValue] == -1) {
        _serverTimeTableNameLabel.text = @"서버 연동 시간표가 없습니다.";
    }
    _subLabel.text = ([timeTableDictionary[@"active"] integerValue]) ? @"기본 시간표" : @"활성화 되지 않은 시간표";
}

@end