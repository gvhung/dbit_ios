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

#import "LectureObject.h"
#import "TimeTableObject.h"
#import "ServerLectureObject.h"

#import "DataManager.h"

#import <Realm/Realm.h>

@interface TimeTableView ()

@property (nonatomic, strong) NSArray *sectionTitles;

@property (nonatomic, strong) RLMArray<LectureObject> *lectures;
@property (nonatomic, strong) NSMutableArray *serverLectureDetails;

@property (nonatomic) NSInteger timeStart;
@property (nonatomic) NSInteger timeEnd;

@property (nonatomic) NSInteger blockStart;
@property (nonatomic) NSInteger blockEnd;

@property (nonatomic) CGFloat sectionWidth;
@property (nonatomic) CGFloat timeHeight;

@property (nonatomic) NSInteger timeBlockCount;

@property (nonatomic) NSInteger serverLectureTheme;

@end

@implementation TimeTableView

static CGFloat SectionHeadHeight = 30.0f;
static CGFloat TimeHeadWidth = 20.0f;
static CGFloat LineWidth = 0.5f;

- (instancetype)initWithFrame:(CGRect)frame timetable:(TimeTableObject *)timetable
{
    return [self initWithFrame:frame timetable:timetable serverLecture:nil theme:-1];
}

- (instancetype)initWithFrame:(CGRect)frame timetable:(TimeTableObject *)timetable serverLecture:(ServerLectureObject *)serverLecture theme:(NSInteger)theme
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        NSArray *sections = (timetable.workAtWeekend) ? @[@"월", @"화", @"수", @"목", @"금"] : @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"];
        
        self.sectionTitles = sections;
        self.lectures = timetable.lectures;
        
        self.timeStart = timetable.timeStart;
        self.timeEnd = timetable.timeEnd;
        self.timeBlockCount = [self timeBlockCount];
        self.timetable = timetable;
        
        if (serverLecture) {
            self.serverLectureTheme = theme;
            self.serverLecture = serverLecture;
        }
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
        _lectures = nil;
        
        _timeStart = 800;
        _timeEnd = 2000;
    }
    return self;
}

- (void)initializeLayout
{
    _timeBlockCount = [self timeBlockCount];
    _sectionWidth = (self.frame.size.width-TimeHeadWidth)/_sectionTitles.count;
    _timeHeight = (self.frame.size.height-SectionHeadHeight)/_timeBlockCount;
    
    for (LectureObject *lecture in _lectures) {
        for (LectureDetailObject *lectureDetail in lecture.lectureDetails) {
            CGRect lectureDetailViewFrame = [self lectureDetailViewFrameWithTimeStart:lectureDetail.timeStart
                                                                              timeEnd:lectureDetail.timeEnd
                                                                                  day:lectureDetail.day];
            LectureDetailView *lectureDetailView = [[LectureDetailView alloc] initWithFrame:lectureDetailViewFrame
                                                                                      theme:lecture.theme
                                                                                lectureName:lecture.lectureName
                                                                            lectureLocation:lectureDetail.lectureLocation
                                                                                       type:LectureDetailViewTypeApp];
            [self addSubview:lectureDetailView];
        }
    }
    
    if (_serverLecture) {
        for (NSDictionary *serverLectureDetail in _serverLectureDetails) {
            NSInteger day = [serverLectureDetail[@"day"] integerValue];
            NSInteger timeStart = [serverLectureDetail[@"timeStart"] integerValue];
            NSInteger timeEnd = [serverLectureDetail[@"timeEnd"] integerValue];
            
            [self reloadTimetableLimitsWithTimeStart:timeStart timeEnd:timeEnd];
            
            NSString *lectureLocation = serverLectureDetail[@"location"];
            
            CGRect serverLectureViewFrame = [self lectureDetailViewFrameWithTimeStart:timeStart
                                                                              timeEnd:timeEnd
                                                                                  day:day];
            LectureDetailView *serverLectureView = [[LectureDetailView alloc] initWithFrame:serverLectureViewFrame
                                                                                      theme:_serverLectureTheme
                                                                                lectureName:_serverLecture.lectureName
                                                                            lectureLocation:lectureLocation
                                                                                       type:LectureDetailViewTypeServerLecture];
            [self addSubview:serverLectureView];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSArray *sections = (_timetable.workAtWeekend) ? @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"] : @[@"월", @"화", @"수", @"목", @"금"];
    
    self.sectionTitles = sections;
    self.lectures = _timetable.lectures;
    
    self.timeStart = _timetable.timeStart;
    self.timeEnd = _timetable.timeEnd;
    
    if (_serverLectureDetails) {
        [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj performSelector:@selector(removeFromSuperview) withObject:nil];
        }];
        
        for (NSDictionary *serverLectureDetail in _serverLectureDetails) {
            NSInteger timeStart = [serverLectureDetail[@"timeStart"] integerValue];
            NSInteger timeEnd = [serverLectureDetail[@"timeEnd"] integerValue];
            [self reloadTimetableLimitsWithTimeStart:timeStart timeEnd:timeEnd];
        }
    }
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

#pragma mark - Setter


- (void)setServerLecture:(ServerLectureObject *)serverLecture
{
    _serverLecture = serverLecture;
    if (!_serverLectureDetails) {
        _serverLectureDetails = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    NSMutableArray *lectureLocationArray = [_serverLecture.lectureLocation componentsSeparatedByString:@"),"].mutableCopy;
    for (NSInteger i = 0; i < lectureLocationArray.count; i++) {
        NSString *lectureLocationString = lectureLocationArray[i];
        
        if (i < lectureLocationArray.count-1) {
            NSString *convertedString = [lectureLocationString stringByAppendingString:@")"];
            [lectureLocationArray replaceObjectAtIndex:i withObject:convertedString];
        }
    }
    
    NSMutableArray *lectureDaytimeArray = [_serverLecture.lectureDaytime componentsSeparatedByString:@","].mutableCopy;
    NSInteger detailCount = MAX(lectureLocationArray.count, lectureDaytimeArray.count);
    
    for (NSInteger i = 0; i < detailCount ; i++) {
        NSInteger day = [self dayWithString:lectureDaytimeArray[i]];
        NSInteger timeStart = [self timeStartWithString:lectureDaytimeArray[i]];
        NSInteger timeEnd = [self timeEndWithString:lectureDaytimeArray[i]];
        
        NSString *lectureLocation = @"";
        if ([lectureLocationArray[i] length]) {
            lectureLocation = lectureLocationArray[i];
        }
        [_serverLectureDetails addObject:@{@"day" : @(day), @"timeStart" : @(timeStart), @"timeEnd" : @(timeEnd), @"location" : lectureLocation}];
    }
}

#pragma mark - Instance Method

- (NSInteger)timeBlockCount
{
    _blockStart = _timeStart/100;
    
    if (_timeEnd%100 == 0)
        _blockEnd = _timeEnd/100;
    else
        _blockEnd = (_timeEnd/100)+1;
    
    return _blockEnd - _blockStart;
}

- (NSInteger)dayWithString:(NSString *)string
{
    if (!string) {
        return 0;
    }
    
    NSString *pureDaytimeString = [string substringToIndex:1];
    
    NSArray *dayStringArray = @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"];
    NSInteger dayInteger = 0;
    for (NSString *dayString in dayStringArray) {
        if ([dayString isEqualToString:pureDaytimeString]) {
            dayInteger = [dayStringArray indexOfObject:dayString];
        }
    }
    
    return dayInteger;
}

- (NSInteger)timeStartWithString:(NSString *)string
{
    if (!string) {
        return 0;
    }
    
    NSString *pureDaytimeString = [string componentsSeparatedByString:@"/"][1];
    NSString *timeStartString = [pureDaytimeString componentsSeparatedByString:@"-"][0];
    return [DataManager integerFromTimeString:timeStartString];
}

- (NSInteger)timeEndWithString:(NSString *)string
{
    if (!string) {
        return 0;
    }
    
    NSString *pureDaytimeString = [string componentsSeparatedByString:@"/"][1];
    NSString *timeEndString = [pureDaytimeString componentsSeparatedByString:@"-"][1];
    return [DataManager integerFromTimeString:timeEndString];
}

- (CGRect)lectureDetailViewFrameWithTimeStart:(NSInteger)timeStart timeEnd:(NSInteger)timeEnd day:(NSInteger)day
{
    NSInteger convertedTimeTableStart = _timeStart/100*60 + _timeStart%100;
    NSInteger startMargin = convertedTimeTableStart%60;
    NSInteger convertedStartTime = timeStart/100*60 + timeStart%100;
    NSInteger convertedStartEnd = timeEnd/100*60 + timeEnd%100;
    
    CGFloat x = TimeHeadWidth + _sectionWidth * day;
    CGFloat y = SectionHeadHeight + _timeHeight * ((startMargin + convertedStartTime - convertedTimeTableStart)/60.0f);
    CGFloat height = _timeHeight*((convertedStartEnd - convertedStartTime)/60.0f);
    
    return CGRectMake(x, y, _sectionWidth, height);
}

- (void)reloadTimetableLimitsWithTimeStart:(NSInteger)timeStart timeEnd:(NSInteger)timeEnd
{
    if (_timeStart == -1 || _timeStart > timeStart) {
        _timeStart = timeStart;
    }
    
    if (_timeEnd == -1 || _timeEnd < timeEnd) {
        _timeEnd = timeEnd;
    }
}

@end
