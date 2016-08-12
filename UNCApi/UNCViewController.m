//
//  UNCViewController.m
//  UNCApi
//
//  Created by unchi on 2014/05/07.
//  Copyright (c) 2014年 unchi. All rights reserved.
//

#import "UNCViewController.h"

#import "UNCApi.h"
#import "UNCApiData.h"


@interface UNCViewController ()

@end

@implementation UNCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    

    

}

- (void)viewDidAppear:(BOOL)animated {

    
    UIImage* image = [UIImage imageNamed:@"image.png"];
    NSData* bin = UIImagePNGRepresentation(image);
    
    
    UNCApi* api = [UNCApi new];
    UNCApiData* data = [UNCApiData new];
    data.mimeType = @"image/png";
    data.fileName = @"image.png";
    data.bin = bin;
    
    [api            post:@"http://local-request-test.com/"
                  params:@{ @"aaa": data, @"bbb": @{ @"ccc": @"yoyo" } }
                 headers:@{}
       completionHandler:^(id data, NSHTTPURLResponse *response, NSError *error) {
         
         NSLog (@"error: %@", error);
         NSLog (@"%ld", (long)response.statusCode);
         NSLog (@"%@", data);
        
     }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
