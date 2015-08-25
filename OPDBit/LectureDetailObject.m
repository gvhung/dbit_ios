//
//  LectureDetailObject.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "TimeTableObject.h"
#import "LectureDetailObject.h"

@implementation LectureDetailObject

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

- (void)setDefaultProperties
{
    self.lectureLocation = @"";
    self.timeStart = 900;
    self.timeEnd = 1100;
    self.day = 0;
}

- (LectureObject *)lecture
{
    NSArray *lectures = [self linkingObjectsOfClass:@"LectureObject" forProperty:@"lectureDetails"];
    if (lectures.count) {
        return [lectures firstObject];
    }
    return nil;
}

- (BOOL)isContainedWithUtid:(NSInteger)utid
{
    NSArray *lectures = [self linkingObjectsOfClass:@"LectureObject" forProperty:@"lectureDetails"];
    if (lectures.count) {
        NSArray *timetables = [[lectures firstObject] linkingObjectsOfClass:@"TimeTableObject" forProperty:@"lectures"];
        if (timetables.count) {
            if (((TimeTableObject *)timetables[0]).utid == utid) {
                return YES;
            }
        }
    }
    return NO;
}

@end
