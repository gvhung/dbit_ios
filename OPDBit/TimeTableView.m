//
//  TimeTableView.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 1..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "TimeTableView.h"
#import "LectureDetailView.h"

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

static CGFloat SectionHeadHeight = 30.0f;
static CGFloat TimeHeadWidth = 20.0f;
static CGFloat LineWidth = 0.5f;


- (id)initForWidgetWithFrame:(CGRect)frame lectures:(NSArray *)lectures sectionTitles:(NSArray *)sectionTitles timeStart:(NSInteger)timeStart timeEnd:(NSInteger)timeEnd
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.sectionTitles = sectionTitles;
        self.lectures = lectures;
        
        self.timeStart = timeStart;
        self.timeEnd = timeEnd;
        self.timeBlockCount = [self timeBlockCount];
        
        [self initializeLayout];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame lectures:(NSArray *)lectures sectionTitles:(NSArray *)sectionTitles timeStart:(NSInteger)timeStart timeEnd:(NSInteger)timeEnd
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor op_background];
        
        self.sectionTitles = sectionTitles;
        self.lectures = lectures;
        
        self.timeStart = timeStart;
        self.timeEnd = timeEnd;
        self.timeBlockCount = [self timeBlockCount];
        
        [self initializeLayout];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor op_background];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setNeedsDisplay)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        _sectionTitles = @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"];
        _lectures = [[NSArray alloc] init];
        
        _timeStart = 800;
        _timeEnd = 2000;
        
        [self initializeLayout];
    }
    return self;
}

- (void)initializeLayout
{
    _timeBlockCount = [self timeBlockCount];
    _sectionWidth = (self.frame.size.width-TimeHeadWidth)/_sectionTitles.count;
    _timeHeight = (self.frame.size.height-SectionHeadHeight)/_timeBlockCount;
    
    for (NSDictionary *lectureDictionary in _lectures) {
        for (NSDictionary *lectureDetailDictionary in lectureDictionary[@"lectureDetails"]) {
            
            NSInteger convertedStartTime = [lectureDetailDictionary[@"timeStart"] integerValue] - _timeStart;
            CGFloat startHours = convertedStartTime/100;
            CGFloat startMinutes = convertedStartTime%100;
            
            NSInteger convertedEndTime = [lectureDetailDictionary[@"timeEnd"] integerValue] - [lectureDetailDictionary[@"timeStart"] integerValue];
            CGFloat endHours = convertedEndTime/100;
            CGFloat endMinutes = convertedEndTime%100;
            
            CGFloat x = TimeHeadWidth + _sectionWidth*[lectureDetailDictionary[@"day"] integerValue];
            CGFloat y = SectionHeadHeight + _timeHeight*(startHours + startMinutes/60);
            CGFloat height = _timeHeight*(endHours + endMinutes/60);
            
            CGRect lectureDetailViewFrame = CGRectMake(x, y, _sectionWidth, height);
            LectureDetailView *lectureDetailView = [[LectureDetailView alloc] initWithFrame:lectureDetailViewFrame
                                                                                      theme:[lectureDictionary[@"theme"] integerValue]
                                                                                lectureName:lectureDictionary[@"lectureName"]
                                                                            lectureLocation:lectureDetailDictionary[@"lectureLocation"]];
            [self addSubview:lectureDetailView];
        }
    }
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
    CGContextSetStrokeColorWithColor(context, [UIColor op_textSecondaryDark].CGColor);
    CGContextSetLineWidth(context, LineWidth);

    // Section Line Drawing
    for (i = 0; i < _sectionTitles.count; i++) {
        if (i == 1) {
            CGContextStrokePath(context);
            CGContextSetStrokeColorWithColor(context, [UIColor op_dividerDark].CGColor);
        }
        CGContextMoveToPoint(context, TimeHeadWidth+(_sectionWidth*i), SectionHeadHeight); //start at this point
        CGContextAddLineToPoint(context, TimeHeadWidth+(_sectionWidth*i), self.frame.size.height); //draw to this point
    }
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor op_textSecondaryDark].CGColor);
    
    for (i = 0; i < _timeBlockCount; i++) {
        if (i == 1) {
            CGContextStrokePath(context);
            CGContextSetStrokeColorWithColor(context, [UIColor op_dividerDark].CGColor);
        }
        CGContextMoveToPoint(context, TimeHeadWidth, SectionHeadHeight+(_timeHeight*i)); //start at this point
        CGContextAddLineToPoint(context, self.frame.size.width, SectionHeadHeight+(_timeHeight*i)); //draw to this point
    }
    CGContextStrokePath(context);
    
    for (i = _blockStart+1; i < _blockEnd; i++) {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SectionHeadHeight+_timeHeight*(i-_blockStart), TimeHeadWidth, _timeHeight)];
        timeLabel.textColor = [UIColor op_textPrimaryDark];
        timeLabel.font = [UIFont op_primary];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.text = [NSString stringWithFormat:@"%2ld", (i%12 == 0) ? 12 : i%12];
        [self addSubview:timeLabel];
        
        [timeLabel sizeToFit];
        CGRect timeLabelRect = CGRectMake(TimeHeadWidth - timeLabel.frame.size.width - 2.0f, SectionHeadHeight+_timeHeight*(i-_blockStart)-timeLabel.frame.size.height/2, timeLabel.frame.size.width, timeLabel.frame.size.height);
        timeLabel.frame = timeLabelRect;
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
