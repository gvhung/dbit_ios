//
//  LectureObject.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "LectureObject.h"
#import "ServerLectureObject.h"
#import "DataManager.h"

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

- (void)lectureFromServerLecture:(ServerLectureObject *)serverLecture
{
    self.lectureName = serverLecture.lectureName;
    
    RLMArray *lectureDetails = [[RLMArray alloc] initWithObjectClassName:LectureDetailObjectID];
    
    // ,로 Location 을 나눌경우 생기는 에러 (ex. 405-250(원흥관 1,3 E250 강의실))
    NSMutableArray *lectureLocationArray = [serverLecture.lectureLocation componentsSeparatedByString:@"),"].mutableCopy;
    for (NSInteger i = 0; i < lectureLocationArray.count; i++) {
        NSString *lectureLocationString = lectureLocationArray[i];
        
        if (i < lectureLocationArray.count-1) {
            NSString *convertedString = [lectureLocationString stringByAppendingString:@")"];
            [lectureLocationArray replaceObjectAtIndex:i withObject:convertedString];
        }
    }
    
    NSMutableArray *lectureDaytimeArray = [serverLecture.lectureDaytime componentsSeparatedByString:@","].mutableCopy;
    NSInteger detailCount = MAX(lectureLocationArray.count, lectureDaytimeArray.count);
    
    for (NSInteger i = 0; i < detailCount; i++) {
        LectureDetailObject *lectureDetail = [[LectureDetailObject alloc] init];
        [lectureDetail setDefaultProperties];
        lectureDetail.ulid = self.ulid;
        
        lectureDetail.lectureLocation = [self locationWithString:lectureLocationArray[i]];
        lectureDetail.timeStart = [self timeStartWithString:lectureDaytimeArray[i]];
        lectureDetail.timeEnd = [self timeEndWithString:lectureDaytimeArray[i]];
        lectureDetail.day = [self dayWithString:lectureDaytimeArray[i]];
        [lectureDetails addObject:lectureDetail];
    }
    [self.lectureDetails removeAllObjects];
    [self.lectureDetails addObjects:lectureDetails];
}
- (NSString *)locationWithString:(NSString *)string
{
    if (!string) {
        return @"";
    }
    
    return string;
}

- (NSInteger)dayWithString:(NSString *)string
{
    if (!string) {
        return 0;
    }
    
    NSString *pureDaytimeString = [string substringToIndex:1];
    
    NSArray *dayStringArray = @[@"월", @"화", @"수", @"목", @"금", @"토", @"일"];
    NSInteger dayInteger = 0;
    for (NSString *dayString in dayStringArray) {
        if ([dayString isEqualToString:pureDaytimeString]) {
            dayInteger = [dayStringArray indexOfObject:dayString];
        }
    }
    
    return dayInteger;
}

- (NSInteger)timeStartWithString:(NSString *)string
{
    if (!string) {
        return 0;
    }
    
    NSString *pureDaytimeString = [string componentsSeparatedByString:@"/"][1];
    NSString *timeStartString = [pureDaytimeString componentsSeparatedByString:@"-"][0];
    return [DataManager integerFromTimeString:timeStartString];
}

- (NSInteger)timeEndWithString:(NSString *)string
{
    if (!string) {
        return 0;
    }
    
    NSString *pureDaytimeString = [string componentsSeparatedByString:@"/"][1];
    NSString *timeEndString = [pureDaytimeString componentsSeparatedByString:@"-"][1];
    return [DataManager integerFromTimeString:timeEndString];
}


@end
