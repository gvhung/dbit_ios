//
//  TimeTableViewForWidget.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 8. 24..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "TimeTableViewForWidget.h"

#import "LectureDetailView.h"

#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

#define TimeTableViewWidth [UIScreen mainScreen].bounds.size.width

@interface TimeTableViewForWidget ()

@property (nonatomic, strong) NSArray *lectures;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic) NSInteger timeStart;
@property (nonatomic) NSInteger timeEnd;

@property (nonatomic) NSInteger blockStart;
@property (nonatomic) NSInteger blockEnd;
@property (nonatomic) CGFloat sectionWidth;
@property (nonatomic) CGFloat timeHeight;
@property (nonatomic) NSInteger timeBlockCount;

@end

static CGFloat const TimeTableViewX = 0.0f;
static CGFloat const TimeTableViewHeight = 400.0f;

static CGFloat const SectionHeadHeight = 30.0f;
static CGFloat const TimeHeadWidth = 20.0f;

@implementation TimeTableViewForWidget

- (instancetype)initForWidgetWithFrame:(CGRect)frame timetable:(NSDictionary *)timetable
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _lectures = _timetableForWidget[@"lectures"];
        _sectionTitles = ([_timetableForWidget[@"workAtWeekend"] boolValue]) ? @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"] : @[@"월", @"화", @"수", @"목", @"금"];
        _timeStart = [_timetableForWidget[@"timeStart"] integerValue];
        _timeEnd = [_timetableForWidget[@"timeEnd"] integerValue];
        
        [self initializeProperty];
        [self drawTimeTableLines];
        [self drawLectureDetailView];
    }
    return self;
}

#pragma mark - Draw Time Table View

- (void)initializeProperty
{
    _timeBlockCount = [self timeBlockCount];
    _sectionWidth = (TimeTableViewWidth-TimeHeadWidth)/_sectionTitles.count;
    _timeHeight = (TimeTableViewHeight-SectionHeadHeight)/_timeBlockCount;
}

- (void)drawTimeTableLines
{
    UIView *timeTableView = [[UIView alloc] initWithFrame:self.frame];
    timeTableView.backgroundColor = [UIColor clearColor];
    
    NSInteger i;
    
    for (i = _blockStart+1; i < _blockEnd; i++) {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TimeTableViewX, SectionHeadHeight+_timeHeight*(i-_blockStart), TimeHeadWidth, _timeHeight)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:12];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.text = [NSString stringWithFormat:@"%2ld", (i%12 == 0) ? 12 : i%12];
        [self addSubview:timeLabel];
        
        [timeLabel sizeToFit];
        CGRect timeLabelRect = CGRectMake(TimeHeadWidth - timeLabel.frame.size.width, SectionHeadHeight+_timeHeight*(i-_blockStart)-timeLabel.frame.size.height/2, timeLabel.frame.size.width, timeLabel.frame.size.height);
        timeLabel.frame = timeLabelRect;
    }
    
    for (i = 0; i < _sectionTitles.count; i++) {
        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(TimeHeadWidth+_sectionWidth*i, 0, _sectionWidth, SectionHeadHeight)];
        sectionLabel.textColor = [UIColor whiteColor];
        sectionLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:12];
        sectionLabel.textAlignment = NSTextAlignmentCenter;
        sectionLabel.text = _sectionTitles[i];
        [self addSubview:sectionLabel];
    }
}

- (void)drawLectureDetailView
{
    for (NSDictionary *lectureDictionary in _lectures) {
        for (NSDictionary *lectureDetailDictionary in lectureDictionary[@"lectureDetails"]) {
            
            NSInteger convertedTimeTableStart = _timeStart/100*60 + _timeStart%100;
            NSInteger convertedStartTime = [lectureDetailDictionary[@"timeStart"] integerValue]/100*60 + [lectureDetailDictionary[@"timeStart"] integerValue]%100;
            NSInteger convertedStartEnd = [lectureDetailDictionary[@"timeEnd"] integerValue]/100*60 + [lectureDetailDictionary[@"timeEnd"] integerValue]%100;
            
            CGFloat x = TimeHeadWidth + _sectionWidth * [lectureDetailDictionary[@"day"] integerValue];
            CGFloat y = SectionHeadHeight + _timeHeight * ((convertedStartTime - convertedTimeTableStart)/60.0f);
            CGFloat height = _timeHeight*((convertedStartEnd - convertedStartTime)/60.0f);
            
            CGRect lectureDetailViewFrame = CGRectMake(x, y, _sectionWidth, height);
            UIView *lectureDetailView = [[LectureDetailView alloc] initWithFrame:lectureDetailViewFrame
                                                                           theme:[lectureDictionary[@"theme"] integerValue]
                                                                     lectureName:lectureDictionary[@"lectureName"]
                                                                 lectureLocation:lectureDetailDictionary[@"lectureLocation"]];
            [self addSubview:lectureDetailView];
        }
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

- (void)setTimetableForWidget:(NSDictionary *)timetableForWidget
{
    _timetableForWidget = timetableForWidget;
    
    _lectures = _timetableForWidget[@"lectures"];
    _sectionTitles = ([_timetableForWidget[@"workAtWeekend"] boolValue]) ? @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"] : @[@"월", @"화", @"수", @"목", @"금"];
    _timeStart = [_timetableForWidget[@"timeStart"] integerValue];
    _timeEnd = [_timetableForWidget[@"timeEnd"] integerValue];
    
    [self initializeProperty];
    [self drawTimeTableLines];
    [self drawLectureDetailView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
