//
//  NSString+api.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 9. 2..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "NSString+api.h"

#define APP_TYPE    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"OPDBitApplicationType"]
#define RELEASE     @"RELEASE"
#define ALPHA       @"ALPHA"

@implementation NSString (api)

+ (NSString *)api_cdn_rawgit
{
    if ([APP_TYPE isEqualToString:RELEASE]) {
        return @"https://cdn.rawgit.com/OVERTHEPIXEL/dbit/master/static/";
    } else if ([APP_TYPE isEqualToString:ALPHA]) {
        return @"https://cdn.rawgit.com/MinJunKweon/dbit/master/static/";
    }
    return @"";
}

+ (NSString *)api_raw_github
{
    if ([APP_TYPE isEqualToString:RELEASE]) {
        return @"https://raw.githubusercontent.com/OVERTHEPIXEL/dbit/master/static/";
    } else if ([APP_TYPE isEqualToString:ALPHA]) {
        return @"https://raw.githubusercontent.com/MinJunKweon/dbit/master/static/";
    }
    return @"";
}

+ (NSString *)api_semester_list
{
    return [[NSString api_raw_github] stringByAppendingString:@"semester_list.json"];
}

+ (NSString *)api_lecture_list_with_id:(NSInteger)semesterID version:(NSInteger)version
{
    return [[NSString api_cdn_rawgit] stringByAppendingFormat:@"%ld-v%ld.json", semesterID, version];
}

@end
