//
//  DataManager.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "DataManager.h"
#import <Realm/Realm.h>

@interface DataManager ()

@property (nonatomic, retain) RLMRealm *realm;

@end

@implementation DataManager

+ (DataManager *)sharedInstance
{
    static dispatch_once_t pred;
    static DataManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[DataManager alloc] init];
    });
    
    return shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        _realm = [RLMRealm defaultRealm];
    }
    return self;
}


/*
- (void)saveLectureWithResponse:(NSArray *)response update:(void (^)(NSInteger index))update
{
    NSInteger index = 0;
    [_realm beginWriteTransaction];
    [_realm deleteAllObjects];
    for (NSDictionary *lectureDictionary in response) {
        LectureObject *lectureObject = [[LectureObject alloc] init];
        lectureObject.name = [lectureDictionary valueForKey:@"name"];
        lectureObject.semester = [lectureDictionary valueForKey:@"semester"];
        lectureObject.score = [[lectureDictionary valueForKey:@"score"] integerValue];
        lectureObject.prof = [lectureDictionary valueForKey:@"prof"];
        lectureObject.key = [lectureDictionary valueForKey:@"key"];
        lectureObject.room = [lectureDictionary valueForKey:@"room"];
        lectureObject.extra = [lectureDictionary valueForKey:@"extra"];
        lectureObject.campus = [lectureDictionary valueForKey:@"campus"];
        lectureObject.date = [lectureDictionary valueForKey:@"date"];
        lectureObject.step = [lectureDictionary valueForKey:@"step"];
        
        
        
        [_realm addObject:lectureObject];
        index += 1;
        update(index);
    }
    [_realm commitWriteTransaction];
}

- (NSArray *)lecturesThatContainName:(NSString *)name
{
    RLMResults *lectures = [LectureObject objectsWhere:[NSString stringWithFormat:@"name CONTAINS '%@'", name]];
    return [self arrayFromLectureResults:lectures];
}

- (NSArray *)arrayFromLectureResults:(RLMResults *)results
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (LectureObject *lectureObject in results) {
        NSMutableDictionary *lectureDictionary = [[NSMutableDictionary alloc] init];
        [lectureDictionary setValue:lectureObject.name forKey:@"name"];
        [lectureDictionary setValue:@(lectureObject.score) forKey:@"score"];
        [lectureDictionary setValue:lectureObject.semester forKey:@"semester"];
        [lectureDictionary setValue:lectureObject.key forKey:@"key"];
        [lectureDictionary setValue:lectureObject.step forKey:@"step"];
        [lectureDictionary setValue:lectureObject.prof forKey:@"prof"];
        [lectureDictionary setValue:lectureObject.campus forKey:@"campus"];
        [lectureDictionary setValue:lectureObject.date forKey:@"date"];
        [lectureDictionary setValue:lectureObject.room forKey:@"room"];
        [lectureDictionary setValue:lectureObject.extra forKey:@"extra"];
        [array addObject:lectureDictionary];
    }
    return array;
}

- (NSArray *)allLectureObjects
{
    return [self arrayFromLectureResults:[LectureObject allObjects]];
}
 
 
 */

@end
