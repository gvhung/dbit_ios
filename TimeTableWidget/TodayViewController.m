//
//  TodayViewController.m
//  TimeTableWidget
//
//  Created by Kweon Min Jun on 2015. 4. 4..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#define TimeTableViewWidth [UIScreen mainScreen].bounds.size.width
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromARGB(argbValue) [UIColor colorWithRed:((float)((argbValue & 0xFF0000) >> 16))/255.0 green:((float)((argbValue & 0xFF00) >> 8))/255.0 blue:((float)(argbValue & 0xFF))/255.0 alpha:((float)((argbValue & 0xFF000000) >> 24))/255.0]

@interface TodayViewController () <NCWidgetProviding, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *timeTableView;
@property (nonatomic, strong) UIButton *emptyButton;

@property (nonatomic, strong) NSDictionary *activedTimeTable;

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

@implementation TodayViewController

static CGFloat const TimeTableViewX = 0.0f;
static CGFloat const TimeTableViewHeight = 400.0f;

static CGFloat const EmptyButtonHeight = 20.0f;
static CGFloat const EmptyButtonPadding = 10.0f;

static CGFloat const SectionHeadHeight = 30.0f;
static CGFloat const TimeHeadWidth = 20.0f;

- (void)initializeWidget
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openDBitApp)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    if (!_activedTimeTable || [_activedTimeTable[@"timeStart"] integerValue] == -1) {
        _emptyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, EmptyButtonPadding, [UIScreen mainScreen].bounds.size.width, EmptyButtonHeight)];
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, EmptyButtonPadding+EmptyButtonHeight);
        [_emptyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _emptyButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:20];
        
        [_emptyButton setTitle:@"시간표를 등록하세요!" forState:UIControlStateNormal];
        if ([_activedTimeTable[@"timeStart"] integerValue] == -1)
            [_emptyButton setTitle:@"수업을 추가하세요!" forState:UIControlStateNormal];
        
        [self.view addSubview:_emptyButton];
        
    } else {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, TimeTableViewHeight+100.0f);
        
        _timeTableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TimeTableViewWidth, TimeTableViewHeight)];
        _timeTableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_timeTableView];
        
        [self updateTimeTable];
    }
}

- (void)updateTimeTable
{
    _lectures = _activedTimeTable[@"lectures"];
    _sectionTitles = ([_activedTimeTable[@"sat"] boolValue] && [_activedTimeTable[@"sun"] boolValue]) ? @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"] : @[@"월", @"화", @"수", @"목", @"금"];
    _timeStart = [_activedTimeTable[@"timeStart"] integerValue];
    _timeEnd = [_activedTimeTable[@"timeEnd"] integerValue];
    
    [self initializeProperty];
    [self drawTimeTableLines];
    [self drawLectureDetailView];
}

- (void)openDBitApp
{
    NSExtensionContext *context = self.extensionContext;
    NSURL *dbitURL;
    if (_activedTimeTable)
        dbitURL = [NSURL URLWithString:@"dbit://widget/show"];
    else
        dbitURL = [NSURL URLWithString:@"dbit://widget"];
    [context openURL:dbitURL completionHandler:nil];
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
    UIView *timeTableView = [[UIView alloc] initWithFrame:self.view.frame];
    timeTableView.backgroundColor = [UIColor clearColor];
    
    NSInteger i;
    
    for (i = _blockStart+1; i < _blockEnd; i++) {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TimeTableViewX, SectionHeadHeight+_timeHeight*(i-_blockStart), TimeHeadWidth, _timeHeight)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:12];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.text = [NSString stringWithFormat:@"%2ld", (i%12 == 0) ? 12 : i%12];
        [_timeTableView addSubview:timeLabel];
        
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
        [_timeTableView addSubview:sectionLabel];
    }
}

- (void)drawLectureDetailView
{
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
            UIView *lectureDetailView = [self lectureDetailViewWithFrame:lectureDetailViewFrame
                                                                   theme:[lectureDictionary[@"theme"] integerValue]
                                                             lectureName:lectureDictionary[@"lectureName"]
                                                         lectureLocation:lectureDetailDictionary[@"lectureLocation"]];
            [self.view addSubview:lectureDetailView];
        }
    }
}

#pragma mark - Draw Lecture Detail View

- (UIView *)lectureDetailViewWithFrame:(CGRect)frame theme:(NSInteger)theme lectureName:(NSString *)lectureName lectureLocation:(NSString *)lectureLocation
{
    UIView *lectureDetailView = [[UIView alloc] initWithFrame:frame];
    
    lectureDetailView.backgroundColor = [[self op_lectureTheme:theme] colorWithAlphaComponent:0.5f];
    lectureDetailView.clipsToBounds = YES;
    
    UILabel *lectureNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
    lectureNameLabel.textAlignment = NSTextAlignmentCenter;
    lectureNameLabel.numberOfLines = 0;
    lectureNameLabel.textColor = [UIColor whiteColor];
    lectureNameLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:10];
    lectureNameLabel.text = lectureName;
    
    UILabel *lectureLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
    lectureLocationLabel.textAlignment = NSTextAlignmentCenter;
    lectureLocationLabel.numberOfLines = 3;
    lectureLocationLabel.textColor = [UIColor whiteColor];
    lectureLocationLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:9];
    lectureLocationLabel.text = lectureLocation;
    
    [lectureDetailView addSubview:lectureNameLabel];
    [lectureDetailView addSubview:lectureLocationLabel];
    
    [lectureNameLabel sizeToFit];
    [lectureLocationLabel sizeToFit];
    
    CGSize lectureNameLabelSize = lectureNameLabel.frame.size;
    CGSize lectureLocationLabelSize = lectureLocationLabel.frame.size;
    
    lectureNameLabel.frame = CGRectMake(0, 10.0f, frame.size.width, lectureNameLabelSize.height);
    lectureLocationLabel.frame = CGRectMake(0, (frame.size.height + lectureNameLabel.frame.size.height)/2 - (lectureLocationLabelSize.height/2), frame.size.width, lectureLocationLabelSize.height);
    
    if ((lectureNameLabel.frame.origin.y+lectureNameLabel.frame.size.height) >= lectureLocationLabel.frame.origin.y)
    {
        lectureNameLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:9];
        lectureLocationLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:8];
        
        CGRect lectureNameLabelFrame = lectureNameLabel.frame;
        CGRect lectureLocationLabelFrame = lectureLocationLabel.frame;
        
        lectureNameLabelFrame.origin.y = 5.0f;
        lectureLocationLabelFrame.origin.y = lectureNameLabelFrame.origin.y + lectureNameLabelFrame.size.height + 2.0f;
        
        lectureNameLabel.frame = lectureNameLabelFrame;
        lectureLocationLabel.frame = lectureLocationLabelFrame;
    }
    
    return lectureDetailView;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect frame = self.view.superview.frame;
    frame = CGRectMake(0, CGRectGetMinY(frame), CGRectGetWidth(frame) + CGRectGetMinX(frame), CGRectGetHeight(frame));
    self.view.superview.frame = frame;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
    _activedTimeTable = [defaults objectForKey:@"ActivedTimeTable"];

    [self initializeWidget];
    completionHandler(NCUpdateResultNewData);
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

#pragma mark - Color Method

- (UIColor *)op_lectureTheme:(NSInteger)themeId
{
    switch (themeId) {
        case 0:
            return [self colorWithHexString:@"#F44336"];
            break;
            
        case 1:
            return [self colorWithHexString:@"#E91E63"];
            break;
            
        case 2:
            return [self colorWithHexString:@"#9C27B0"];
            break;
            
        case 3:
            return [self colorWithHexString:@"#673AB7"];
            break;
            
        case 4:
            return [self colorWithHexString:@"#3F51B5"];
            break;
            
        case 5:
            return [self colorWithHexString:@"#2196F3"];
            break;
            
        case 6:
            return [self colorWithHexString:@"#03A9F4"];
            break;
            
        case 7:
            return [self colorWithHexString:@"#00BCD4"];
            break;
            
        case 8:
            return [self colorWithHexString:@"#009688"];
            break;
            
        case 9:
            return [self colorWithHexString:@"#4CAF50"];
            break;
            
        case 10:
            return [self colorWithHexString:@"#8BC34A"];
            break;
            
        case 11:
            return [self colorWithHexString:@"#CDDC39"];
            break;
            
        case 12:
            return [self colorWithHexString:@"#FFEB3B"];
            break;
            
        case 13:
            return [self colorWithHexString:@"#FFC107"];
            break;
            
        case 14:
            return [self colorWithHexString:@"#FF9800"];
            break;
            
        case 15:
            return [self colorWithHexString:@"#FF5722"];
            break;
            
        case 16:
            return [self colorWithHexString:@"#795548"];
            break;
            
        case 17:
            return [self colorWithHexString:@"#9E9E9E"];
            break;
            
        case 18:
            return [self colorWithHexString:@"#607D8B"];
            break;
            
        default:
            return [UIColor whiteColor];
    }
}

- (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    if (str.length == 9) {
        return UIColorFromARGB(x);
    }
    return UIColorFromRGB(x);
}

@end
