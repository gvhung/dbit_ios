//
//  ServerLectureObject.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "ServerLectureObject.h"

@implementation ServerLectureObject

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[@""];
}

- (void)setPropertiesWithResponse:(NSDictionary *)response
{
    self.lectureCourse = response[@"lecture_course"];
    self.semesterID = [response[@"semester_id"] integerValue];
    self.lectureName = response[@"lecture_name"];
    self.lectureKey = response[@"lecture_key"];
    self.lectureProf = response[@"lecture_prof"];
    self.lectureType = response[@"lecture_type"];
    self.lectureEtc = response[@"lecture_etc"];
    self.lectureLanguage = response[@"lecture_lang"];
    self.lectureLocation = response[@"lecture_location"];
    self.lectureDaytime = response[@"lecture_daytime"];
    self.lecturePoint = response[@"lecture_point"];
    self.lectureCampus = response[@"lecture_campus"];
    self.serverLectureID = [response[@"id"] integerValue];
}
@end
