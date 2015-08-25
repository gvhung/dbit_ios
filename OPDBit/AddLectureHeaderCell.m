//
//  AddLectureHeaderCell.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AddLectureHeaderCell.h"
#import "DataManager.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

#import <Masonry/Masonry.h>
#import <HMSegmentedControl/HMSegmentedControl.h>

@interface AddLectureHeaderCell () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *separator;

@property (nonatomic, strong) UILabel *lectureNameLabel;
@property (nonatomic, strong) UILabel *lectureThemeLabel;

@property (nonatomic, strong) UITextField *lectureNameField;
@property (nonatomic, strong) HMSegmentedControl *lectureThemeSegmentedControl;

@end

@implementation AddLectureHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _lectureTheme = 0;
        
        NSArray *thumbnailArray = [DataManager lectureThemeThumbnailArray];

        _separator = [[UIView alloc] init];
        
        _lectureNameLabel = [[UILabel alloc] init];
        _lectureThemeLabel = [[UILabel alloc] init];
        
        _lectureNameField = [[UITextField alloc] init];
        _lectureThemeSegmentedControl = [[HMSegmentedControl alloc] initWithSectionImages:thumbnailArray sectionSelectedImages:thumbnailArray];
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _separator.backgroundColor = [UIColor op_dividerDark];
    
    _lectureNameLabel.text = @"강의명";
    _lectureNameLabel.textColor = [UIColor op_textSecondaryDark];
    _lectureNameLabel.font = [UIFont op_secondary];
    
    _lectureThemeLabel.text = @"테마";
    _lectureThemeLabel.textColor = [UIColor op_textSecondaryDark];
    _lectureThemeLabel.font = [UIFont op_secondary];
    
    _lectureNameField.placeholder = @"강의명";
    _lectureNameField.font = [UIFont op_title];
    _lectureNameField.textColor = [UIColor op_textPrimaryDark];
    _lectureNameField.backgroundColor = [UIColor clearColor];
    _lectureNameField.borderStyle = UITextBorderStyleNone;
    [_lectureNameField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _lectureNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _lectureNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _lectureNameField.tag = -1;
    _lectureNameField.delegate = self;
    
    _lectureThemeSegmentedControl.borderColor = [UIColor op_dividerDark];
    _lectureThemeSegmentedControl.selectionIndicatorColor = [UIColor op_primary];
    _lectureThemeSegmentedControl.selectionIndicatorHeight = 2.0f;
    _lectureThemeSegmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    _lectureThemeSegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _lectureThemeSegmentedControl.selectionIndicatorBoxOpacity = 0;
    _lectureThemeSegmentedControl.tag = -1;
    [_lectureThemeSegmentedControl addTarget:self
                                      action:@selector(segmentedControlDidChanged:)
                            forControlEvents:UIControlEventValueChanged];
    
    [self.contentView addSubview:_separator];
    
    [self.contentView addSubview:_lectureNameLabel];
    [self.contentView addSubview:_lectureThemeLabel];
    
    [self.contentView addSubview:_lectureNameField];
    [self.contentView addSubview:_lectureThemeSegmentedControl];
    
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    CGFloat padding = 15.0f;
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
    [_lectureThemeSegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lectureThemeLabel.mas_bottom).with.offset(2.0f);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
        make.height.equalTo(@40.0f);
    }];

    [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).with.offset(-0.5f);
        make.left.equalTo(self.contentView).with.offset(15.0f);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@0.5f);
    }];
}

- (void)drawRect:(CGRect)rect
{
    [_lectureThemeSegmentedControl setSelectedSegmentIndex:_lectureTheme animated:NO];
}

#pragma mark - Text Field Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([_delegate respondsToSelector:@selector(addLectureHeaderCell:didChangedName:)]) {
        [_delegate addLectureHeaderCell:self didChangedName:textField.text];
    }
}

#pragma mark - Segmented Control Delegate

- (void)segmentedControlDidChanged:(HMSegmentedControl *)segmentedControl
{
    if ([_delegate respondsToSelector:@selector(addLectureHeaderCell:didChangedTheme:)]) {
        [_delegate addLectureHeaderCell:self didChangedTheme:segmentedControl.selectedSegmentIndex];
    }
}

#pragma mark - Getter

- (void)setLectureName:(NSString *)lectureName
{
    _lectureName = lectureName;
    _lectureNameField.text = lectureName;
}

- (void)setLectureTheme:(NSInteger)lectureTheme
{
    _lectureTheme = lectureTheme;
    _lectureThemeSegmentedControl.selectedSegmentIndex = lectureTheme;
}

@end
