//
//  DataManager.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "DataManager.h"

#import <Realm/Realm.h>
#import "ServerSchoolObject.h"
#import "ServerTimeTableObject.h"
#import "ServerLectureObject.h"
#import "TimeTableObject.h"

@interface DataManager ()

@property (nonatomic, strong) RLMRealm *realm;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) TimeTableObject *activedTimeTableObject;

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
        NSLog(@"%@", [LectureObject allObjects]);
    }
    return self;
}

#pragma mark - Save Objects

- (void)saveServerSchoolsWithResponse:(NSArray *)response
{
    [_realm beginWriteTransaction];
    [_realm deleteObjects:[ServerSchoolObject allObjects]];
    for (NSDictionary *schoolDictionary in response) {
        ServerSchoolObject *serverSchoolObject = [[ServerSchoolObject alloc] init];
        serverSchoolObject.schoolId = [schoolDictionary[@"id"] integerValue];
        serverSchoolObject.schoolName = schoolDictionary[@"school_name"];
        
        [_realm addObject:serverSchoolObject];
    }
    [_realm commitWriteTransaction];
}

- (void)saveServerTimeTablesWithResponse:(NSArray *)response
{
    [_realm beginWriteTransaction];
    [_realm deleteObjects:[ServerTimeTableObject allObjects]];
    for (NSDictionary *serverTimeTableDictionary in response) {
        ServerTimeTableObject *serverTimeTableObject = [[ServerTimeTableObject alloc] init];
        serverTimeTableObject.timeTableId = [serverTimeTableDictionary[@"id"] integerValue];
        serverTimeTableObject.schoolId = [serverTimeTableDictionary[@"school_id"] integerValue];
        serverTimeTableObject.semester = serverTimeTableDictionary[@"semester"];
        serverTimeTableObject.updatedAt = [_dateFormatter dateFromString:serverTimeTableDictionary[@"updated_at"]];
        serverTimeTableObject.checkedAt = [NSDate date];
        serverTimeTableObject.downloaded = NO;
        
        [_realm addObject:serverTimeTableObject];
    }
    [_realm commitWriteTransaction];
}

- (void)saveServerLecturesWithResponse:(NSArray *)response update:(void (^)(NSInteger progressIndex))update
{
    NSInteger index = 0;
    [_realm beginWriteTransaction];
    [_realm deleteObjects:[ServerLectureObject allObjects]];
    for (NSDictionary *serverLectureDictionary in response) {
        ServerLectureObject *serverLectureObject = [[ServerLectureObject alloc] init];
        serverLectureObject.lectureCode = serverLectureDictionary[@"lecture_code"];
        serverLectureObject.lectureDaytime = serverLectureDictionary[@"lecture_daytime"];
        serverLectureObject.lectureLocation = serverLectureDictionary[@"lecture_location"];
        serverLectureObject.lectureName = serverLectureDictionary[@"lecture_name"];
        serverLectureObject.lectureCode = serverLectureDictionary[@"lecture_code"];
        serverLectureObject.lectureProf = serverLectureDictionary[@"lecture_prof"];
        serverLectureObject.timeTableId = [serverLectureDictionary[@"timetable_id"] integerValue];
        
        [_realm addObject:serverLectureObject];
        update(++index);
    }
    [_realm commitWriteTransaction];
}

- (void)saveTimeTableWithName:(NSString *)name serverId:(NSInteger)serverId active:(BOOL)active
{
    [_realm beginWriteTransaction];
    TimeTableObject *timeTableObject = [[TimeTableObject alloc] init];
    timeTableObject.timeTableName = name;
    timeTableObject.serverId = serverId;
    
    if (active) {
        RLMResults *timeTableResults = [TimeTableObject allObjects];
        for (TimeTableObject *resultTimeTableObject in timeTableResults) {
            resultTimeTableObject.active = NO;
        }
    }
    
    timeTableObject.active = active;
    timeTableObject.utid = [self lastUtid]+1;
    timeTableObject.timeStart = 800;
    timeTableObject.timeEnd = 2300;
    timeTableObject.mon = YES;
    timeTableObject.tue = YES;
    timeTableObject.wed = YES;
    timeTableObject.thu = YES;
    timeTableObject.fri = YES;
    timeTableObject.sat = YES;
    timeTableObject.sun = YES;
    [_realm addObject:timeTableObject];
    [_realm commitWriteTransaction];
}

- (NSInteger)lastUtid
{
    RLMResults *timeTableResults = [[TimeTableObject allObjects] sortedResultsUsingProperty:@"utid" ascending:NO];
    NSLog(@"%@", timeTableResults);
    if (timeTableResults.count == 0)
        return -1;
    TimeTableObject *lastTimeTableObject = timeTableResults[0];
    return lastTimeTableObject.utid;
}

- (void)updateTimeTableWithUtid:(NSInteger)utid
                         name:(NSString *)name
                     serverId:(NSInteger)serverId
                       active:(BOOL)active
                      failure:(void (^)(NSString *reason))failure
{
    [_realm beginWriteTransaction];
    RLMResults *timeTableResults = [TimeTableObject objectsWhere:@"utid == %ld", utid];
    if (timeTableResults.count == 0) {
        NSString *reason = [NSString stringWithFormat:@"TimeTable (utid : %ld) for edit is NOT exist", utid];
        NSLog(@"%@", reason);
        failure(reason);
        [_realm commitWriteTransaction];
        return;
    }
    TimeTableObject *timeTableObject = timeTableResults[0];
    timeTableObject.timeTableName = name;
    timeTableObject.serverId = serverId;
    timeTableObject.active = active;
    [_realm addOrUpdateObject:timeTableObject];
    [_realm commitWriteTransaction];
}

- (void)saveLectureWithLectureName:(NSString *)lectureName theme:(NSString *)theme lectureDetails:(NSArray *)lectureDetails
{
    [_realm beginWriteTransaction];
    LectureObject *lectureObject = [[LectureObject alloc] init];
    lectureObject.ulid = [self lastUlid]+1;
    lectureObject.lectureName = lectureName;
    lectureObject.theme = theme;
    [self.activedTimeTableObject.lectures addObject:lectureObject];
    [_realm commitWriteTransaction];
    for (NSDictionary *lectureDetailDictionary in lectureDetails) {
        [self saveLectureDetailWithUlid:lectureObject.ulid
                        lectureLocation:lectureDetailDictionary[@"lectureLocation"]
                                timeEnd:[lectureDetailDictionary[@"timeEnd"] integerValue]
                              timeStart:[lectureDetailDictionary[@"timeStart"] integerValue]
                                    day:[lectureDetailDictionary[@"day"] integerValue]];
    }
}

- (NSInteger)lastUlid
{
    RLMResults *lectureResults = [self.activedTimeTableObject.lectures sortedResultsUsingProperty:@"ulid" ascending:NO];
    if (lectureResults.count == 0)
        return -1;
    LectureObject *lastLectureObject = lectureResults[0];
    return lastLectureObject.ulid;
}

- (void)saveLectureDetailWithUlid:(NSInteger)ulid lectureLocation:(NSString *)lectureLocation timeEnd:(NSInteger)timeEnd timeStart:(NSInteger)timeStart day:(NSInteger)day
{
    [_realm beginWriteTransaction];
    LectureObject *lectureObject = [self lectureObjectWithUlid:ulid];
    LectureDetailObject *lectureDetailObject = [[LectureDetailObject alloc] init];
    lectureDetailObject.ulid = ulid;
    lectureDetailObject.lectureLocation = lectureLocation;
    lectureDetailObject.timeEnd = timeEnd;
    lectureDetailObject.timeStart = timeStart;
    lectureDetailObject.day = day;
    [lectureObject.lectureDetails addObject:lectureDetailObject];
    [_realm commitWriteTransaction];
}

#pragma mark - Delete Object in Realm

- (void)deleteTimeTableWithUtid:(NSInteger)utid
{
    [_realm beginWriteTransaction];
    RLMResults *timeTableObjectToDeleteResult = [TimeTableObject objectsWhere:@"utid == %ld", utid];
    TimeTableObject *timeTableObjectToDelete = timeTableObjectToDeleteResult[0];
    for (LectureObject *lectureObject in timeTableObjectToDelete.lectures) {
        [_realm deleteObjects:lectureObject.lectureDetails];
    }
    [_realm deleteObjects:timeTableObjectToDelete.lectures];
    [_realm deleteObject:timeTableObjectToDelete];
    [_realm commitWriteTransaction];
}

- (void)deleteLectureWithUlid:(NSInteger)ulid
{
    [_realm beginWriteTransaction];
    RLMResults *lectureObjectToDeleteResult = [LectureObject objectsWhere:@"ulid == %ld", ulid];
    LectureObject *lectureObjectToDelete = lectureObjectToDeleteResult[0];
    [_realm deleteObjects:lectureObjectToDelete.lectureDetails];
    [_realm deleteObject:lectureObjectToDelete];
    [_realm commitWriteTransaction];
}

#pragma mark - Set Object Attribute

- (void)setDownloadedWithTimeTableId:(NSInteger)timeTableId
{
    RLMResults *serverTimeTables = [ServerTimeTableObject objectsWhere:[NSString stringWithFormat:@"timeTableId == %ld", timeTableId]];
    if (serverTimeTables.count == 0) {
        NSLog(@"TimeTable (timeTableId : %ld) to set 'downloaded' is NOT exist!", timeTableId);
        return;
    }
    ServerTimeTableObject *timeTableObject = serverTimeTables[0];
    timeTableObject.downloaded = YES;
}

#pragma mark - Get Objects

- (NSArray *)downloadedTimeTables
{
    RLMResults *downloadedTimeTables = [ServerTimeTableObject objectsWhere:[NSString stringWithFormat:@"downloaded == YES"]];
    if (downloadedTimeTables.count == 0) {
        NSLog(@"Downloaded TimeTables are NOT exist!");
        return nil;
    }
    return [self arrayWithServerTimeTableResults:downloadedTimeTables];
}

- (NSArray *)serverTimeTablesWithSchoolId:(NSInteger)schoolId;
{
    RLMResults *serverTimeTables = [ServerTimeTableObject objectsWhere:[NSString stringWithFormat:@"schoolId == %ld", schoolId]];
    if (serverTimeTables.count == 0) {
        NSLog(@"Server TimeTable (schoolId : %ld) is NOT exist!", schoolId);
        return nil;
    }
    return [self arrayWithServerTimeTableResults:serverTimeTables];
}

- (NSArray *)schools
{
    RLMResults *schoolResults = [ServerSchoolObject allObjects];
    if (schoolResults.count == 0) {
        NSLog(@"Schools are NOT exist!");
        return nil;
    }
    return [self arrayWithSchoolResults:schoolResults];
}

- (NSDictionary *)serverTimeTableWithId:(NSInteger)serverTimeTableId
{
    RLMResults *serverTimeTableResults = [ServerTimeTableObject objectsWhere:[NSString stringWithFormat:@"timeTableId == %ld", serverTimeTableId]];
    if (serverTimeTableResults.count == 0) {
        NSLog(@"Server TimeTable (timeTableId : %ld) is NOT exist!", serverTimeTableId);
        return nil;
    }
    return [self arrayWithServerTimeTableResults:serverTimeTableResults][0];
}

- (NSArray *)timeTables
{
    RLMResults *timeTableResults = [[TimeTableObject allObjects] sortedResultsUsingProperty:@"utid" ascending:YES];
    if (timeTableResults.count == 0) {
        NSLog(@"TimeTables are NOT exist!");
        return nil;
    }
    return [self arrayWithTimeTableResults:timeTableResults];
}

- (NSDictionary *)timeTableWithId:(NSInteger)timeTableId
{
    RLMResults *timeTableResults = [TimeTableObject objectsWhere:@"utid == %ld", timeTableId];
    if (timeTableResults.count == 0) {
        NSLog(@"TimeTable (utid : %ld) is NOT exist!", timeTableId);
        return nil;
    }
    return [self arrayWithTimeTableResults:timeTableResults][0];
}

- (NSArray *)serverLecturesWithServerTimeTableId:(NSInteger)serverTimeTableId
{
    RLMResults *serverLectureResults = [ServerLectureObject objectsWhere:[NSString stringWithFormat:@"timeTableId == %ld", serverTimeTableId]];
    if (serverLectureResults.count == 0) {
        NSLog(@"Server Lectures (timeTableId : %ld) are NOT exist!", serverTimeTableId);
        return nil;
    }
    return [self arrayWithServerLectureResults:serverLectureResults];
}


- (NSString *)schoolNameWithServerTimeTableId:(NSInteger)timeTableId
{
    RLMResults *serverTimeTableResults = [ServerTimeTableObject objectsWhere:[NSString stringWithFormat:@"timeTableId == %ld", timeTableId]];
    if (serverTimeTableResults.count == 0) {
        NSLog(@"Server TimeTable (timeTableId : %ld) for School Name is NOT exist!", timeTableId);
        return @"";
    }
    ServerTimeTableObject *serverTimeTableObject = serverTimeTableResults[0];
    RLMResults *serverSchoolResults = [ServerSchoolObject objectsWhere:[NSString stringWithFormat:@"schoolId == %ld", serverTimeTableObject.schoolId]];
    if (serverSchoolResults.count == 0) {
        NSLog(@"Server School (schoolId : %ld) for School Name is NOT exist!", serverTimeTableObject.schoolId);
        return @"";
    }
    ServerSchoolObject *serverSchoolObject = serverSchoolResults[0];
    return serverSchoolObject.schoolName;
}

- (NSString *)semesterString:(NSString *)semester
{
    NSArray *titleArray = [semester componentsSeparatedByString:@"-0"];
    return [NSString stringWithFormat:@"%@년 %@학기", titleArray[0], titleArray[1]];
}

- (NSArray *)lectureDetailsWithDay:(NSInteger)day
{
    NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    for (LectureObject *lectureObject in self.activedTimeTableObject.lectures) {
        RLMResults *lecturesResults = [lectureObject.lectureDetails objectsWhere:@"day == %d", day];
        if (lecturesResults.count != 0) [resultsArray addObject:lecturesResults];
    }
    if (resultsArray.count == 0) {
        NSLog(@"LectureDetails (day : %ld) is NOT exist", day);
        return nil;
    }
    return [self arrayWithLectureDetailResulstArray:resultsArray];
}

- (LectureObject *)lectureObjectWithUlid:(NSInteger)ulid
{
    RLMResults *lectureResults = [self.activedTimeTableObject.lectures objectsWhere:@"ulid == %ld", ulid];
    if (lectureResults.count == 0) {
        NSLog(@"Lecture (ulid : %ld) is NOT exist", ulid);
        return nil;
    }
    LectureObject *lectureObject = lectureResults[0];
    return lectureObject;
}

#pragma mark - Getter

- (TimeTableObject *)activedTimeTableObject
{
    RLMResults *activedTimeTableResults = [TimeTableObject objectsWhere:[NSString stringWithFormat:@"active == YES"]];
    if (activedTimeTableResults.count == 0) {
        NSLog(@"Actived TimeTable is NOT exist! (Object)");
        return nil;
    }
    return activedTimeTableResults[0];
}

- (NSDictionary *)activedTimeTable
{
    RLMResults *activedTimeTableResults = [TimeTableObject objectsWhere:[NSString stringWithFormat:@"active == YES"]];
    if (activedTimeTableResults.count == 0) {
        NSLog(@"Actived TimeTable is NOT exist! (Dictionary)");
        return nil;
    }
    return [self arrayWithTimeTableResults:activedTimeTableResults][0];
}

#pragma mark - Results To Array

- (NSArray *)arrayWithServerTimeTableResults:(RLMResults *)result
{
    NSMutableArray *arrayForReturn = [[NSMutableArray alloc] init];
    for (ServerTimeTableObject *serverTimeTableObject in result) {
        NSMutableDictionary *serverTimeTableDictionary = [[NSMutableDictionary alloc] init];
        serverTimeTableDictionary[@"timeTableId"] = @(serverTimeTableObject.timeTableId);
        serverTimeTableDictionary[@"schoolId"] = @(serverTimeTableObject.schoolId);
        serverTimeTableDictionary[@"semester"] = serverTimeTableObject.semester;
        serverTimeTableDictionary[@"updatedAt"] = serverTimeTableObject.updatedAt;
        serverTimeTableDictionary[@"checkedAt"] = serverTimeTableObject.checkedAt;
        serverTimeTableDictionary[@"downloaded"] = @(serverTimeTableObject.downloaded);
        [arrayForReturn addObject:serverTimeTableDictionary];
    }
    return arrayForReturn;
}

- (NSArray *)arrayWithSchoolResults:(RLMResults *)result
{
    NSMutableArray *arrayForReturn = [[NSMutableArray alloc] init];
    for (ServerSchoolObject *schoolObject in result) {
        NSMutableDictionary *schoolDictionary = [[NSMutableDictionary alloc] init];
        schoolDictionary[@"schoolId"] = @(schoolObject.schoolId);
        schoolDictionary[@"schoolName"] = schoolObject.schoolName;
        [arrayForReturn addObject:schoolDictionary];
    }
    return arrayForReturn;
}

- (NSArray *)arrayWithTimeTableResults:(RLMResults *)result
{
    NSMutableArray *arrayForReturn = [[NSMutableArray alloc] init];
    for (TimeTableObject *timeTableObject in result) {
        NSMutableDictionary *timeTableDictionary = [[NSMutableDictionary alloc] init];
        timeTableDictionary[@"utid"] = @(timeTableObject.utid);
        timeTableDictionary[@"timeTableName"] = timeTableObject.timeTableName;
        timeTableDictionary[@"serverId"] = @(timeTableObject.serverId);
        timeTableDictionary[@"timeStart"] = @(timeTableObject.timeStart);
        timeTableDictionary[@"timeEnd"] = @(timeTableObject.timeEnd);
        timeTableDictionary[@"lectures"] = [self arrayWithLectureArray:timeTableObject.lectures];
        timeTableDictionary[@"active"] = @(timeTableObject.active);
        timeTableDictionary[@"mon"] = @(timeTableObject.mon);
        timeTableDictionary[@"tue"] = @(timeTableObject.tue);
        timeTableDictionary[@"wed"] = @(timeTableObject.wed);
        timeTableDictionary[@"thu"] = @(timeTableObject.thu);
        timeTableDictionary[@"fri"] = @(timeTableObject.fri);
        timeTableDictionary[@"sat"] = @(timeTableObject.sat);
        timeTableDictionary[@"sun"] = @(timeTableObject.sun);
        [arrayForReturn addObject:timeTableDictionary];
    }
    return arrayForReturn;
}

- (NSArray *)arrayWithLectureArray:(RLMArray *)lectures
{
    NSMutableArray *arrayForReturn = [[NSMutableArray alloc] init];
    for (LectureObject *lectureObject in lectures) {
        NSMutableDictionary *lectureDictionary = [[NSMutableDictionary alloc] init];
        lectureDictionary[@"ulid"] = @(lectureObject.ulid);
        lectureDictionary[@"lectureName"] = lectureObject.lectureName;
        lectureDictionary[@"lectureDetails"] = [self arrayWithLectureDetailArray:lectureObject.lectureDetails];
        lectureDictionary[@"theme"] = lectureObject.theme;
        [arrayForReturn addObject:lectureDictionary];
    }
    return arrayForReturn;
}

- (NSArray *)arrayWithLectureDetailResulstArray:(NSArray *)resultsArray
{
    NSMutableArray *arrayForReturn = [[NSMutableArray alloc] init];
    for (RLMResults *lectureDetailResults in resultsArray) {
        for (LectureDetailObject *lectureDetailObject in lectureDetailResults) {
            NSMutableDictionary *lectureDetailDictionary = [[NSMutableDictionary alloc] init];
            LectureObject *lectureObject = [self lectureObjectWithUlid:lectureDetailObject.ulid];
            lectureDetailDictionary[@"ulid"] = @(lectureDetailObject.ulid);
            lectureDetailDictionary[@"lectureLocation"] = lectureDetailObject.lectureLocation;
            lectureDetailDictionary[@"timeStart"] = @(lectureDetailObject.timeStart);
            lectureDetailDictionary[@"timeEnd"] = @(lectureDetailObject.timeEnd);
            lectureDetailDictionary[@"lectureName"] = lectureObject.lectureName;
            lectureDetailDictionary[@"theme"] = lectureObject.theme;
            [arrayForReturn addObject:lectureDetailDictionary];
        }
    }
    return arrayForReturn;
}

- (NSArray *)arrayWithLectureDetailArray:(RLMArray *)lectureDetails
{
    NSMutableArray *arrayForReturn = [[NSMutableArray alloc] init];
    for (LectureDetailObject *lectureDetailObject in lectureDetails) {
        NSMutableDictionary *lectureDetailDictionary = [[NSMutableDictionary alloc] init];
        lectureDetailDictionary[@"ulid"] = @(lectureDetailObject.ulid);
        lectureDetailDictionary[@"lectureLocation"] = lectureDetailObject.lectureLocation;
        lectureDetailDictionary[@"timeStart"] = @(lectureDetailObject.timeStart);
        lectureDetailDictionary[@"timeEnd"] = @(lectureDetailObject.timeEnd);
        lectureDetailDictionary[@"day"] = @(lectureDetailObject.day);
        [arrayForReturn addObject:lectureDetailDictionary];
    }
    return arrayForReturn;
}

- (NSArray *)arrayWithServerLectureResults:(RLMResults *)result
{
    NSMutableArray *arrayForReturn = [[NSMutableArray alloc] init];
    for (ServerLectureObject *serverLectureObject in result) {
        NSMutableDictionary *serverLectureDictionary = [[NSMutableDictionary alloc] init];
        serverLectureDictionary[@"timeTableId"] = @(serverLectureObject.timeTableId);
        serverLectureDictionary[@"lectureProf"] = serverLectureObject.lectureProf;
        serverLectureDictionary[@"lectureCode"] = serverLectureObject.lectureCode;
        serverLectureDictionary[@"lectureName"] = serverLectureObject.lectureName;
        serverLectureDictionary[@"lectureLocation"] = serverLectureObject.lectureLocation;
        serverLectureDictionary[@"lectureDaytime"] = serverLectureObject.lectureDaytime;
        [arrayForReturn addObject:serverLectureDictionary];
    }
    return arrayForReturn;
}

#pragma mark - Time Convert Method

+ (NSString *)stringFromTimeInteger:(NSInteger)timeInteger
{
    NSInteger hours = timeInteger/100;
    NSInteger minutes = timeInteger%100;
    return [NSString stringWithFormat:@"%ld:%02ld", hours, minutes];
}

+ (NSInteger)integerFromTimeString:(NSString *)timeString
{
    NSArray *timeStringComponents = [timeString componentsSeparatedByString:@":"];
    NSInteger hours = [timeStringComponents[0] integerValue];
    NSInteger minutes = [timeStringComponents[1] integerValue];
    return hours*100 + minutes;
}

@end