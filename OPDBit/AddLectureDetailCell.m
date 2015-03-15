//
//  AddLectureDetailCell.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AddLectureDetailCell.h"

#import <Masonry/Masonry.h>
#import <HMSegmentedControl/HMSegmentedControl.h>

@interface AddLectureDetailCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *lectureLocationLabel;
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *timeStartLabel;
@property (nonatomic, strong) UILabel *timeEndLabel;

@property (nonatomic, strong) UITextField *lectureLocationField;
@property (nonatomic, strong) HMSegmentedControl *daySegmentedControl;
@property (nonatomic, strong) UIButton *timeStartButton;
@property (nonatomic, strong) UIButton *timeEndButton;

@property (nonatomic, strong) UIView *separator;

@end

@implementation AddLectureDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _lectureLocationLabel = [[UILabel alloc] init];
        _dayLabel = [[UILabel alloc] init];
        _timeStartLabel = [[UILabel alloc] init];
        _timeEndLabel = [[UILabel alloc] init];
        
        _lectureLocationField = [[UITextField alloc] init];
        _daySegmentedControl = [[HMSegmentedControl alloc] init];
        _timeStartButton = [[UIButton alloc] init];
        _timeEndButton = [[UIButton alloc] init];
        
        _separator = [[UIView alloc] init];
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _titleLabel.text = [self titleString];
    
    _lectureLocationLabel.text = @"강의실";
    _dayLabel.text = @"수업일";
    _timeStartLabel.text = @"시작시간";
    _timeEndLabel.text = @"종료시간";
    
    _lectureLocationField.placeholder = @"강의실";
    _lectureLocationField.backgroundColor = [UIColor clearColor];
    _lectureLocationField.borderStyle = UITextBorderStyleNone;
    [_lectureLocationField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _lectureLocationField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _lectureLocationField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_lectureLocationField addTarget:self.delegate
                              action:@selector(textFieldDidChanged:)
                    forControlEvents:UIControlEventEditingChanged];
    
    
    NSArray *sectionTitles = @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"];
    _daySegmentedControl.sectionTitles = sectionTitles;
    _daySegmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    _daySegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _daySegmentedControl.selectionIndicatorBoxOpacity = 0;
    
    _timeStartButton.backgroundColor = [UIColor lightGrayColor];
    _timeStartButton.tag = 1;
    [_timeStartButton addTarget:self
                         action:@selector(changeTime:)
               forControlEvents:UIControlEventTouchUpInside];
    
    _timeEndButton.backgroundColor = [UIColor lightGrayColor];
    _timeEndButton.tag = 2;
    [_timeEndButton addTarget:self
                         action:@selector(changeTime:)
               forControlEvents:UIControlEventTouchUpInside];
    
    _separator.backgroundColor = [UIColor lightGrayColor];
    
    [self.contentView addSubview:_titleLabel];
    [self.contentView addSubview:_lectureLocationLabel];
    [self.contentView addSubview:_dayLabel];
    [self.contentView addSubview:_timeStartLabel];
    [self.contentView addSubview:_timeEndLabel];
    
    [self.contentView addSubview:_lectureLocationField];
    [self.contentView addSubview:_daySegmentedControl];
    [self.contentView addSubview:_timeStartButton];
    [self.contentView addSubview:_timeEndButton];
    
    [self.contentView addSubview:_separator];
    
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    CGFloat padding = 10.0f;
    CGFloat gap = 30.0f;
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(padding);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
    }];
    
    [_lectureLocationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).with.offset(gap);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
    }];
    [_lectureLocationField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lectureLocationLabel.mas_bottom).with.offset(2.0f);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
    }];
    
    [_dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lectureLocationField.mas_bottom).with.offset(gap);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
    }];
    [_daySegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_dayLabel.mas_bottom).with.offset(2.0f);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
        make.height.equalTo(@40.0f);
    }];
    
    [_timeStartLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_daySegmentedControl.mas_bottom).with.offset(gap);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView.mas_centerX).with.offset(-padding);
    }];
    [_timeStartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeStartLabel.mas_bottom).with.offset(2.0f);
        make.left.equalTo(self.contentView).with.offset(padding);
        make.right.equalTo(self.contentView.mas_centerX).with.offset(-padding);
    }];
    
    [_timeEndLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_daySegmentedControl.mas_bottom).with.offset(gap);
        make.left.equalTo(self.contentView.mas_centerX).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
    }];
    [_timeEndButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeEndLabel.mas_bottom).with.offset(2.0f);
        make.left.equalTo(self.contentView.mas_centerX).with.offset(padding);
        make.right.equalTo(self.contentView).with.offset(-padding);
    }];
    
    [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).with.offset(1.0f);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@1.0f);
    }];
}

#pragma mark - Time Change Method

- (void)changeTime:(UIButton *)button
{
    [button setTitle:@"9:00" forState:UIControlStateNormal];
    NSLog(@"changeTime\ntag : %ld\ntitle : %@", button.tag, button.titleLabel.text);
}

#pragma mark - Setter

- (void)setLectureDetailIndex:(NSInteger)lectureDetailIndex
{
    _lectureDetailIndex = lectureDetailIndex;
    _lectureLocationField.tag = lectureDetailIndex;
    _titleLabel.text = [self titleString];
}

- (void)setLectureLocation:(NSString *)lectureLocation
{
    _lectureLocationField.text = lectureLocation;
}

- (void)setTimeStart:(NSInteger)timeStart
{
    [_timeStartButton setTitle:[self stringFromTimeInteger:timeStart] forState:UIControlStateNormal];
}

- (void)setTimeEnd:(NSInteger)timeEnd
{
    [_timeEndButton setTitle:[self stringFromTimeInteger:timeEnd] forState:UIControlStateNormal];
}

- (void)setDay:(NSInteger)day
{
    _daySegmentedControl.selectedSegmentIndex = day;
}

#pragma mark - Getter

- (NSString *)titleString
{
    return [NSString stringWithFormat:@"수업 %ld", _lectureDetailIndex+1];
}

- (NSString *)lectureLocation
{
    return _lectureLocationField.text;
}

- (NSInteger)timeStart
{
    return [self integerFromTimeString:_timeStartButton.titleLabel.text];
}

- (NSInteger)timeEnd
{
    return [self integerFromTimeString:_timeEndButton.titleLabel.text];
}

- (NSInteger)day
{
    return _daySegmentedControl.selectedSegmentIndex;
}

#pragma mark - Convert Method

- (NSString *)stringFromTimeInteger:(NSInteger)timeInteger
{
    NSInteger hours = timeInteger/100;
    NSInteger minutes = timeInteger%100;
    return [NSString stringWithFormat:@"%ld:%02ld", hours, minutes];
}

- (NSInteger)integerFromTimeString:(NSString *)timeString
{
    NSArray *timeStringComponents = [timeString componentsSeparatedByString:@":"];
    NSInteger hours = [timeStringComponents[0] integerValue];
    NSInteger minutes = [timeStringComponents[1] integerValue];
    return hours*100 + minutes;
}

@end
