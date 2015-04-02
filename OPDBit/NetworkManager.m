//
//  NetworkManager.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

+ (NetworkManager *)sharedInstance
{
    static dispatch_once_t pred;
    static NetworkManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[NetworkManager alloc] init];
        shared.manager = [AFHTTPRequestOperationManager manager];
        shared.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        shared.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    
    return shared;
}

- (void)getServerSchoolsWithCompletion:(void (^)(id response))success
                               failure:(void (^)(NSError *error))failure
{
    [self statusBarIndicator:YES];
    NSString *url = [NSString stringWithFormat:@"http://dbit.api.overthepixel.com/school"];
    [_manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
        [self statusBarIndicator:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [self statusBarIndicator:NO];
    }];
}

// 학기목록 가져오기
- (void)getServerTimeTableWithWithSchoolID:(NSInteger)schoolId
                                completion:(void (^)(id response))success
                                   failure:(void (^)(NSError *error))failure
{
    [self statusBarIndicator:YES];
    NSString *url = [NSString stringWithFormat:@"http://dbit.api.overthepixel.com/school/timetable/%ld", schoolId];
    [_manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
        [self statusBarIndicator:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [self statusBarIndicator:NO];
    }];
}

// 학기별로 강의목록 가져오기
- (void)getServerLecturesWithTimeTableID:(NSInteger)timeTableId
                               completion:(void (^)(id response))success
                                  failure:(void (^)(NSError *error))failure
{
    [self statusBarIndicator:YES];
    NSString *url = [NSString stringWithFormat:@"http://dbit.api.overthepixel.com/timetable/%ld", timeTableId];
    [_manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
        [self statusBarIndicator:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [self statusBarIndicator:NO];
    }];
}

- (void)statusBarIndicator:(BOOL)visible
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
}


@end
