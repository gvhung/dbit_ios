//
//  AddLectureHeaderCell.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AddLectureHeaderCell.h"

#import <Masonry/Masonry.h>

@interface AddLectureHeaderCell ()

@property (nonatomic, strong) UIView *separator;

@property (nonatomic, strong) UILabel *lectureNameLabel;
@property (nonatomic, strong) UILabel *lectureThemeLabel;

@property (nonatomic, strong) UITextField *lectureNameField;
@property (nonatomic, strong) UITextField *lectureThemeField;

@end

@implementation AddLectureHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _separator = [[UIView alloc] init];
        
        _lectureNameLabel = [[UILabel alloc] init];
        _lectureThemeLabel = [[UILabel alloc] init];
        
        _lectureNameField = [[UITextField alloc] init];
        _lectureThemeField = [[UITextField alloc] init];
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _separator.backgroundColor = [UIColor lightGrayColor];
    
    _lectureNameLabel.text = @"강의명";
    _lectureThemeLabel.text = @"테마";
    
    _lectureNameField.placeholder = @"강의명";
    _lectureNameField.backgroundColor = [UIColor clearColor];
    _lectureNameField.borderStyle = UITextBorderStyleNone;
    [_lectureNameField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _lectureNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _lectureNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _lectureNameField.tag = -1;
    [_lectureNameField addTarget:self.delegate action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    
    _lectureThemeField.placeholder = @"테마 (임시)";
    _lectureThemeField.backgroundColor = [UIColor clearColor];
    _lectureThemeField.borderStyle = UITextBorderStyleNone;
    [_lectureThemeField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _lectureThemeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _lectureThemeField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _lectureThemeField.tag = -2;
    [_lectureThemeField addTarget:self.delegate action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.contentView addSubview:_separator];
    
    [self.contentView addSubview:_lectureNameLabel];
    [self.contentView addSubview:_lectureThemeLabel];
    
    [self.contentView addSubview:_lectureNameField];
    [self.contentView addSubview:_lectureThemeField];
    
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    CGFloat padding = 10.0f;
    [_lectureNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(padding);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
    }];
    [_lectureNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lectureNameLabel.mas_bottom).with.offset(2.0f);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
    }];
    
    [_lectureThemeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lectureNameField.mas_bottom).with.offset(20.0f);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
    }];
    [_lectureThemeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lectureThemeLabel.mas_bottom).with.offset(2.0f);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
    }];
    
    [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).with.offset(1.0f);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@1.0f);
    }];
}

#pragma mark - Getter

- (void)setLectureName:(NSString *)lectureName
{
    _lectureNameField.text = lectureName;
}

- (void)setLectureTheme:(NSString *)lectureTheme
{
    _lectureThemeField.text = lectureTheme;
}

- (NSString *)lectureName
{
    return _lectureNameField.text;
}

- (NSString *)lectureTheme
{
    return _lectureThemeField.text;
}

@end
