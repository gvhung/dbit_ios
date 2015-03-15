//
//  DataManager.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, strong) NSDictionary *activedTimeTable;

+ (DataManager *)sharedInstance;

- (void)saveServerSchoolsWithResponse:(NSArray *)response;
- (void)saveServerTimeTablesWithResponse:(NSArray *)response;
- (void)saveServerLecturesWithResponse:(NSArray *)response
                                update:(void (^)(NSInteger progressIndex))update;

- (void)saveTimeTableWithName:(NSString *)name
                     serverId:(NSInteger)serverId
                       active:(BOOL)active;
- (void)saveLectureWithLectureName:(NSString *)lectureName
                             theme:(NSString *)theme
                    lectureDetails:(NSArray *)lectureDetails;
- (void)saveLectureDetailWithUlid:(NSInteger)ulid
                  lectureLocation:(NSString *)lectureLocation
                          timeEnd:(NSInteger)timeEnd
                        timeStart:(NSInteger)timeStart
                              day:(NSInteger)day;

- (void)updateTimeTableWithUtid:(NSInteger)utid
                         name:(NSString *)name
                     serverId:(NSInteger)serverId
                       active:(BOOL)active
                      failure:(void (^)(NSString *reason))failure;

- (void)setDownloadedWithTimeTableId:(NSInteger)timeTableId;

- (NSArray *)downloadedTimeTables;
- (NSArray *)serverTimeTablesWithSchoolId:(NSInteger)schoolId;
- (NSArray *)schools;
- (NSDictionary *)serverTimeTableWithId:(NSInteger)serverTimeTableId;
- (NSArray *)timeTables;
- (NSDictionary *)timeTableWithId:(NSInteger)timeTableId;
- (NSArray *)serverLecturesWithServerTimeTableId:(NSInteger)serverTimeTableId;
- (NSString *)schoolNameWithServerTimeTableId:(NSInteger)timeTableId;
- (NSString *)semesterString:(NSString *)semester;

@end
