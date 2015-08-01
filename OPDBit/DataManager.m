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

#define REALMPATH @"VERSION2.realm"

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

- (void)migrateV1toV2
{
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:[RLMRealm defaultRealmPath]
            withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
//                @property NSInteger semesterID;
//                @property NSString *lectureName;
//                @property NSString *lectureKey;    // lectureCode 학수번호
//                @property NSString *lectureProf;
//                @property NSString *lectureLocation;
//                @property NSString *lectureDaytime;
//                
//                // Addtional Meta Data
//                @property NSString *lectureCourse;
//                @property NSString *lectureType;
//                @property NSString *lectureEtc;
//                @property NSString *lectureLanguage;
//                @property NSInteger lecturePoint;
//                @property NSInteger serverLectureID;
    }];
}

- (id)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        _realm = [RLMRealm realmWithPath:REALMPATH];
    }
    return self;
}

#pragma mark - Save Objects

- (void)saveServerSemestersWithResponse:(NSArray *)response
                             completion:(void (^)())completion
{
    [_realm beginWriteTransaction];
    [_realm deleteObjects:[ServerSemesterObject allObjectsInRealm:_realm]];
    for (NSDictionary *serverSemesterResponse in response) {
        ServerSemesterObject *serverSemesterObject = [[ServerSemesterObject alloc] init];
        
        serverSemesterObject.semesterVersion = [serverSemesterResponse[@"version"] integerValue];
        serverSemesterObject.semesterID = [serverSemesterResponse[@"id"] integerValue];
        serverSemesterObject.semesterKey = serverSemesterResponse[@"key"];
        serverSemesterObject.semesterName = serverSemesterResponse[@"name"];
        
        [_realm addObject:serverSemesterObject];
    }
    [_realm commitWriteTransaction];
    completion();
}

- (void)saveServerLecturesWithResponse:(NSArray *)response
                            semesterID:(NSInteger)semesterID
                            completion:(void (^)())completion
{
    [_realm beginWriteTransaction];
    [_realm deleteObjects:[ServerLectureObject objectsInRealm:_realm where:@"semesterID == %ld", semesterID]];
    for (NSDictionary *serverLectureDictionary in response) {
        ServerLectureObject *serverLectureObject = [[ServerLectureObject alloc] init];
        
        serverLectureObject.semesterID = [serverLectureDictionary[@"semester_id"] integerValue];
        serverLectureObject.lectureDaytime = serverLectureDictionary[@"lecture_daytime"];
        serverLectureObject.lectureLocation = serverLectureDictionary[@"lecture_location"];
        serverLectureObject.lectureName = serverLectureDictionary[@"lecture_name"];
        serverLectureObject.lectureKey = serverLectureDictionary[@"lecture_key"];
        serverLectureObject.lectureProf = serverLectureDictionary[@"lecture_prof"];
        
        serverLectureObject.lectureCourse = serverLectureDictionary[@""];
        
        
        [_realm addObject:serverLectureObject];
    }
    [_realm commitWriteTransaction];
    completion();
}

- (void)saveTimeTableWithName:(NSString *)name
                   semesterID:(NSInteger)semesterID
                       active:(BOOL)active
{
    [_realm beginWriteTransaction];
    TimeTableObject *timeTableObject = [[TimeTableObject alloc] init];
    timeTableObject.timeTableName = name;
    timeTableObject.semesterID = semesterID;
    
    if (active) {
        RLMResults *timeTableResults = [TimeTableObject allObjectsInRealm:_realm];
        for (TimeTableObject *resultTimeTableObject in timeTableResults) {
            resultTimeTableObject.active = NO;
        }
    }
    
    timeTableObject.active = active;
    timeTableObject.utid = [self lastUtid]+1;
    timeTableObject.timeStart = -1;
    timeTableObject.timeEnd = -1;
    timeTableObject.workAtWeekend = NO;
    
    [_realm addObject:timeTableObject];
    [_realm commitWriteTransaction];
    
    [self synchronizeUserDefaultWithTimeTable:self.activedTimeTable];
}

- (void)saveLectureWithLectureName:(NSString *)lectureName
                             theme:(NSInteger)theme
                    lectureDetails:(RLMArray *)lectureDetails
{
    [_realm beginWriteTransaction];
    LectureObject *lectureObject = [[LectureObject alloc] init];
    lectureObject.ulid = [self lastUlid]+1;
    lectureObject.lectureName = lectureName;
    lectureObject.theme = theme;
    [lectureObject.lectureDetails removeAllObjects];
    [lectureObject.lectureDetails addObjects:lectureDetails];
    
    [self.activedTimeTable.lectures addObject:lectureObject];
    [_realm commitWriteTransaction];
    
    [self synchronizeUserDefaultWithTimeTable:self.activedTimeTable];
}

- (void)saveLectureDetailWithUlid:(NSInteger)ulid
                  lectureLocation:(NSString *)lectureLocation
                          timeEnd:(NSInteger)timeEnd
                        timeStart:(NSInteger)timeStart
                              day:(NSInteger)day
{
    [_realm beginWriteTransaction];
    LectureObject *lectureObject = [self lectureObjectWithUlid:ulid];
    LectureDetailObject *lectureDetailObject = [[LectureDetailObject alloc] init];
    lectureDetailObject.lectureLocation = lectureLocation;
    lectureDetailObject.timeEnd = timeEnd;
    lectureDetailObject.timeStart = timeStart;
    lectureDetailObject.day = day;
    [lectureObject.lectureDetails addObject:lectureDetailObject];
    [_realm commitWriteTransaction];
    
    [self refreshTimeTableSetting];
}

- (void)updateTimeTableWithUtid:(NSInteger)utid
                           name:(NSString *)name
                     semesterID:(NSInteger)semesterID
                         active:(BOOL)active
                        failure:(void (^)(NSString *reason))failure
{
    [_realm beginWriteTransaction];
    RLMResults *timeTableResults = [TimeTableObject objectsInRealm:_realm where:@"utid == %ld", utid];
    if (timeTableResults.count == 0) {
        NSString *reason = [NSString stringWithFormat:@"TimeTable (utid : %ld) for edit is NOT exist", utid];
        NSLog(@"%@", reason);
        failure(reason);
        [_realm commitWriteTransaction];
        return;
    }
    TimeTableObject *timeTableObject = timeTableResults[0];
    timeTableObject.timeTableName = name;
    timeTableObject.semesterID = semesterID;
    if (active) {
        RLMResults *timeTableResults = [TimeTableObject allObjectsInRealm:_realm];
        for (TimeTableObject *resultTimeTableObject in timeTableResults) {
            resultTimeTableObject.active = NO;
        }
    }
    
    timeTableObject.active = active;
    [_realm addOrUpdateObject:timeTableObject];
    [_realm commitWriteTransaction];
    
    [self synchronizeUserDefaultWithTimeTable:self.activedTimeTable];
}

- (void)updateLectureWithUlid:(NSInteger)ulid
                         name:(NSString *)name
                        theme:(NSInteger)theme
               lectureDetails:(RLMArray *)lectureDetails;
{
    [_realm beginWriteTransaction];
    RLMResults *lectureObjectResult = [LectureObject objectsInRealm:_realm where:@"ulid == %ld", ulid];
    LectureObject *lectureObject = [lectureObjectResult firstObject];
    lectureObject.lectureName = name;
    lectureObject.theme = theme;
    [lectureObject.lectureDetails removeAllObjects];
    [lectureObject.lectureDetails addObjects:lectureDetails];
    
    [_realm addOrUpdateObject:lectureObject];
    [_realm commitWriteTransaction];
    
    [self synchronizeUserDefaultWithTimeTable:self.activedTimeTable];
}

#pragma mark - Delete Object in Realm

//- (void)deleteLectureWithUlid:(NSInteger)ulid;

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
        RLMResults *lectureDetailResults = [lectureObject.lectureDetails objectsWhere:@"ulid == %ld", lectureObject.ulid];
        for (LectureDetailObject *lectureDetailObject in lectureDetailResults) {
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
}

#pragma mark - Get Objects

- (RLMArray *)timeTables
{
    RLMResults *timeTableResults = [[TimeTableObject allObjectsInRealm:_realm] sortedResultsUsingProperty:@"utid" ascending:YES];
    if (timeTableResults.count == 0) {
        NSLog(@"TimeTables are NOT exist!");
        return nil;
    }
    
    return [self realmArrayFromResult:timeTableResults className:TimeTableObjectID];
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

- (RLMArray *)serverLecturesWithSemesterID:(NSInteger)semesterID
{
    RLMResults *serverLectureResults = [ServerLectureObject objectsInRealm:_realm where:@"semesterID == %ld", semesterID];
    if (serverLectureResults.count == 0) {
        NSLog(@"Server Lectures (timeTableId : %ld) are NOT exist!", semesterID);
        return nil;
    }
    return [self realmArrayFromResult:serverLectureResults className:ServerLectureObjectID];
}

- (RLMArray *)lectureDetailsWithDay:(NSInteger)day
{
    RLMArray *lectureDetails = [[RLMArray alloc] initWithObjectClassName:LectureDetailObjectID];
    
    for (LectureObject *lectureObject in self.activedTimeTable.lectures) {
        RLMResults *lecturesResults = [lectureObject.lectureDetails objectsWhere:@"day == %d", day];
        for (LectureDetailObject *lectureDetail in lecturesResults) {
            [lectureDetails addObject:lectureDetail];
        }
    }
    if (lectureDetails.count == 0) {
        NSLog(@"LectureDetails (day : %ld) is NOT exist", day);
        return nil;
    }
    
    RLMResults *sortedResult = [lectureDetails sortedResultsUsingProperty:@"timeStart" ascending:YES];
    
    return [self realmArrayFromResult:sortedResult className:LectureDetailObjectID];
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
    return [self realmArrayFromResult:lectureDetailResults className:LectureDetailObjectID];
}

- (LectureObject *)lectureWithUlid:(NSInteger)ulid
{
    RLMResults *lectureResults = [self.activedTimeTable.lectures objectsWhere:@"ulid == %ld", ulid];
    return lectureResults[0];
}

- (BOOL)lectureDetailsAreDuplicatedOtherLectureDetails:(RLMArray *)lectureDetails
{
    for (LectureDetailObject *lectureDetailObject in lectureDetails) {
        RLMResults *sameDayObjectResult = [LectureDetailObject objectsInRealm:_realm
                                                                        where:@"day == %ld", lectureDetailObject.day];
        RLMResults *containedTimeStartObjectResult = [sameDayObjectResult objectsWhere:@"timeStart <= %ld && %ld < timeEnd", lectureDetailObject.timeStart, lectureDetailObject.timeStart];
        if (containedTimeStartObjectResult) {
            return YES;
        }
        RLMResults *containedTimeEndObjectResult = [sameDayObjectResult objectsWhere:@"timetart < %ld && %ld <= timeEnd", lectureDetailObject.timeEnd, lectureDetailObject.timeEnd];
        if (containedTimeEndObjectResult.count) {
            return YES;
        }
    }
    return NO;
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

- (RLMArray *)realmArrayFromResult:(RLMResults *)result className:(NSString *)className
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
    NSInteger hours = timeInteger/100;
    NSInteger minutes = timeInteger%100;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)hours, (long)minutes];
}

+ (NSInteger)integerFromTimeString:(NSString *)timeString
{
    NSArray *timeStringComponents = [timeString componentsSeparatedByString:@":"];
    NSInteger hours = [timeStringComponents[0] integerValue];
    NSInteger minutes = [timeStringComponents[1] integerValue];
    return hours*100 + minutes;
}

#pragma mark - User Default Manage

- (void)synchronizeUserDefaultWithTimeTable:(TimeTableObject *)timeTable
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
    
    [sharedDefaults setObject:timeTable forKey:@"ActivedTimeTable"];
    [sharedDefaults synchronize];
}

@end