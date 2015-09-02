//
//  NetworkManager.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "NetworkManager.h"
#import "NSString+api.h"

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
    NSString *url = [NSString api_semester_list];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [_manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"ServerSemesters:\n%@", responseObject);
        success(responseObject);
        [self statusBarIndicator:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [self statusBarIndicator:NO];
    }];
}

- (void)getServerLecturesWithSemesterID:(NSInteger)semesterID
                                version:(NSInteger)version
                             completion:(void (^)(id response))success
                                failure:(void (^)(NSError *error))failure
{
    [self statusBarIndicator:YES];
    
    NSString *url = [NSString api_lecture_list_with_id:semesterID version:version];
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [_manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"ServerLectures:\n%@", responseObject);
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
