//
//  LectureDetailView.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 2..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "LectureDetailView.h"

// Utilities
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

#define BORDER_WIDTH 1.0f

@interface LectureDetailView ()

@property (nonatomic, strong) UILabel *lectureNameLabel;
@property (nonatomic, strong) UILabel *lectureLocationLabel;

@end

@implementation LectureDetailView

- (id)initWithFrame:(CGRect)frame theme:(NSInteger)theme lectureName:(NSString *)lectureName lectureLocation:(NSString *)lectureLocation type:(LectureDetailViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedLectureDetail = NO;
        self.lectureName = lectureName;
        self.lectureLocation = lectureLocation;
        self.theme = theme;
        
        self.type = type;
        
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = LectureDetailViewTypeApp;
        
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
    
    if (_type == LectureDetailViewTypeWidget) {
        _lectureNameLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:10];
        _lectureLocationLabel.numberOfLines = 3;
        _lectureLocationLabel.textColor = [UIColor op_textPrimary];
        _lectureLocationLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:9];
        
        self.backgroundColor = [[UIColor op_lectureTheme:_theme] colorWithAlphaComponent:0.5f];
    }
    
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
    if (_type == LectureDetailViewTypeWidget) {
        _lectureLocationLabel.frame = CGRectMake(0, (self.bounds.size.height + _lectureNameLabel.frame.size.height)/2 - (lectureLocationLabelSize.height/2), self.bounds.size.width, lectureLocationLabelSize.height);
    } else {
        _lectureLocationLabel.frame = CGRectMake(0, (self.bounds.size.height + 10.0f + _lectureNameLabel.frame.size.height)/2 - (lectureLocationLabelSize.height/2), self.bounds.size.width, lectureLocationLabelSize.height);
    }
    
    if ((_lectureNameLabel.frame.origin.y + _lectureNameLabel.frame.size.height) >= _lectureLocationLabel.frame.origin.y)
    {
        if (_type == LectureDetailViewTypeWidget) {
            _lectureNameLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:9];
            _lectureLocationLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:8];
        } else {
            _lectureNameLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:10];
            _lectureLocationLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:9];
        }
        
        CGRect lectureNameLabelFrame = _lectureNameLabel.frame;
        CGRect lectureLocationLabelFrame = _lectureLocationLabel.frame;
        
        lectureNameLabelFrame.origin.y = 5.0f;
        lectureLocationLabelFrame.origin.y = lectureNameLabelFrame.origin.y + lectureNameLabelFrame.size.height + 2.0f;
        
        _lectureNameLabel.frame = lectureNameLabelFrame;
        _lectureLocationLabel.frame = lectureLocationLabelFrame;
    }
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
    self.backgroundColor = [[UIColor op_lectureTheme:theme] colorWithAlphaComponent:(_type == LectureDetailViewTypeWidget)? 0.5f : 0.7f];
    [self setNeedsDisplay];
}

- (void)setType:(LectureDetailViewType)type
{
    _type = type;
    if (type == LectureDetailViewTypeServerLecture) {
        // Spreading Animation
        CALayer *borderLayer = [[CALayer alloc] initWithLayer:self.layer];
        borderLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
        borderLayer.backgroundColor = [UIColor clearColor].CGColor;
        borderLayer.frame = self.bounds;
        borderLayer.opacity = 0.7f;
//        borderLayer.frame = self.layer.frame;
//        borderLayer.position = self.layer.position;
        borderLayer.borderWidth = BORDER_WIDTH;
        borderLayer.borderColor = [UIColor op_lectureTheme:_theme].CGColor;
        
        CABasicAnimation *spreadAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        spreadAnimation.toValue = @(1.2f);
        spreadAnimation.fromValue = @(1.0f);
        
        CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOutAnimation.toValue = @(0.0f);
        fadeOutAnimation.fromValue = @(1.0f);
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[spreadAnimation, fadeOutAnimation];
        animationGroup.speed = 1.0f;
        animationGroup.duration = 1.0f;
        animationGroup.repeatCount = HUGE_VALF;
        
        [borderLayer addAnimation:animationGroup forKey:@"spread"];
        [self.layer insertSublayer:borderLayer atIndex:0];
        self.clipsToBounds = NO;
        [self setNeedsDisplay];
    } else {
        self.clipsToBounds = YES;
    }
}

@end
