//
//  DataManager.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

- (void)setActiveWithUtid:(NSInteger)utid;
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
- (NSDictionary *)lectureWithId:(NSInteger)ulid;

/**
 * Lecture Details to display
 *
 *  @param  day day (ex. mon, tue, ...) to display Lecture Detail in active TimeTable
 *
 *  @return lectureName Lecture Name
 *  @return theme       Color Theme
 *  @return timeStart   Start time (NSInteger)
 *  @return timeEnd     End time (NSInteger)
 *  @return lectureLocation Lecture Location
 */

- (NSArray *)lectureDetailsWithDay:(NSInteger)day;

#pragma mark - Lecture Theme

+ (NSInteger)lectureThemeCount;
+ (NSArray *)lectureThemeThumbnailArray;
+ (UIImage *)lectureThemeThumbnail:(NSInteger)themeId;

#pragma mark - Time Convert Method

+ (NSString *)stringFromTimeInteger:(NSInteger)timeInteger;

+ (NSInteger)integerFromTimeString:(NSString *)timeString;

@end
