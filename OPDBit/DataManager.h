//
//  DataManager.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

+ (DataManager *)sharedInstance;

- (void)saveServerSchoolsWithResponse:(NSArray *)response;
- (void)saveServerTimeTablesWithResponse:(NSArray *)response;
- (void)saveServerLecturesWithResponse:(NSArray *)response update:(void (^)(NSInteger progressIndex))update;

- (void)setDownloadedWithTimeTableId:(NSInteger)timeTableId;

- (NSArray *)getDownloadedTimeTables;
- (NSArray *)getServerTimeTablesWithSchoolId:(NSInteger)schoolId;
- (NSArray *)getSchools;

@end
