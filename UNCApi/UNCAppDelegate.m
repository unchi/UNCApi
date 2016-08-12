//
//  UNCAppDelegate.m
//  UNCApi
//
//  Created by unchi on 2014/05/07.
//  Copyright (c) 2014年 unchi. All rights reserved.
//

#import "UNCAppDelegate.h"

#import "UNCApi.h"
#import "UNCApiData.h"


@implementation UNCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
    
    
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{

    
    UIImage* image = [UIImage imageNamed:@"image.png"];
    NSData* bin = UIImagePNGRepresentation(image);
    
    
    UNCApi* api = [UNCApi new];
    UNCApiData* data = [UNCApiData new];
    data.mimeType = @"image/png";
    data.fileName = @"image.png";
    data.bin = bin;
    
    
    
    [api            post:@"http://local-request-test.com/"
                  params:@{ @"aaa": data, @"hoge": @"test" }
                 headers:@{}
       completionHandler:^(id data, NSHTTPURLResponse *response, NSError *error) {
           
           NSLog (@"error: %@", error);
           NSLog (@"%ld", (long)response.statusCode);
           NSLog (@"%@", data);
           
       }];
    
    
    
    
    
    // 成功時には UIBackgroundFetchResultNewData を渡して completionHandler を呼ぶ
 
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
