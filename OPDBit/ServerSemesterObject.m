//
//  ServerSemesterObject.m
//  OPDBit
//
//  Created by 1000732 on 2015. 7. 26..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "ServerSemesterObject.h"

@implementation ServerSemesterObject

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

+ (NSString *)primaryKey
{
    return @"semesterID";
}

+ (NSArray *)ignoredProperties
{
    return @[@""];
}

- (void)setPropertiesWithResponse:(NSDictionary *)response
{
    self.semesterVersion = [response[@"version"] integerValue];
    self.semesterName = response[@"name"];
    self.semesterKey = response[@"key"];
    self.semesterID = [response[@"id"] integerValue];
}

@end
