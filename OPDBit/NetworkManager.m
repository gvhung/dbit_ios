//
//  NetworkManager.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#define SERVER_URL @"https://dbit.plusquare.com/api"

#define SEMESTER @"/semester"
#define LECTURE_LIST @"/lecture/list"


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

- (void)getServerSemestersWithCompletion:(void (^)(id response))success
                                 failure:(void (^)(NSError *error))failure
{
    [self statusBarIndicator:YES];
    NSString *url = [SERVER_URL stringByAppendingString:SEMESTER];
    [_manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
        [self statusBarIndicator:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [self statusBarIndicator:NO];
    }];
}

- (void)getServerLecturesWithSemesterID:(NSInteger)semesterID
                             completion:(void (^)(id response))success
                                failure:(void (^)(NSError *error))failure
{
    [self statusBarIndicator:YES];
    NSString *parameter = [NSString stringWithFormat:@"/%ld", semesterID];
    NSString *url = [[SERVER_URL stringByAppendingString:LECTURE_LIST]
                                 stringByAppendingString:parameter];
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
