//
//  LectureObject.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "LectureObject.h"
#import "ServerLectureObject.h"

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

#warning SearchLectureViewController 참조해서 ServerLecture -> Lecture로 변환하는 거 가져오기
- (void)lectureWithServerLecture:(ServerLectureObject *)serverLecture
{
    
}

@end
