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

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

+ (NetworkManager *)sharedInstance;

- (void)getServerSemestersWithCompletion:(void (^)(id response))success
                                 failure:(void (^)(NSError *error))failure;

- (void)getServerLecturesWithSemesterID:(NSInteger)semesterID
                                version:(NSInteger)version
                             completion:(void (^)(id response))success
                                failure:(void (^)(NSError *error))failure;

@end
