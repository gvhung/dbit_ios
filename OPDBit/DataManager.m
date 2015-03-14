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
        _activedTimeTable = [self getActivedTimeTable];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        _realm = [RLMRealm defaultRealm];
    }
    return self;
}

- (void)reloadActivedTimeTable
{
    self.activedTimeTable = [self getActivedTimeTable];
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
    self.activedTimeTable = [self getActivedTimeTable];
}

- (NSInteger)lastUtid
{
    RLMResults *timeTableResults = [[TimeTableObject allObjects] sortedResultsUsingProperty:@"utid" ascending:NO];
    if (timeTableResults.count == 0)
        return 0;
    TimeTableObject *lastTimeTableObject = timeTableResults[0];
    return lastTimeTableObject.utid;
}

#pragma mark - Set Object Attribute

- (void)setDownloadedWithTimeTableId:(NSInteger)timeTableId
{
    RLMResults *serverTimeTables = [ServerTimeTableObject objectsWhere:[NSString stringWithFormat:@"timeTableId == %ld", timeTableId]];
    ServerTimeTableObject *timeTableObject = serverTimeTables[0];
    timeTableObject.downloaded = YES;
}

#pragma mark - Get Objects

- (NSArray *)getDownloadedTimeTables
{
    RLMResults *downloadedTimeTables = [ServerTimeTableObject objectsWhere:[NSString stringWithFormat:@"downloaded == YES"]];
    return [self arrayWithServerTimeTableResults:downloadedTimeTables];
}

- (NSArray *)getServerTimeTablesWithSchoolId:(NSInteger)schoolId;
{
    RLMResults *serverTimeTables = [ServerTimeTableObject objectsWhere:[NSString stringWithFormat:@"schoolId == %ld", schoolId]];
    return [self arrayWithServerTimeTableResults:serverTimeTables];
}

- (NSArray *)getSchools
{
    RLMResults *schoolResults = [ServerSchoolObject allObjects];
    return [self arrayWithSchoolResults:schoolResults];
}

- (NSDictionary *)getServerTimeTableWithId:(NSInteger)timeTableId
{
    RLMResults *serverTimeTableResults = [ServerTimeTableObject objectsWhere:[NSString stringWithFormat:@"timeTableId == %ld", timeTableId]];
    return [self arrayWithServerTimeTableResults:serverTimeTableResults][0];
}

- (NSArray *)getTimeTables;
{
    RLMResults *timeTableResults = [TimeTableObject allObjects];
    return [self arrayWithTimeTableResults:timeTableResults];
}

- (NSArray *)getServerLecturesWithServerTimeTableId:(NSInteger)serverTimeTableId
{
    RLMResults *serverLectureResults = [ServerLectureObject objectsWhere:[NSString stringWithFormat:@"timeTableId == %ld", serverTimeTableId]];
    return [self arrayWithServerLectureResults:serverLectureResults];
}


- (NSString *)getSchoolNameWithServerTimeTableId:(NSInteger)timeTableId
{
    RLMResults *serverTimeTableResults = [ServerTimeTableObject objectsWhere:[NSString stringWithFormat:@"timeTableId == %ld", timeTableId]];
    ServerTimeTableObject *serverTimeTableObject = serverTimeTableResults[0];
    RLMResults *serverSchoolResults = [ServerSchoolObject objectsWhere:[NSString stringWithFormat:@"schoolId == %ld", serverTimeTableObject.schoolId]];
    ServerSchoolObject *serverSchoolObject = serverSchoolResults[0];
    return serverSchoolObject.schoolName;
}

- (NSDictionary *)getActivedTimeTable
{
    RLMResults *activedTimeTableResults = [TimeTableObject objectsWhere:[NSString stringWithFormat:@"active == YES"]];
    if (activedTimeTableResults.count == 0) return nil;
    return [self arrayWithTimeTableResults:activedTimeTableResults][0];
}

- (NSString *)getSemesterString:(NSString *)semester
{
    NSArray *titleArray = [semester componentsSeparatedByString:@"-0"];
    return [NSString stringWithFormat:@"%@년 %@학기", titleArray[0], titleArray[1]];
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

- (NSArray *)arrayWithLectureDetailArray:(RLMArray *)lectureDetails
{
    NSMutableArray *arrayForReturn = [[NSMutableArray alloc] init];
    for (LectureDetailObject *lectureDetailObject in lectureDetails) {
        NSMutableDictionary *lectureDetailDictionary = [[NSMutableDictionary alloc] init];
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

@end