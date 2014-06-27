//
//  Api.h
//
//  Created by unchi on 2013/12/06.
//  Copyright (c) 2013年 unchi. All rights reserved.
//


@class NSURLResponse;


@interface UNCApi : NSObject

typedef void (^UNCApiHandler)(id data, NSHTTPURLResponse* response, NSError* error);


@property NSInteger timeoutInterval;


- (void)        get:(NSString*)url
             params:(NSDictionary*)params
  completionHandler:(UNCApiHandler)func;

- (void)        get:(NSString*)url
             params:(NSDictionary*)params
            headers:(NSDictionary*)headers
  completionHandler:(UNCApiHandler)func;


- (void)        post:(NSString*)url
              params:(NSDictionary*)params
   completionHandler:(UNCApiHandler)func;

- (void)        post:(NSString*)url
              params:(NSDictionary*)params
             headers:(NSDictionary*)headers
   completionHandler:(UNCApiHandler)func;


- (void)        put:(NSString*)url
             params:(NSDictionary*)params
  completionHandler:(UNCApiHandler)func;

- (void)        put:(NSString*)url
             params:(NSDictionary*)params
            headers:(NSDictionary*)headers
  completionHandler:(UNCApiHandler)func;


- (void)        delete:(NSString*)url
                params:(NSDictionary*)params
    completionHandler:(UNCApiHandler)func;

- (void)        delete:(NSString*)url
                params:(NSDictionary*)params
                headers:(NSDictionary*)headers
    completionHandler:(UNCApiHandler)func;

@end
