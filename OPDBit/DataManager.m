//
//  DataManager.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "DataManager.h"

#import <Realm/Realm.h>
#import "ServerLectureObject.h"
#import "TimeTableObject.h"

#import "UIColor+OPTheme.h"

#define REALMPATH @"VERSION2.realm"

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

- (void)migrateV1toV2
{
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:[RLMRealm defaultRealmPath]
            withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
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

- (void)saveServerTimeTablesWithResponse:(NSArray *)response
{
    [_realm beginWriteTransaction];
    for (NSDictionary *serverTimeTableDictionary in response) {
        [_realm deleteObjects:[ServerTimeTableObject objectsWhere:@"timeTableId == %ld", [serverTimeTableDictionary[@"id"] integerValue]]];
        ServerTimeTableObject *serverTimeTableObject = [[ServerTimeTableObject alloc] init];
        serverTimeTableObject.timeTableId = [serverTimeTableDictionary[@"id"] integerValue];
        serverTimeTableObject.schoolId = [serverTimeTableDictionary[@"school_id"] integerValue];
        serverTimeTableObject.semester = serverTimeTableDictionary[@"semester"];
        serverTimeTableObject.updatedAt = [_dateFormatter dateFromString:serverTimeTableDictionary[@"updated_at"]];
        serverTimeTableObject.checkedAt = [NSDate date];
        
        [_realm addObject:serverTimeTableObject];
    }
    [_realm commitWriteTransaction];
}

- (void)saveServerLecturesWithResponse:(NSArray *)response serverTimeTableId:(NSInteger)serverTimeTableId update:(void (^)(NSInteger progressIndex))update
{
    NSInteger index = 0;
    [_realm beginWriteTransaction];
    [_realm deleteObjects:[ServerLectureObject objectsWhere:@"timeTableId == %ld", serverTimeTableId]];
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
        RLMResults *timeTableResults = [TimeTableObject allObjectsInRealm:_realm];
        for (TimeTableObject *resultTimeTableObject in timeTableResults) {
            resultTimeTableObject.active = NO;
        }
    }
    
    timeTableObject.active = active;
    timeTableObject.utid = [self lastUtid]+1;
    timeTableObject.timeStart = -1;
    timeTableObject.timeEnd = -1;
    timeTableObject.mon = YES;
    timeTableObject.tue = YES;
    timeTableObject.wed = YES;
    timeTableObject.thu = YES;
    timeTableObject.fri = YES;
    timeTableObject.sat = NO;
    timeTableObject.sun = NO;
    [_realm addObject:timeTableObject];
    [_realm commitWriteTransaction];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
    
    [sharedDefaults setObject:self.activedTimeTable forKey:@"ActivedTimeTable"];
    [sharedDefaults synchronize];
}

- (NSInteger)lastUtid
{
    RLMResults *timeTableResults = [[TimeTableObject allObjectsInRealm:_realm] sortedResultsUsingProperty:@"utid" ascending:NO];
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
    
    if (active) {
        RLMResults *timeTableResults = [TimeTableObject allObjectsInRealm:_realm];
        for (TimeTableObject *resultTimeTableObject in timeTableResults) {
            resultTimeTableObject.active = NO;
        }
    }
    
    timeTableObject.active = active;
    [_realm addOrUpdateObject:timeTableObject];
    [_realm commitWriteTransaction];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
    
    [sharedDefaults setObject:self.activedTimeTable forKey:@"ActivedTimeTable"];
    [sharedDefaults synchronize];
}

- (void)updateLectureWithUlid:(NSInteger)ulid
                         name:(NSString *)name
                        theme:(NSInteger)theme
               lectureDetails:(NSArray *)lectureDetails
{
    [self deleteLectureWithUlid:ulid];
    [self saveLectureWithLectureName:name theme:theme lectureDetails:lectureDetails ulid:ulid];
}

- (void)saveLectureWithLectureName:(NSString *)lectureName theme:(NSInteger)theme lectureDetails:(NSArray *)lectureDetails
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
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
    
    [sharedDefaults setObject:self.activedTimeTable forKey:@"ActivedTimeTable"];
    [sharedDefaults synchronize];
}

- (void)saveLectureWithLectureName:(NSString *)lectureName theme:(NSInteger)theme lectureDetails:(NSArray *)lectureDetails ulid:(NSInteger)ulid
{
    [_realm beginWriteTransaction];
    LectureObject *lectureObject = [[LectureObject alloc] init];
    lectureObject.ulid = ulid;
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
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
    
    [sharedDefaults setObject:self.activedTimeTable forKey:@"ActivedTimeTable"];
    [sharedDefaults synchronize];
}

- (NSInteger)lastUlid
{
    RLMResults *lectureResults = [[LectureObject allObjectsInRealm:_realm] sortedResultsUsingProperty:@"ulid" ascending:NO];
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
    
    [self refreshTimeTableSetting];
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
    if (!self.activedTimeTableObject) {
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
        
        [sharedDefaults setObject:nil forKey:@"ActivedTimeTable"];
        [sharedDefaults synchronize];
    }
}

- (void)deleteLectureWithUlid:(NSInteger)ulid
{
    [_realm beginWriteTransaction];
    RLMResults *lectureObjectToDeleteResult = [LectureObject objectsWhere:@"ulid == %ld", ulid];
    LectureObject *lectureObjectToDelete = lectureObjectToDeleteResult[0];
    [_realm deleteObjects:lectureObjectToDelete.lectureDetails];
    [_realm deleteObject:lectureObjectToDelete];
    [_realm commitWriteTransaction];
    
    [self refreshTimeTableSetting];
}

- (void)refreshTimeTableSetting
{
    [_realm beginWriteTransaction];
    
    self.activedTimeTableObject.sat = NO;
    self.activedTimeTableObject.sun = NO;
    self.activedTimeTableObject.timeStart = -1;
    self.activedTimeTableObject.timeEnd = -1;
    
    NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    for (LectureObject *lectureObject in self.activedTimeTableObject.lectures) {
        RLMResults *lecturesResults = [lectureObject.lectureDetails objectsWhere:@"ulid == %ld", lectureObject.ulid];
        if (lecturesResults.count != 0) [resultsArray addObject:lecturesResults];
    }
    for (RLMResults *lectureDetailResults in resultsArray) {
        for (LectureDetailObject *lectureDetailObject in lectureDetailResults) {
            if (self.activedTimeTableObject.timeStart == -1 || self.activedTimeTableObject.timeStart > lectureDetailObject.timeStart)
                self.activedTimeTableObject.timeStart = lectureDetailObject.timeStart;
            
            if (self.activedTimeTableObject.timeEnd == -1 || self.activedTimeTableObject.timeEnd < lectureDetailObject.timeEnd)
                self.activedTimeTableObject.timeEnd = lectureDetailObject.timeEnd;
            
            if (lectureDetailObject.day == 5 || lectureDetailObject.day == 6) {
                self.activedTimeTableObject.sat = YES;
                self.activedTimeTableObject.sun = YES;
            }
        }
    }
    [_realm commitWriteTransaction];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
    
    [sharedDefaults setObject:self.activedTimeTable forKey:@"ActivedTimeTable"];
    [sharedDefaults synchronize];

}

#pragma mark - Set Object Attribute

- (void)setActiveWithUtid:(NSInteger)utid
{
    [_realm beginWriteTransaction];
    TimeTableObject *timeTableObject = [TimeTableObject objectsWhere:@"utid == %ld", utid][0];
    RLMResults *timeTableResults = [TimeTableObject allObjectsInRealm:_realm];
    for (TimeTableObject *resultTimeTableObject in timeTableResults) {
        resultTimeTableObject.active = NO;
    }
    timeTableObject.active = YES;
    [_realm commitWriteTransaction];
}

#pragma mark - Get Objects

- (NSArray *)downloadedTimeTables
{
    RLMResults *downloadedTimeTables = [ServerTimeTableObject allObjectsInRealm:_realm];
    if (downloadedTimeTables.count == 0) {
        NSLog(@"Downloaded TimeTables are NOT exist!");
        return nil;
    }
    return [self arrayWithServerTimeTableResults:downloadedTimeTables];
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
    RLMResults *timeTableResults = [[TimeTableObject allObjectsInRealm:_realm] sortedResultsUsingProperty:@"utid" ascending:YES];
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
    
    NSArray *sortedArray = [self arrayWithLectureDetailResulstArray:resultsArray];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStart" ascending:YES];
    return [sortedArray sortedArrayUsingDescriptors:@[sortDescriptor]];
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

- (NSArray *)lectureDetailObjectsWithUlid:(NSInteger)ulid
{
    RLMResults *lectureDetailResults = [LectureDetailObject objectsWhere:@"ulid == %ld", ulid];
    if (lectureDetailResults.count == 0) {
        NSLog(@"LectureDetails (ulid : %ld) is NOT exist", ulid);
        return nil;
    }
    NSMutableArray *lectureDetailObjects = [[NSMutableArray alloc] init];
    for (LectureDetailObject *lectureDetailObject in lectureDetailResults) {
        [lectureDetailObjects addObject:lectureDetailObject];
    }
    return lectureDetailObjects;
}

- (NSDictionary *)lectureWithId:(NSInteger)ulid
{
    RLMResults *lectureResults = [self.activedTimeTableObject.lectures objectsWhere:@"ulid == %ld", ulid];
    return [self arrayWithLectureArray:(RLMArray *)lectureResults][0];
}

- (BOOL)lectureDetailsAreDuplicatedOtherLectureDetails:(NSArray *)lectureDetails
{
    for (NSDictionary *lectureDetailDictionary in lectureDetails) {
        for (NSNumber *ulid in [self ulidsInActivedTimeTables]) {
            for (LectureDetailObject *lectureDetailObject in [self lectureDetailObjectsWithUlid:ulid.integerValue]) {
                // lectureDetailObject.day가 같을 경우
                if (lectureDetailObject.day == [lectureDetailDictionary[@"day"] integerValue]) {
                    // (lectureDetailObject.timeStart <= timeStart < lectureDetailObject.timeEnd) || (lectureDetailObject.timeStart < timeEnd <= lectureDetailObject.timeEnd)
                    if ((lectureDetailObject.timeStart <= [lectureDetailDictionary[@"timeStart"] integerValue]
                         && [lectureDetailDictionary[@"timeStart"] integerValue] < lectureDetailObject.timeEnd)
                        ||
                        (lectureDetailObject.timeStart < [lectureDetailDictionary[@"timeEnd"] integerValue]
                         && [lectureDetailDictionary[@"timeEnd"] integerValue] <= lectureDetailObject.timeEnd)) {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (NSArray *)ulidsInActivedTimeTables
{
    NSMutableArray *ulids = [[NSMutableArray alloc] init];
    for (LectureObject *lectureObject in self.activedTimeTableObject.lectures) {
        [ulids addObject:@(lectureObject.ulid)];
    }
    return ulids;
}

- (NSArray *)daySectionTitles
{
    return (self.activedTimeTableObject.sat && self.activedTimeTableObject.sun) ? @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"] : @[@"월", @"화", @"수", @"목", @"금"];
}

- (BOOL)lecturesIsEmptyInActivedTimeTable
{
    if (self.activedTimeTableObject.lectures.count != 0)
        return NO;
    return YES;
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
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.Minz.Dbit"];
    
    [sharedDefaults setObject:[self arrayWithTimeTableResults:activedTimeTableResults][0] forKey:@"ActivedTimeTable"];
    [sharedDefaults synchronize];
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
        lectureDictionary[@"theme"] = @(lectureObject.theme);
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
            lectureDetailDictionary[@"theme"] = @(lectureObject.theme);
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

@end