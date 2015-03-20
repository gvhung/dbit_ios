//
//  LectureTableViewCell.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "LectureTableViewCell.h"
#import "DataManager.h"

#import <Masonry/Masonry.h>
#import <MZClockView/MZClockView.h>

@interface LectureTableViewCell ()

@property (nonatomic, strong) MZClockView *clockView;

@property (nonatomic, strong) UILabel *lectureNameLabel;
@property (nonatomic, strong) UILabel *lectureLocationLabel;
@property (nonatomic, strong) UILabel *lectureTimeLabel;

@end

@implementation LectureTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _clockView = [[MZClockView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.height - 10.0f, self.contentView.frame.size.height - 10.0f)
                                                  color:[UIColor blueColor]
                                                  hours:10
                                                minutes:10
                                              handWidth:2.0f
                                            borderWidth:2.0f];
        _lectureNameLabel = [[UILabel alloc] init];
        _lectureLocationLabel = [[UILabel alloc] init];
        _lectureTimeLabel = [[UILabel alloc] init];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    _clockView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addSubview:_clockView];
    [self.contentView addSubview:_lectureNameLabel];
    [self.contentView addSubview:_lectureTimeLabel];
    [self.contentView addSubview:_lectureLocationLabel];
    
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_clockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(10.0f);
        make.top.equalTo(self.contentView).with.offset(5.0f);
        make.bottom.equalTo(self.contentView.mas_centerY).with.offset(5.0f);
    }];
    
    [_lectureNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(5.0f);
        make.left.equalTo(_clockView.mas_bottom).with.offset(10.0f);
        make.right.equalTo(self.contentView).with.offset(-10.0f);
    }];
    [_lectureTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lectureNameLabel.mas_bottom).with.offset(3.0f);
        make.left.equalTo(_clockView.mas_bottom).with.offset(10.0f);
        make.right.equalTo(self.contentView).with.offset(-10.0f);
    }];
    [_lectureLocationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lectureTimeLabel.mas_bottom).with.offset(3.0f);
        make.left.equalTo(_clockView.mas_bottom).with.offset(10.0f);
        make.right.equalTo(self.contentView).with.offset(-10.0f);
    }];
}

#pragma mark - Setter

- (void)setLectureDetailDictionary:(NSDictionary *)lectureDetailDictionary
{
    _lectureDetailDictionary = lectureDetailDictionary;
    
    NSInteger startTime = [lectureDetailDictionary[@"timeStart"] integerValue];
    NSInteger endTime = [lectureDetailDictionary[@"timeEnd"] integerValue];
    
    _clockView.hours = startTime/100;
    _clockView.minutes = startTime%100;
    
    NSString *timeString = [NSString stringWithFormat:@"%@ ~ %@", [DataManager stringFromTimeInteger:startTime], [DataManager stringFromTimeInteger:endTime]];
    
    _lectureNameLabel.text = lectureDetailDictionary[@"lectureName"];
    _lectureLocationLabel.text = lectureDetailDictionary[@"lectureLocation"];
    _lectureTimeLabel.text = timeString;
}

#pragma mark - Getter

- (NSInteger)ulid
{
    if (!_lectureDetailDictionary[@"ulid"])
        return -1;
    return [_lectureDetailDictionary[@"ulid"] integerValue];
}
@end
