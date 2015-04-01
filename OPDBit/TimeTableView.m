//
//  TimeTableView.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 1..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "TimeTableView.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

@interface TimeTableView ()

@property (nonatomic) NSInteger blockStart;
@property (nonatomic) NSInteger blockEnd;

@property (nonatomic) CGFloat sectionWidth;
@property (nonatomic) CGFloat timeHeight;

@property (nonatomic) NSInteger timeBlockCount;

@end

@implementation TimeTableView

static CGFloat const SectionHeadHeight = 50.0f;
static CGFloat const TimeHeadWidth = 30.0f;
static CGFloat const LineWidth = 0.5f;

- (id)initWithFrame:(CGRect)frame lectureDetails:(NSArray *)lectureDetails sectionTitles:(NSArray *)sectionTitles timeStart:(NSInteger)timeStart timeEnd:(NSInteger)timeEnd
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _sectionTitles = sectionTitles;
        _lectureDetails = lectureDetails;
        
        _timeStart = timeStart;
        _timeEnd = timeEnd;
        _timeBlockCount = [self timeBlockCount];
        
        [self initializeLayout];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor op_background];
        
        _sectionTitles = @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"];
        _lectureDetails = [[NSArray alloc] init];
        
        _timeStart = 800;
        _timeEnd = 2000;
        _timeBlockCount = [self timeBlockCount];
        
        [self initializeLayout];
    }
    return self;
}

- (void)initializeLayout
{
    _sectionWidth = (self.frame.size.width-TimeHeadWidth)/_sectionTitles.count;
    _timeHeight = (self.frame.size.height-SectionHeadHeight)/_timeBlockCount;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawLines];
}

- (void)drawLines
{
    [self initializeLayout];
    NSInteger i;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor op_dividerDark].CGColor);

    CGContextSetLineWidth(context, LineWidth);
    
    // Section Line Drawing
    for (i = 0; i < _sectionTitles.count; i++) {
        CGContextMoveToPoint(context, TimeHeadWidth+(_sectionWidth*i), 0.0f); //start at this point
        CGContextAddLineToPoint(context, TimeHeadWidth+(_sectionWidth*i), self.frame.size.height); //draw to this point
    }
    
    for (i = 0; i < _timeBlockCount; i++) {
        CGContextMoveToPoint(context, 0.0f, SectionHeadHeight+(_timeHeight*i)); //start at this point
        CGContextAddLineToPoint(context, self.frame.size.width, SectionHeadHeight+(_timeHeight*i)); //draw to this point
    }
    
    // and now draw the Path!
    CGContextStrokePath(context);
    
#warning 텍스트 위, 아래로 정렬
    
    for (i = _blockStart; i < _blockEnd; i++) {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SectionHeadHeight+_timeHeight*(i-_blockStart), TimeHeadWidth, _timeHeight)];
        timeLabel.textColor = [UIColor op_textPrimaryDark];
        timeLabel.font = [UIFont op_primary];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.text = [NSString stringWithFormat:@"%2ld", (i%12 == 0) ? 12 : i%12];
        [self addSubview:timeLabel];
    }
    
    for (i = 0; i < _sectionTitles.count; i++) {
        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(TimeHeadWidth+_sectionWidth*i, 0, _sectionWidth, SectionHeadHeight)];
        sectionLabel.textColor = [UIColor op_textPrimaryDark];
        sectionLabel.font = [UIFont op_primary];
        sectionLabel.textAlignment = NSTextAlignmentCenter;
        sectionLabel.text = _sectionTitles[i];
        [self addSubview:sectionLabel];
    }
}

#pragma mark - Instance Method

- (NSInteger)timeBlockCount
{
    if (_timeStart%100 == 0)
        _blockStart = _timeStart/100;
    else
        _blockStart = (_timeStart/100)-1;
    
    if (_timeEnd%100 == 0)
        _blockEnd = _timeEnd/100;
    else
        _blockEnd = (_timeEnd/100)+1;
    
    return _blockEnd - _blockStart;
}


@end
