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

- (void)saveServerSemester:(ServerSemesterObject *)serverSemester
                completion:(void (^)(BOOL isUpdated))completion;
/*
- (void)saveServerLecturesWithResponse:(NSArray *)response
                            semesterID:(NSInteger)semesterID
                            completion:(void (^)())completion;
*/
- (void)saveOrUpdateTimeTable:(TimeTableObject *)timeTableObject
                   completion:(void (^)(BOOL isUpdated))completion;
- (void)saveLectureWithLectureName:(NSString *)lectureName
                             theme:(NSInteger)theme
                    lectureDetails:(RLMArray *)lectureDetails;
- (void)saveLectureDetailWithUlid:(NSInteger)ulid
                  lectureLocation:(NSString *)lectureLocation
                          timeEnd:(NSInteger)timeEnd
                        timeStart:(NSInteger)timeStart
                              day:(NSInteger)day;
- (void)updateLectureWithUlid:(NSInteger)ulid
                         name:(NSString *)name
                        theme:(NSInteger)theme
               lectureDetails:(RLMArray *)lectureDetails;

- (void)deleteTimeTableWithUtid:(NSInteger)utid;
- (void)deleteLectureWithUlid:(NSInteger)ulid;

#pragma mark - Set Attributes

- (void)setActiveWithUtid:(NSInteger)utid;

#pragma mark - Get Objects

- (RLMArray *)savedServerSemesters;
- (RLMArray *)timeTables;
- (TimeTableObject *)timeTableWithUtid:(NSInteger)utid;
- (RLMArray *)lectureDetailsWithDay:(NSInteger)day;
- (LectureObject *)lectureObjectWithUlid:(NSInteger)ulid;
- (RLMArray *)lectureDetailObjectsWithUlid:(NSInteger)ulid;
- (LectureObject *)lectureWithUlid:(NSInteger)ulid;
- (BOOL)lectureAreDuplicatedOtherLecture:(LectureObject *)lecture inTimeTable:(TimeTableObject *)timeTable;
- (NSArray *)daySectionTitles;

#pragma mark - Lecture Theme

+ (NSInteger)lectureThemeCount;
+ (NSArray *)lectureThemeThumbnailArray;
+ (UIImage *)lectureThemeThumbnail:(NSInteger)themeId;

#pragma mark - Time Convert Method

+ (NSString *)stringFromTimeInteger:(NSInteger)timeInteger;
+ (NSInteger)integerFromTimeString:(NSString *)timeString;

@end
