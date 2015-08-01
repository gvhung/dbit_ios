//
//  TimeTableObject.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "TimeTableObject.h"

@implementation TimeTableObject

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

+ (NSString *)primaryKey
{
    return @"utid";
}

- (void)setDefaultProperties
{
    self.utid = -1;
    self.timeTableName = @"";
    self.timeStart = -1;
    self.timeEnd = -1;
    self.active = NO;
    self.workAtWeekend = NO;
    
    self.serverSemesterObject = nil;
    self.lectures = nil;
}

@end
