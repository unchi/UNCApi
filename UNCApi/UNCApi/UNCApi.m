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
        // do nothing
        
        _timeoutInterval = 20;
    }
    return self;
}

- (void)        get:(NSString*)url
             params:(NSDictionary*)params
  completionHandler:(UNCApiHandler)func {
    
    [self get: url params:params headers:@{} completionHandler:func];
}

- (void)        get:(NSString*)url
             params:(NSDictionary*)params
            headers:(NSDictionary*)headers
  completionHandler:(UNCApiHandler)func {

//    NSLog (@"P:%@", params);
//    NSLog (@"H:%@", headers);
//    
//    NSLog (@"%d", __IPHONE_OS_VERSION_MIN_REQUIRED);
    
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000

    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    AFHTTPRequestSerializer* request = [AFHTTPRequestSerializer serializer];
    
    for (NSString* key in headers) {
        NSString* val = [headers objectForKey: key];
        [request setValue: val forHTTPHeaderField: key];
    }
    
    request.timeoutInterval = _timeoutInterval;
    
    manager.requestSerializer = request;
    
    [manager GET:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        func(responseObject, (NSHTTPURLResponse*)[task response], nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        func(nil, (NSHTTPURLResponse*)[task response], error);
    }];

    [manager operationQueue];

#else
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFHTTPRequestSerializer* request = [AFHTTPRequestSerializer serializer];
    
    for (NSString* key in headers) {
        NSString* val = [headers objectForKey: key];
        [request setValue: val forHTTPHeaderField: key];
    }

    request.timeoutInterval = _timeoutInterval;

    manager.requestSerializer = request;
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        func(responseObject, operation.response, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        func(nil, operation.response, error);
    }];

    [manager operationQueue];
#endif
}

- (void)        post:(NSString*)url
              params:(NSDictionary*)params
   completionHandler:(UNCApiHandler)func {
    
    [self request:url method:@"POST" params:params headers:@{} completionHandler:func];
}

- (void)        post:(NSString*)url
              params:(NSDictionary*)params
             headers:(NSDictionary*)headers
   completionHandler:(UNCApiHandler)func {
    
    [self request:url method:@"POST" params:params headers:headers completionHandler:func];
}

- (void)        put:(NSString*)url
             params:(NSDictionary*)params
  completionHandler:(UNCApiHandler)func {
    
    [self request:url method:@"PUT" params:params headers:@{} completionHandler:func];
}

- (void)        put:(NSString*)url
             params:(NSDictionary*)params
            headers:(NSDictionary*)headers
  completionHandler:(UNCApiHandler)func {
    
    [self request:url method:@"PUT" params:params headers:headers completionHandler:func];
}

- (void)    delete:(NSString*)url
            params:(NSDictionary*)params
 completionHandler:(UNCApiHandler)func {
    
    [self request:url method:@"DELETE" params:params headers:@{} completionHandler:func];
}

- (void)    delete:(NSString*)url
            params:(NSDictionary*)params
           headers:(NSDictionary*)headers
 completionHandler:(UNCApiHandler)func {
    
    [self request:url method:@"DELETE" params:params headers:headers completionHandler:func];
}

- (void)    request:(NSString*)url
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
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000

    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    AFHTTPRequestSerializer* request = [AFHTTPRequestSerializer serializer];
    
    for (NSString* key in headers) {
        NSString* val = [headers objectForKey: key];
        [request setValue: val forHTTPHeaderField: key];
    }
    request.timeoutInterval = _timeoutInterval;

    manager.requestSerializer = request;
    
    [manager            POST:url
                  parameters:params
   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for (NSString* key in binParams) {
            UNCApiData* data = [binParams objectForKey: key];
            [formData appendPartWithFileData:data.bin
                                        name:key
                                    fileName:data.fileName
                                    mimeType:data.mimeType];
        }
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        func(responseObject, [task response], nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        func(nil, [task response], error);
    }];

    [manager operationQueue];
    
#else
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    
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
    
    request.timeoutInterval = _timeoutInterval;
    
    for (NSString* key in headers) {
        NSString* val = [headers objectForKey: key];
        [request addValue:val forHTTPHeaderField:key];
    }
    
    AFHTTPRequestOperation *operation = [manager
                                         HTTPRequestOperationWithRequest:request
                                         success:^(AFHTTPRequestOperation* operation, id responseObject) {
                                            // NSLog(@"status code %ld", (long)[operation.response statusCode]);
                                            // NSLog (@"API: %@: %@", url, responseObject);
                                             func(responseObject, operation.response, nil);
                                         }
                                         failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                                            // NSLog(@"status code %ld", (long)[operation.response statusCode]);
                                             func(nil, operation.response, error);
                                         }];
    
    [manager.operationQueue addOperation:operation];
#endif
}

@end

