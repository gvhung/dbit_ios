//
//  LectureObject.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "LectureObject.h"

@implementation LectureObject

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
    return @"ulid";
}

- (void)setDefaultProperties
{
    self.ulid = -1;
    self.lectureName = @"";
    self.lectureDetails = nil;
    self.theme = 0;
}

@end
