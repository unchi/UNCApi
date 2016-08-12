//
//  Api.m
//
//  Created by unchi on 2013/12/06.
//  Copyright (c) 2013年 unchi. All rights reserved.
//

#import "UNCApi.h"
#import "UNCApiData.h"

#import <AFNetworking.h>


static const NSString* const TWO_HYPHENS = @"--";
static const NSString* const LINE_END = @"\r\n";


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
    
    [self _requestUrl: url method: @"GET" params:params headers:@{} completionHandler:func];
}

- (void)        get:(NSString*)url
             params:(NSDictionary*)params
            headers:(NSDictionary*)headers
  completionHandler:(UNCApiHandler)func {

    [self _requestUrl: url method: @"GET" params:params headers:headers completionHandler:func];
}

- (void)        post:(NSString*)url
              params:(NSDictionary*)params
   completionHandler:(UNCApiHandler)func {
    
    [self _requestSerializeBody:url method:@"POST" params:params headers:@{} completionHandler:func];
}

- (void)        post:(NSString*)url
              params:(NSDictionary*)params
             headers:(NSDictionary*)headers
   completionHandler:(UNCApiHandler)func {
    
    [self _requestSerializeBody:url method:@"POST" params:params headers:headers completionHandler:func];
}

- (void)        put:(NSString*)url
             params:(NSDictionary*)params
  completionHandler:(UNCApiHandler)func {
    
    [self _requestSerializeBody:url method:@"PUT" params:params headers:@{} completionHandler:func];
}

- (void)        put:(NSString*)url
             params:(NSDictionary*)params
            headers:(NSDictionary*)headers
  completionHandler:(UNCApiHandler)func {
    
    [self _requestSerializeBody:url method:@"PUT" params:params headers:headers completionHandler:func];
}

- (void)    delete:(NSString*)url
            params:(NSDictionary*)params
 completionHandler:(UNCApiHandler)func {
    
    [self _requestUrl:url method:@"DELETE" params:params headers:@{} completionHandler:func];
}

- (void)    delete:(NSString*)url
            params:(NSDictionary*)params
           headers:(NSDictionary*)headers
 completionHandler:(UNCApiHandler)func {
    
    [self _requestUrl:url method:@"DELETE" params:params headers:headers completionHandler:func];
}


- (void) _requestUrl:(NSString*)url
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

//- (void)_requestBody:(NSString*)url
//             method:(NSString*)method
//             params:(NSDictionary*)params
//            headers:(NSDictionary*)headers
//  completionHandler:(UNCApiHandler)func {
//    
//    NSMutableDictionary* strParams = [NSMutableDictionary new];
//    NSMutableDictionary* binParams = [NSMutableDictionary new];
//    
//    for (NSString* key in params) {
//
//        id o = [params objectForKey: key];
//        
//        if ([o isKindOfClass:[UNCApiData class]]) {
//            [binParams setObject:o forKey: key];
//        } else {
//            [strParams setObject:o forKey: key];
//        }
//    }
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
//    AFHTTPRequestSerializer* serializer = [AFHTTPRequestSerializer serializer];
//
//    for (NSString* key in headers) {
//        NSString* val = [headers objectForKey: key];
//        [serializer setValue: val forHTTPHeaderField: key];
//    }
//    serializer.timeoutInterval = _timeoutInterval;
//
//    NSMutableURLRequest* request = nil;
//    
//    if ([binParams count] > 0) {
//        request = [serializer multipartFormRequestWithMethod:method
//                                                   URLString:url
//                                                  parameters:strParams
//                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//
//                        // XXX データは ネストに対応していない
//                                       
//                        for (NSString* key in binParams) {
//                            UNCApiData* data = [binParams objectForKey: key];
//                            [formData appendPartWithFileData:data.bin
//                                                        name:key
//                                                    fileName:data.fileName
//                                                    mimeType:data.mimeType];
//                        }
//
//                     }
//                                                       error:nil];
//    } else {
//        
//        request = [serializer requestWithMethod:method URLString:url parameters:strParams error:nil];
//    }
//
//    manager.requestSerializer = serializer;
//    
//    __block NSURLSessionDataTask *task =
//    [manager uploadTaskWithStreamedRequest:request
//                                  progress:nil
//                         completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
//
//        if (error) {
//            func(nil, (NSHTTPURLResponse*)[task response], error);
//        } else {
//            func(responseObject, (NSHTTPURLResponse*)[task response], nil);
//        }
//    }];
//    
//    [task resume];
//}

- (void)_requestSerializeBody:(NSString*)urlStr
                       method:(NSString*)method
                       params:(NSDictionary*)params
                      headers:(NSDictionary*)headers
            completionHandler:(UNCApiHandler)func {
    
    
    // AFNetworking使ってない
    NSURL* const url = [NSURL URLWithString:urlStr];
    
    NSString* boundary = [UNCApi _boundaryGenarate];
    
    // データ構築
    NSMutableData* data = [NSMutableData new];
    for (id key in params) {
        id val = params[key];
        [UNCApi _buildBody:data boundary:boundary key:key val:val];
    }
    [UNCApi _dataAppend:data withFormat:@"%@%@%@%@", TWO_HYPHENS, boundary, TWO_HYPHENS, LINE_END];
    
    
    NSMutableURLRequest* const request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request setHTTPBody:data];
    
    NSString* const contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    NSMutableDictionary* const requestHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
    [requestHeaders setObject:contentType forKey:@"Content-Type"];

    NSURLSessionConfiguration* const config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = requestHeaders;
    
    NSURLSession* const session = [NSURLSession sessionWithConfiguration:config];

    
    __block NSURLSessionDataTask *task =
            [session dataTaskWithRequest:request
                       completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            func(nil, (NSHTTPURLResponse*)[task response], error);
        } else {
            func(response, (NSHTTPURLResponse*)[task response], nil);
        }
    }];

    [task resume];
}

+ (void)_buildBody:(NSMutableData*)bos boundary:(NSString*)boundary key:(NSString*)key val:(NSObject*)val {

    if (val == nil) {
        // do nothing
    } else if ([val isKindOfClass:[NSArray class]]) {
        
        for (NSObject* aval in (NSArray*)val) {
            
            NSString* const skey = [NSString stringWithFormat:@"%@[]", key];
            [UNCApi _buildBody:bos boundary:boundary key:skey val:aval];
        }
        
    } else if ([val isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary* cval = (NSDictionary*)val;
        
        for (NSString* dkey in cval) {
            
            NSString* const skey = [NSString stringWithFormat:@"%@[%@]", key, dkey];
            NSObject* const dval = (NSDictionary*)cval[dkey];
            [UNCApi _buildBody:bos boundary:boundary key:skey val:dval];
        }
        
    } else if ([val isKindOfClass:[UNCApiData class]]) {
        
        UNCApiData* const data = (UNCApiData*)val;
        
        [self _dataAppend:bos withFormat:@"%@%@%@", TWO_HYPHENS, boundary, LINE_END];
        [self _dataAppend:bos withFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@", key, data.fileName, LINE_END];
        [self _dataAppend:bos withFormat:@"Content-Type: %@%@", data.mimeType, LINE_END];
        [self _dataAppend:bos withFormat:@"%@", LINE_END];
        [bos appendData:data.bin];
        [self _dataAppend:bos withFormat:@"%@", LINE_END];
        
    } else {

        [self _dataAppend:bos withFormat:@"%@%@%@", TWO_HYPHENS, boundary, LINE_END];
        [self _dataAppend:bos withFormat:@"Content-Disposition: form-data; name=\"%@\"%@", key, LINE_END];
        [self _dataAppend:bos withFormat:@"%@", LINE_END];
        [self _dataAppend:bos withFormat:@"%@", val];
        [self _dataAppend:bos withFormat:@"%@", LINE_END];
    }

}

+ (void)_dataAppend:(NSMutableData*)data withFormat:(NSString*)format, ... {
    va_list args;
    va_start(args, format);
    
    NSString* const str = [[NSString alloc] initWithFormat:format arguments:args];
    
    [data appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    va_end(args);
}

+ (NSString*) _boundaryGenarate {
    NSString* const boundary = [NSString stringWithFormat:@"------UNCAPI%@", [NSUUID UUID].UUIDString];
    return boundary;
}

@end
