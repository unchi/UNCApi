//
//  Api.m
//  Hige
//
//  Created by unchi on 2013/12/06.
//  Copyright (c) 2013年 sugiyama-mitsunari. All rights reserved.
//

#import "UNCApi.h"
#import "UNCApiData.h"

#import "AFHTTPRequestOperationManager.h"


@implementation UNCApi

- (id) init {
    if (self = [super init]) {
        // do nothing
        
        _timeoutInterval = 20;
    }
    return self;
}

- (void)
    get: (NSString*)url
    params: (NSDictionary*)params
    completionHandler: (UNCApiHandler)func {
    
    [self get: url params:params headers:@{} completionHandler:func];
}

- (void)
    get: (NSString*)url
    params: (NSDictionary*)params
    headers: (NSDictionary*)headers
    completionHandler: (UNCApiHandler)func {

    NSLog (@"P:%@", params);
    NSLog (@"H:%@", headers);
    
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    
    NSString* uri = [[NSURL URLWithString:url relativeToURL:manager.baseURL] absoluteString];

    NSError* error;
    NSMutableURLRequest *request = [manager.requestSerializer
                                        requestWithMethod:@"GET"
                                                URLString:uri
                                               parameters:params
                                                    error:&error];

    for (NSString* key in headers) {
        NSString* val = [headers objectForKey: key];
        [request setValue: val forHTTPHeaderField: key];
    }
    
    [request setTimeoutInterval:_timeoutInterval];
   // [request setCachePolicy:cachePolicy];
    
    AFHTTPRequestOperation *operation = [manager
            HTTPRequestOperationWithRequest:request
                                    success:^(AFHTTPRequestOperation* operation, id responseObject) {
                                      //  NSLog(@"status code %ld", (long)[operation.response statusCode]);
                                      //  NSLog (@"API: %@: %@", url, responseObject);
                                        func(responseObject, operation, nil);
                                    }
                                    failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                                      //  NSLog(@"status code %ld", (long)[operation.response statusCode]);
                                        func(nil, operation, error);
                                    }];
    
    [manager.operationQueue addOperation:operation];
}

- (void)
    post: (NSString*)url
    params: (NSDictionary*)params
    completionHandler: (UNCApiHandler)func {
    
    [self request:url method:@"POST" params:params headers:@{} completionHandler:func];
}

- (void)
    post: (NSString*)url
    params: (NSDictionary*)params
    headers: (NSDictionary*)headers
    completionHandler: (UNCApiHandler)func {
    
    [self request:url method:@"POST" params:params headers:headers completionHandler:func];
}

- (void)
    put: (NSString*)url
    params: (NSDictionary*)params
    completionHandler: (UNCApiHandler)func {
    
    [self request:url method:@"PUT" params:params headers:@{} completionHandler:func];
}

- (void)
    put: (NSString*)url
    params: (NSDictionary*)params
    headers: (NSDictionary*)headers
    completionHandler: (UNCApiHandler)func {
    
    [self request:url method:@"PUT" params:params headers:headers completionHandler:func];
}

- (void)
    request: (NSString*)url
    method: (NSString*)method
    params: (NSDictionary*)params
    headers: (NSDictionary*)headers
    completionHandler: (UNCApiHandler)func {
    
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary* strParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* binParams = [[NSMutableDictionary alloc] init];
    
    for (NSString* key in params) {
        
        id o = [params objectForKey: key];
        
        if ([o isKindOfClass:[UNCApiData class]]) {
            [binParams setObject:o forKey: key];
        } else {
            [strParams setObject:o forKey: key];
        }
        
    }
    
    
    
    NSString* uri = [[NSURL URLWithString:url relativeToURL:manager.baseURL] absoluteString];
    
    NSError* error;
    NSMutableURLRequest *request = [manager.requestSerializer
                                    multipartFormRequestWithMethod:method
                                    URLString:uri
                                    parameters:strParams
                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
                                        
                                        for (NSString* key in binParams) {
                                            UNCApiData* data = [binParams objectForKey: key];
                                            [formData appendPartWithFileData:data.bin
                                                                        name:key
                                                                    fileName:data.fileName
                                                                    mimeType:data.mimeType];
                                        }
                                    }
                                    error:&error];
    
    [request setTimeoutInterval:_timeoutInterval];
    // [request setCachePolicy:cachePolicy];
    
    for (NSString* key in headers) {
        NSString* val = [headers objectForKey: key];
        [request addValue:val forHTTPHeaderField:key];
    }
    
    AFHTTPRequestOperation *operation = [manager
                                         HTTPRequestOperationWithRequest:request
                                         success:^(AFHTTPRequestOperation* operation, id responseObject) {
                                            // NSLog(@"status code %ld", (long)[operation.response statusCode]);
                                            // NSLog (@"API: %@: %@", url, responseObject);
                                             func(responseObject, operation, nil);
                                         }
                                         failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                                            // NSLog(@"status code %ld", (long)[operation.response statusCode]);
                                             func(nil, operation, error);
                                         }];
    
    [manager.operationQueue addOperation:operation];
}

@end

