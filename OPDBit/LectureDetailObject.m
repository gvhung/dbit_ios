//
//  LectureDetailObject.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

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
    self.ulid = -1;
    self.lectureLocation = @"";
    self.timeStart = -1;
    self.timeEnd = -1;
    self.day = -1;
}

@end
