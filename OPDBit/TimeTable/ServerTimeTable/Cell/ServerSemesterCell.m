//
//  ServerSemesterCell.m
//  OPDBit
//
//  Created by 1000732 on 2015. 8. 1..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

// View
#import "ServerSemesterCell.h"

// Utility
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

// Model
#import "ServerSemesterObject.h"

// Library
#import <Masonry/Masonry.h>


@interface ServerSemesterCell ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UILabel *semesterLabel;
@property (nonatomic, strong) UILabel *checkedAtLabel;

@property (nonatomic, strong) UIView *separatorView;

@end

@implementation ServerSemesterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _semesterLabel = [[UILabel alloc] init];
        _checkedAtLabel = [[UILabel alloc] init];
        
        _separatorView = [[UIView alloc] init];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _semesterLabel.textColor = [UIColor op_textPrimaryDark];
    _semesterLabel.font = [UIFont op_primary];
    
    _checkedAtLabel.textColor = [UIColor op_textSecondaryDark];
    _checkedAtLabel.font = [UIFont op_secondary];
    
    _separatorView.backgroundColor = [UIColor op_dividerDark];
    
    [self.contentView addSubview:_semesterLabel];
    [self.contentView addSubview:_checkedAtLabel];
    [self.contentView addSubview:_separatorView];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    CGFloat padding = 10.0f;
    CGFloat gap = 3.0f;
    CGFloat leftMargin = 15.0f;
    CGFloat separatorWidth = 0.5f;
    
    [_semesterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(leftMargin);
        make.top.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(padding);
    }];
    
    [_checkedAtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(leftMargin);
        make.top.equalTo(_semesterLabel.mas_bottom).with.offset(gap);
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

- (void)setServerSemester:(ServerSemesterObject *)serverSemester
{
    _serverSemester = serverSemester;

    _semesterLabel.text = serverSemester.semesterName;
    _checkedAtLabel.text = [NSString stringWithFormat:@"종합강의 시간표 %ld번째 버전", serverSemester.semesterVersion];
}

@end
