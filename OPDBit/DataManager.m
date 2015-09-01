//
//  DataManager.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "DataManager.h"

#import <Realm/Realm.h>
#import "ServerSemesterObject.h"
#import "ServerLectureObject.h"
#import "TimeTableObject.h"

#import "UIColor+OPTheme.h"

@interface DataManager ()

@property (nonatomic, strong) RLMRealm *realm;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation DataManager

+ (DataManager *)sharedInstance
{
    static dispatch_once_t pred;
    static DataManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[DataManager alloc] init];
    });
    
    return shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        _realm = [RLMRealm defaultRealm];
    }
    return self;
}

#pragma mark - Save Objects

- (void)saveOrUpdateServerSemester:(ServerSemesterObject *)serverSemester
                        completion:(void (^)(BOOL isUpdated))completion
{
    BOOL hasDuplicated = NO;
    
    [_realm beginWriteTransaction];
    RLMResults *result = [ServerSemesterObject objectsInRealm:_realm where:@"semesterID == %ld", serverSemester.semesterID];
    if (result.count) {
        hasDuplicated = YES;
        if ([[result firstObject] serverLectures].count) {
            [_realm deleteObjects:[[result firstObject] serverLectures]];
        }
        [_realm deleteObjects:result];
    }
    
    [_realm addObjects:serverSemester.serverLectures];
    [_realm addOrUpdateObject:serverSemester];
    [_realm commitWriteTransaction];
    completion(hasDuplicated);
}
- (void)saveOrUpdateTimeTable:(TimeTableObject *)timeTableObject
                   completion:(void (^)(BOOL isUpdated))completion
{
    BOOL hasDuplicated = NO;
    
    [_realm beginWriteTransaction];
    
    RLMResults *timeTableResults = [TimeTableObject objectsInRealm:_realm where:@"utid == %ld", timeTableObject.utid];
    if (timeTableResults.count) {
        hasDuplicated = YES;
    } else {
        timeTableObject.utid = [self lastUtid] + 1;
    }
    
    if (timeTableObject.active) {
        RLMResults *timeTableResults = [TimeTableObject objectsInRealm:_realm where:@"active == YES AND utid != %ld", timeTableObject.utid];
        NSInteger count = timeTableResults.count;
        for (NSInteger i = 0; i < count; i++) {
            TimeTableObject *resultTimeTableObject = timeTableResults[i];
            resultTimeTableObject.active = NO;
            [_realm addOrUpdateObject:resultTimeTableObject];
        }
    }
    
    [_realm addOrUpdateObject:timeTableObject];
    [_realm commitWriteTransaction];
    
    completion(hasDuplicated);

    [self refreshTimeTableSetting];
    [self synchronizeUserDefaultWithTimeTable:self.activedTimeTable];
}

- (void)saveOrUpdateLectureWithLecture:(LectureObject *)lectureObject
                        lectureDetails:(RLMArray *)lectureDetails
                            completion:(void (^)(BOOL isUpdated))completion
{
    BOOL hasDuplicated = NO;
    
    [_realm beginWriteTransaction];
    
    
    TimeTableObject *activedTimeTable = self.activedTimeTable;
    
    RLMResults *lectureResults = [LectureObject objectsInRealm:_realm where:@"ulid == %ld", lectureObject.ulid];
    if (lectureResults.count) {
        [activedTimeTable.lectures removeObjectAtIndex:[activedTimeTable.lectures indexOfObject:lectureResults[0]]];
        hasDuplicated = YES;
    } else {
        lectureObject.ulid = [self lastUlid] + 1;
    }
    
    lectureObject.lectureDetails = nil;
    [lectureObject.lectureDetails addObjects:lectureDetails];
    
    [_realm addObjects:lectureObject.lectureDetails];
    [_realm addOrUpdateObject:lectureObject];
    
    [activedTimeTable.lectures addObject:lectureObject];
    [_realm addOrUpdateObject:activedTimeTable];
    [_realm commitWriteTransaction];
    
    completion(hasDuplicated);
    
    [self refreshTimeTableSetting];
    [self synchronizeUserDefaultWithTimeTable:self.activedTimeTable];
}

#pragma mark - Delete Object in Realm

- (void)deleteTimeTableWithUtid:(NSInteger)utid
{
    [_realm beginWriteTransaction];
    RLMResults *timeTableObjectToDeleteResult = [TimeTableObject objectsInRealm:_realm where:@"utid == %ld", utid];
    TimeTableObject *timeTableObjectToDelete = timeTableObjectToDeleteResult[0];
    for (LectureObject *lectureObject in timeTableObjectToDelete.lectures) {
        [_realm deleteObjects:lectureObject.lectureDetails];
    }
    [_realm deleteObjects:timeTableObjectToDelete.lectures];
    [_realm deleteObject:timeTableObjectToDelete];
    [_realm commitWriteTransaction];
    if (!self.activedTimeTable) {
        [self synchronizeUserDefaultWithTimeTable:nil];
    }
}

- (void)deleteLectureWithUlid:(NSInteger)ulid
{
    [_realm beginWriteTransaction];
    RLMResults *lectureObjectToDeleteResult = [LectureObject objectsInRealm:_realm where:@"ulid == %ld", ulid];
    LectureObject *lectureObjectToDelete = lectureObjectToDeleteResult[0];
    [_realm deleteObjects:lectureObjectToDelete.lectureDetails];
    [_realm deleteObject:lectureObjectToDelete];
    [_realm commitWriteTransaction];
    
    [self refreshTimeTableSetting];
}

#pragma mark - Instance Action

- (NSInteger)lastUtid
{
    RLMResults *timeTableResults = [[TimeTableObject allObjectsInRealm:_realm] sortedResultsUsingProperty:@"utid" ascending:NO];
    if (timeTableResults.count == 0)
        return -1;
    TimeTableObject *lastTimeTableObject = timeTableResults[0];
    return lastTimeTableObject.utid;
}

- (NSInteger)lastUlid
{
    RLMResults *lectureResults = [[LectureObject allObjectsInRealm:_realm] sortedResultsUsingProperty:@"ulid" ascending:NO];
    if (lectureResults.count == 0)
        return -1;
    LectureObject *lastLectureObject = lectureResults[0];
    return lastLectureObject.ulid;
}

- (void)refreshTimeTableSetting
{
    [_realm beginWriteTransaction];
    
    self.activedTimeTable.workAtWeekend = NO;
    self.activedTimeTable.timeStart = -1;
    self.activedTimeTable.timeEnd = -1;
    
    for (LectureObject *lectureObject in self.activedTimeTable.lectures) {
        for (LectureDetailObject *lectureDetailObject in lectureObject.lectureDetails) {
            if (self.activedTimeTable.timeStart == -1 ||
                self.activedTimeTable.timeStart > lectureDetailObject.timeStart) {
                self.activedTimeTable.timeStart = lectureDetailObject.timeStart;
            }
            
            if (self.activedTimeTable.timeEnd == -1 ||
                self.activedTimeTable.timeEnd < lectureDetailObject.timeEnd) {
                self.activedTimeTable.timeEnd = lectureDetailObject.timeEnd;
            }
            
            if (lectureDetailObject.day == 5 || lectureDetailObject.day == 6) {
                self.activedTimeTable.workAtWeekend = YES;
            }
        }
    }
    [_realm commitWriteTransaction];
    
    [self synchronizeUserDefaultWithTimeTable:self.activedTimeTable];
}

#pragma mark - Set Object Attribute

- (void)setActiveWithUtid:(NSInteger)utid
{
    [_realm beginWriteTransaction];
    TimeTableObject *timeTableObject = [TimeTableObject objectsInRealm:_realm where:@"utid == %ld", utid][0];
    RLMResults *timeTableResults = [TimeTableObject allObjectsInRealm:_realm];
    for (TimeTableObject *resultTimeTableObject in timeTableResults) {
        resultTimeTableObject.active = NO;
    }
    timeTableObject.active = YES;
    [_realm commitWriteTransaction];
    
    [self synchronizeUserDefaultWithTimeTable:self.activedTimeTable];
}

#pragma mark - Get Objects

- (RLMArray *)savedServerSemesters
{
    RLMResults *downloadedServerSemesterResult = [ServerSemesterObject allObjectsInRealm:_realm];
    if (!downloadedServerSemesterResult.count) {
        NSLog(@"Downloaded Server Semesters are NOT exist!");
        return nil;
    }
    
    return [DataManager realmArrayFromResult:downloadedServerSemesterResult className:ServerSemesterObjectID];
}

- (RLMArray *)timeTables
{
    RLMResults *timeTableResults = [[TimeTableObject allObjectsInRealm:_realm] sortedResultsUsingProperty:@"utid" ascending:YES];
    if (timeTableResults.count == 0) {
        NSLog(@"TimeTables are NOT exist!");
        return nil;
    }
    
    return [DataManager realmArrayFromResult:timeTableResults className:TimeTableObjectID];
}

- (TimeTableObject *)timeTableWithUtid:(NSInteger)utid
{
    RLMResults *timeTableResults = [TimeTableObject objectsInRealm:_realm where:@"utid == %ld", utid];
    if (timeTableResults.count == 0) {
        NSLog(@"TimeTable (utid : %ld) is NOT exist!", utid);
        return nil;
    }
    return timeTableResults[0];
}

- (RLMArray *)lectureDetailsWithDay:(NSInteger)day
{
    RLMResults *lectureDetailResults = [LectureDetailObject objectsInRealm:_realm where:@"day == %d", day];
    RLMResults *sortedResult = [lectureDetailResults sortedResultsUsingProperty:@"timeStart" ascending:YES];

    RLMArray *lectureDetails = [DataManager realmArrayFromResult:sortedResult className:LectureDetailObjectID];
    
    NSLog(@"%ld", lectureDetails.count);
    for (NSInteger i = 0; i < lectureDetails.count; i++) {
        LectureDetailObject *lectureDetail = lectureDetails[i];
        if (![lectureDetail isContainedWithUtid:self.activedTimeTable.utid]) {
            [lectureDetails removeObjectAtIndex:i--];
        }
    }
    if (lectureDetails.count == 0) {
        NSLog(@"LectureDetails (day : %ld) is NOT exist", day);
        return nil;
    }
    
//    RLMResults *sortedResult = [lectureDetails sortedResultsUsingProperty:@"timeStart" ascending:YES];
    
//    return [DataManager realmArrayFromResult:sortedResult className:LectureDetailObjectID];
    NSLog(@"lectureDetailInDataManager: %@", lectureDetails);
    return lectureDetails;
}

- (LectureObject *)lectureObjectWithUlid:(NSInteger)ulid
{
    RLMResults *lectureResults = [self.activedTimeTable.lectures objectsWhere:@"ulid == %ld", ulid];
    if (lectureResults.count == 0) {
        NSLog(@"Lecture (ulid : %ld) is NOT exist", ulid);
        return nil;
    }
    LectureObject *lectureObject = lectureResults[0];
    return lectureObject;
}

- (RLMArray *)lectureDetailObjectsWithUlid:(NSInteger)ulid
{
    RLMResults *lectureDetailResults = [LectureDetailObject objectsInRealm:_realm where:@"ulid == %ld", ulid];
    if (lectureDetailResults.count == 0) {
        NSLog(@"LectureDetails (ulid : %ld) is NOT exist", ulid);
        return nil;
    }
    return [DataManager realmArrayFromResult:lectureDetailResults className:LectureDetailObjectID];
}

- (LectureObject *)lectureWithUlid:(NSInteger)ulid
{
    RLMResults *lectureResults = [self.activedTimeTable.lectures objectsWhere:@"ulid == %ld", ulid];
    return lectureResults[0];
}

- (NSString *)lectureAreDuplicatedOtherLecture:(LectureObject *)lecture lectureDetails:(RLMArray *)lectureDetails inTimeTable:(TimeTableObject *)timeTable
{
    RLMArray *lectureDetailsInTimeTable = [[RLMArray alloc] initWithObjectClassName:LectureDetailObjectID];
    for (LectureObject *otherLecture in timeTable.lectures) {
        if (otherLecture.ulid == lecture.ulid) {
            continue;
        }
        for (LectureDetailObject *lectureDetail in otherLecture.lectureDetails) {
            [lectureDetailsInTimeTable addObject:lectureDetail];
        }
    }
    
    for (LectureDetailObject *lectureDetail in lectureDetails) {
        for (LectureDetailObject *otherLectureDetail in lectureDetailsInTimeTable) {
            if (lectureDetail.day == otherLectureDetail.day) {
                if (otherLectureDetail.timeStart <= lectureDetail.timeStart &&
                    lectureDetail.timeStart < otherLectureDetail.timeEnd) {
                    return otherLectureDetail.lecture.lectureName;
                }
                if (otherLectureDetail.timeStart < lectureDetail.timeEnd &&
                    lectureDetail.timeEnd <= otherLectureDetail.timeEnd) {
                    return otherLectureDetail.lecture.lectureName;
                }
                if (lectureDetail.timeStart <= otherLectureDetail.timeStart && otherLectureDetail.timeEnd <= lectureDetail.timeEnd) {
                    return otherLectureDetail.lecture.lectureName;
                }
            }
        }
    }
    return nil;
}

- (NSString *)lectureDetailTimeIsEmpty:(LectureObject *)lecture lectureDetails:(RLMArray *)lectureDetails
{
    BOOL isEmpty = NO;
    NSString *errorMessage = @"";
    for (LectureDetailObject *lectureDetail in lectureDetails) {
        errorMessage = [errorMessage stringByAppendingFormat:@"%ld번째 수업의", [lectureDetails indexOfObject:lectureDetail]+1];
        if (lectureDetail.timeStart == -1) {
            isEmpty = YES;
            errorMessage = [errorMessage stringByAppendingString:@" 시작시간"];
        }
        if (lectureDetail.timeEnd == -1) {
            if (isEmpty) {
                errorMessage = [errorMessage stringByAppendingString:@"과"];
            }
            isEmpty = YES;
            errorMessage = [errorMessage stringByAppendingString:@" 종료시간"];
        }
        
        if (!lectureDetail.lectureLocation.length) {
            if (isEmpty) {
                errorMessage = [errorMessage stringByAppendingString:@"과"];
            }
            isEmpty = YES;
            errorMessage = [errorMessage stringByAppendingString:@" 강의실"];
        }
        
        if (isEmpty) {
            errorMessage = [errorMessage stringByAppendingString:@"이 비어있습니다."];
            return errorMessage;
        } else {
            errorMessage = @"";
        }
    }
    return nil;
}

- (NSArray *)daySectionTitles
{
    return (self.activedTimeTable.workAtWeekend) ? @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"] : @[@"월", @"화", @"수", @"목", @"금"];
}

- (BOOL)lecturesIsEmptyInActivedTimeTable
{
    if (self.activedTimeTable.lectures.count != 0)
        return NO;
    return YES;
}

#pragma mark - Getter

- (TimeTableObject *)activedTimeTable
{
    RLMResults *activedTimeTableResults = [TimeTableObject objectsInRealm:_realm where:@"active == YES"];
    if (activedTimeTableResults.count == 0) {
        NSLog(@"Actived TimeTable is NOT exist! (Object)");
        return nil;
    }
    return activedTimeTableResults[0];
}


#pragma mark - Results To Array

+ (RLMArray *)realmArrayFromResult:(RLMResults *)result className:(NSString *)className
{
    RLMArray *array = [[RLMArray alloc] initWithObjectClassName:className];
    for (id object in result) {
        [array addObject:object];
    }
    return array;
}

#pragma mark - Lecture Theme

+ (NSInteger)lectureThemeCount
{
    return 19;
}

+ (NSArray *)lectureThemeThumbnailArray
{
    NSMutableArray *lectureThemeArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [self lectureThemeCount]; i++) {
        [lectureThemeArray addObject:[self lectureThemeThumbnail:i]];
    }
    return lectureThemeArray;
}

+ (UIImage *)lectureThemeThumbnail:(NSInteger)themeId;
{
    return [self thumbnailFromColor:[UIColor op_lectureTheme:themeId]];
}

+ (UIImage *)thumbnailFromColor:(UIColor *)color
{
    UIView *thumbnailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    thumbnailView.layer.cornerRadius = thumbnailView.frame.size.width/2;
    thumbnailView.layer.backgroundColor = color.CGColor;
    CGRect rect = [thumbnailView bounds];
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [thumbnailView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [self imageResize:img andResizeTo:CGSizeMake(30, 30)];
}

+ (UIImage *)imageResize:(UIImage *)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Time Convert Method

+ (NSString *)stringFromTimeInteger:(NSInteger)timeInteger
{
    if (timeInteger == -1) {
        return @"--:--";
    }
    NSInteger hours = timeInteger/100;
    NSInteger minutes = timeInteger%100;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)hours, (long)minutes];
}

+ (NSInteger)integerFromTimeString:(NSString *)timeString
{
    if ([timeString isEqualToString:@"--:--"]) {
        return -1;
    }
    NSArray *timeStringComponents = [timeString componentsSeparatedByString:@":"];
    NSInteger hours = [timeStringComponents[0] integerValue];
    NSInteger minutes = [timeStringComponents[1] integerValue];
    return hours*100 + minutes;
}

#pragma mark - User Default Manage

- (void)synchronizeUserDefaultWithTimeTable:(TimeTableObject *)timeTable
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
    
    [sharedDefaults setObject:[self dictionaryWithTimetable:timeTable] forKey:@"ActivedTimeTable"];
    [sharedDefaults synchronize];
}

- (NSDictionary *)dictionaryWithTimetable:(TimeTableObject *)timetable
{
    NSMutableDictionary *timetableDictionary = [[NSMutableDictionary alloc] init];
    // utid, timeTableName, timeStart, timeEnd, active, workAtWeekend, serverSemesterObject, lectures
    [timetableDictionary setValue:@(timetable.utid) forKey:@"utid"];
    [timetableDictionary setValue:timetable.timeTableName forKey:@"timeTableName"];
    [timetableDictionary setValue:@(timetable.timeStart) forKey:@"timeStart"];
    [timetableDictionary setValue:@(timetable.timeEnd) forKey:@"timeEnd"];
    [timetableDictionary setValue:@(timetable.active) forKey:@"active"];
    [timetableDictionary setValue:@(timetable.workAtWeekend) forKey:@"workAtWeekend"];
    
    NSMutableArray *lectures = [[NSMutableArray alloc] init];
    for (LectureObject *lecture in timetable.lectures) {
        NSMutableDictionary *lectureDictionary = [[NSMutableDictionary alloc] init];
        [lectureDictionary setValue:lecture.lectureName forKey:@"lectureName"];
        [lectureDictionary setValue:@(lecture.ulid) forKey:@"ulid"];
        [lectureDictionary setValue:@(lecture.theme) forKey:@"theme"];
        NSMutableArray *lectureDetails = [[NSMutableArray alloc] init];
        for (LectureDetailObject *lectureDetail in lecture.lectureDetails) {
            NSMutableDictionary *lectureDetailDictionary = [[NSMutableDictionary alloc] init];
            [lectureDetailDictionary setValue:lectureDetail.lectureLocation forKey:@"lectureLocation"];
            [lectureDetailDictionary setValue:@(lectureDetail.timeStart) forKey:@"timeStart"];
            [lectureDetailDictionary setValue:@(lectureDetail.timeEnd) forKey:@"timeEnd"];
            [lectureDetailDictionary setValue:@(lectureDetail.day) forKey:@"day"];
            [lectureDetails addObject:lectureDetailDictionary];
        }
        [lectureDictionary setValue:lectureDetails forKey:@"lectureDetails"];
        [lectures addObject:lectureDictionary];
    }
    [timetableDictionary setValue:lectures forKey:@"lectures"];
    
    return timetableDictionary;
}

@end