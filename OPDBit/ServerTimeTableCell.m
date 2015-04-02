//
//  ServerTimeTableCell.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "ServerTimeTableCell.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"
#import "DataManager.h"

#import <Masonry/Masonry.h>

@interface ServerTimeTableCell ()

@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UIImageView *switchImageView;

@property (nonatomic, strong) UILabel *semesterLabel;
@property (nonatomic, strong) UILabel *schoolNameLabel;
@property (nonatomic, strong) UILabel *checkedAtLabel;

@property (nonatomic, strong) UIView *separatorView;

@end

@implementation ServerTimeTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _dataManager = [DataManager sharedInstance];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        _serverTimeTable = [[NSDictionary alloc] init];
        
        _switchImageView = [[UIImageView alloc] init];
        
        _semesterLabel = [[UILabel alloc] init];
        _schoolNameLabel = [[UILabel alloc] init];
        _checkedAtLabel = [[UILabel alloc] init];
        
        _separatorView = [[UIView alloc] init];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [_dateFormatter setDateFormat:@"yyyy. M. d. HH:mm"];
    
    _semesterLabel.textColor = [UIColor op_textPrimaryDark];
    _semesterLabel.font = [UIFont op_primary];
    
    _schoolNameLabel.textColor = [UIColor op_textSecondaryDark];
    _schoolNameLabel.font = [UIFont op_secondary];
    
    _checkedAtLabel.textColor = [UIColor op_textSecondaryDark];
    _checkedAtLabel.font = [UIFont op_secondary];
    
    _separatorView.backgroundColor = [UIColor op_dividerDark];
    
    [self.contentView addSubview:_switchImageView];
    [self.contentView addSubview:_semesterLabel];
    [self.contentView addSubview:_schoolNameLabel];
    [self.contentView addSubview:_checkedAtLabel];
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
    CGFloat separatorWidth = 0.5f;
    
    [_switchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(imageViewMargin);
        make.width.equalTo(@(switchImageViewWidth));
        
        make.height.equalTo(@(switchImageViewWidth));
        make.centerY.equalTo(self.contentView);
    }];
    [_semesterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(leftMargin);
        make.top.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(padding);
    }];
    [_schoolNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(leftMargin);
        make.top.equalTo(_semesterLabel.mas_bottom).with.offset(gap);
        make.right.equalTo(self.contentView).with.offset(padding);
    }];
    [_checkedAtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(leftMargin);
        make.top.equalTo(_schoolNameLabel.mas_bottom).with.offset(gap);
        make.right.equalTo(self.contentView).with.offset(padding);
    }];
    
    [_separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).with.offset(-separatorWidth);
        make.height.equalTo(@(separatorWidth));
    }];
}

#pragma mark - Setter

- (void)setServerTimeTable:(NSDictionary *)serverTimeTable
{
    _serverTimeTable = serverTimeTable;
    _switchImageView.image = ([serverTimeTable[@"downloaded"] integerValue]) ? [UIImage imageNamed:@"on.png"] : [UIImage imageNamed:@"off.png"];
    _schoolNameLabel.text = [_dataManager schoolNameWithServerTimeTableId:[serverTimeTable[@"timeTableId"] integerValue]];
    _semesterLabel.text = [_dataManager semesterString:serverTimeTable[@"semester"]];
    _checkedAtLabel.text = [NSString stringWithFormat:@"최종 확인 : %@", [_dateFormatter stringFromDate:serverTimeTable[@"checkedAt"]]];
}

@end
