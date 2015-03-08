//
//  NetworkManager.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface NetworkManager : NSObject

@property (nonatomic, retain) AFHTTPRequestOperationManager *manager;

+ (NetworkManager *)sharedInstance;


// 학교목록 가져오기
- (void)getServerSchoolsWithCompletion:(void (^)(id response))success
                               failure:(void (^)(NSError *error))failure;

// 학기목록 가져오기
- (void)getServerTimeTableWithWithSchoolID:(NSInteger)schoolId
                                completion:(void (^)(id response))success
                                   failure:(void (^)(NSError *error))failure;

// 학기별로 강의목록 가져오기
- (void)getServerLecuturesWithTimeTableID:(NSInteger)timeTableId
                         completion:(void (^)(id response))success
                            failure:(void (^)(NSError *error))failure;

@end
