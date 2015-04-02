//
//  LectureDetailView.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 2..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "LectureDetailView.h"

#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

@interface LectureDetailView ()

@property (nonatomic, strong) UILabel *lectureNameLabel;
@property (nonatomic, strong) UILabel *lectureLocationLabel;

@end

@implementation LectureDetailView

- (id)initWithFrame:(CGRect)frame theme:(NSInteger)theme lectureName:(NSString *)lectureName lectureLocation:(NSString *)lectureLocation
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedLectureDetail = NO;
        self.lectureName = lectureName;
        self.lectureLocation = lectureLocation;
        self.theme = theme;
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedLectureDetail = NO;
        self.lectureName = @"";
        self.lectureLocation = @"";
        self.theme = 0;
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.clipsToBounds = YES;
    self.alpha = 0.7f;
    
    _lectureNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 10)];
    _lectureNameLabel.textAlignment = NSTextAlignmentCenter;
    _lectureNameLabel.numberOfLines = 0;
    _lectureNameLabel.textColor = [UIColor op_textPrimary];
    _lectureNameLabel.font = [UIFont op_secondary];
    
    _lectureLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 10)];
    _lectureLocationLabel.textAlignment = NSTextAlignmentCenter;
    _lectureLocationLabel.numberOfLines = 4;
    _lectureLocationLabel.textColor = [UIColor op_textSecondary];
    _lectureLocationLabel.font = [UIFont op_secondary];
    
    [self addSubview:_lectureNameLabel];
    [self addSubview:_lectureLocationLabel];
}

#pragma mark - Draw

- (void)layoutSubviews
{
    _lectureNameLabel.text = _lectureName;
    _lectureLocationLabel.text = _lectureLocation;
    
    [_lectureNameLabel sizeToFit];
    [_lectureLocationLabel sizeToFit];
    
    CGSize lectureNameLabelSize = _lectureNameLabel.frame.size;
    CGSize lectureLocationLabelSize = _lectureLocationLabel.frame.size;
    
    _lectureNameLabel.frame = CGRectMake(0, 10.0f, self.bounds.size.width, lectureNameLabelSize.height);
    _lectureLocationLabel.frame = CGRectMake(0, (self.bounds.size.height + 10.0f + _lectureNameLabel.frame.size.height)/2 - (lectureLocationLabelSize.height/2), self.bounds.size.width, lectureLocationLabelSize.height);
}

- (void)drawRect:(CGRect)rect
{
    [self setNeedsLayout];
}

#pragma mark - Setter

- (void)setLectureName:(NSString *)lectureName
{
    _lectureName = lectureName;
    [self layoutSubviews];
}

- (void)setLectureLocation:(NSString *)lectureLocation
{
    _lectureLocation = lectureLocation;
    [self layoutSubviews];
}

- (void)setTheme:(NSInteger)theme
{
    _theme = theme;
    self.backgroundColor = [UIColor op_lectureTheme:theme];
    [self setNeedsDisplay];
}

@end
