//
//  DataManager.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class TimeTableObject;
@class ServerSemesterObject;
@class ServerLectureObject;
@class LectureObject;
@class LectureDetailObject;

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

@interface DataManager : NSObject

@property (nonatomic, strong) TimeTableObject *activedTimeTable;

+ (DataManager *)sharedInstance;

- (void)migrateV1toV2;

#pragma mark - Database Manage Method

- (void)saveServerTimeTablesWithResponse:(NSArray *)response;
- (void)saveServerLecturesWithResponse:(NSArray *)response
                     serverTimeTableId:(NSInteger)serverTimeTableId
                                update:(void (^)(NSInteger progressIndex))update;
- (void)saveTimeTableWithName:(NSString *)name
                     serverId:(NSInteger)serverId
                       active:(BOOL)active;
- (void)saveLectureWithLectureName:(NSString *)lectureName
                             theme:(NSInteger)theme
                    lectureDetails:(NSArray *)lectureDetails;
- (void)saveLectureWithLectureName:(NSString *)lectureName
                             theme:(NSInteger)theme
                    lectureDetails:(NSArray *)lectureDetails
                              ulid:(NSInteger)ulid;
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
- (void)updateLectureWithUlid:(NSInteger)ulid
                         name:(NSString *)name
                        theme:(NSInteger)theme
               lectureDetails:(NSArray *)lectureDetails;
- (void)deleteTimeTableWithUtid:(NSInteger)utid;
- (void)deleteLectureWithUlid:(NSInteger)ulid;

#pragma mark - Set Attributes

- (void)setActiveWithUtid:(NSInteger)utid;

#pragma mark - Get Objects

- (RLMArray *)timeTables;
- (TimeTableObject *)timeTableWithId:(NSInteger)timeTableId;
- (RLMArray *)serverLecturesWithServerTimeTableId:(NSInteger)serverTimeTableId;
- (RLMArray *)lectureDetailsWithDay:(NSInteger)day;
- (LectureObject *)lectureObjectWithUlid:(NSInteger)ulid;
- (RLMArray *)lectureDetailObjectsWithUlid:(NSInteger)ulid;
- (LectureObject *)lectureWithId:(NSInteger)ulid;
- (BOOL)lectureDetailsAreDuplicatedOtherLectureDetails:(RLMArray *)lectureDetails;
- (RLMArray *)ulidsInActivedTimeTables;
- (NSArray *)daySectionTitles;
- (BOOL)lecturesIsEmptyInActivedTimeTable;

#pragma mark - Lecture Theme

+ (NSInteger)lectureThemeCount;
+ (NSArray *)lectureThemeThumbnailArray;
+ (UIImage *)lectureThemeThumbnail:(NSInteger)themeId;

#pragma mark - Time Convert Method

+ (NSString *)stringFromTimeInteger:(NSInteger)timeInteger;
+ (NSInteger)integerFromTimeString:(NSString *)timeString;

@end
