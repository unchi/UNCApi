//
//  Api.m
//
//  Created by unchi on 2013/12/06.
//  Copyright (c) 2013年 unchi. All rights reserved.
//

#import "UNCApi.h"
#import "UNCApiData.h"

#import <AFNetworking.h>

@implementation UNCApi

- (id) init {
    if (self = [super init]) {
        _timeoutInterval = 20;
    }
    return self;
}

- (void)        get:(NSString*)url
             params:(NSDictionary*)params
  completionHandler:(UNCApiHandler)func {
    
    [self requestUrl: url method: @"GET" params:params headers:@{} completionHandler:func];
}

- (void)        get:(NSString*)url
             params:(NSDictionary*)params
            headers:(NSDictionary*)headers
  completionHandler:(UNCApiHandler)func {

    [self requestUrl: url method: @"GET" params:params headers:headers completionHandler:func];
}

- (void)        post:(NSString*)url
              params:(NSDictionary*)params
   completionHandler:(UNCApiHandler)func {
    
    [self requestBody:url method:@"POST" params:params headers:@{} completionHandler:func];
}

- (void)        post:(NSString*)url
              params:(NSDictionary*)params
             headers:(NSDictionary*)headers
   completionHandler:(UNCApiHandler)func {
    
    [self requestBody:url method:@"POST" params:params headers:headers completionHandler:func];
}

- (void)        put:(NSString*)url
             params:(NSDictionary*)params
  completionHandler:(UNCApiHandler)func {
    
    [self requestBody:url method:@"PUT" params:params headers:@{} completionHandler:func];
}

- (void)        put:(NSString*)url
             params:(NSDictionary*)params
            headers:(NSDictionary*)headers
  completionHandler:(UNCApiHandler)func {
    
    [self requestBody:url method:@"PUT" params:params headers:headers completionHandler:func];
}

- (void)    delete:(NSString*)url
            params:(NSDictionary*)params
 completionHandler:(UNCApiHandler)func {
    
    [self requestUrl:url method:@"DELETE" params:params headers:@{} completionHandler:func];
}

- (void)    delete:(NSString*)url
            params:(NSDictionary*)params
           headers:(NSDictionary*)headers
 completionHandler:(UNCApiHandler)func {
    
    [self requestUrl:url method:@"DELETE" params:params headers:headers completionHandler:func];
}


- (void) requestUrl:(NSString*)url
             method:(NSString*)method
             params:(NSDictionary*)params
            headers:(NSDictionary*)headers
  completionHandler:(UNCApiHandler)func {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    AFHTTPRequestSerializer* serializer = [AFHTTPRequestSerializer serializer];
    
    for (NSString* key in headers) {
        NSString* val = [headers objectForKey: key];
        [serializer setValue: val forHTTPHeaderField: key];
    }
    
    serializer.timeoutInterval = _timeoutInterval;

    manager.requestSerializer = serializer;
    
    [manager GET:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        func(responseObject, (NSHTTPURLResponse*)[task response], nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        func(nil, (NSHTTPURLResponse*)[task response], error);
    }];
}

- (void)requestBody:(NSString*)url
             method:(NSString*)method
             params:(NSDictionary*)params
            headers:(NSDictionary*)headers
  completionHandler:(UNCApiHandler)func {
    
    NSMutableDictionary* strParams = [NSMutableDictionary new];
    NSMutableDictionary* binParams = [NSMutableDictionary new];
    
    for (NSString* key in params) {

        id o = [params objectForKey: key];
        
        if ([o isKindOfClass:[UNCApiData class]]) {
            [binParams setObject:o forKey: key];
        } else {
            [strParams setObject:o forKey: key];
        }
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    AFHTTPRequestSerializer* serializer = [AFHTTPRequestSerializer serializer];

    for (NSString* key in headers) {
        NSString* val = [headers objectForKey: key];
        [serializer setValue: val forHTTPHeaderField: key];
    }
    serializer.timeoutInterval = _timeoutInterval;

    NSMutableURLRequest* request = nil;
    
    if ([binParams count] > 0) {
        request = [serializer multipartFormRequestWithMethod:method
                                                   URLString:url
                                                  parameters:strParams
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

                        // XXX データは ネストに対応していない
                                       
                        for (NSString* key in binParams) {
                            UNCApiData* data = [binParams objectForKey: key];
                            [formData appendPartWithFileData:data.bin
                                                        name:key
                                                    fileName:data.fileName
                                                    mimeType:data.mimeType];
                        }

                     }
                                                       error:nil];
    } else {
        
        request = [serializer requestWithMethod:method URLString:url parameters:strParams error:nil];
    }

    manager.requestSerializer = serializer;
    
    __block NSURLSessionDataTask *task =
    [manager uploadTaskWithStreamedRequest:request
                                  progress:nil
                         completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {

        if (error) {
            func(nil, (NSHTTPURLResponse*)[task response], error);
        } else {
            func(responseObject, (NSHTTPURLResponse*)[task response], nil);
        }
    }];
    
    [task resume];
}

@end
