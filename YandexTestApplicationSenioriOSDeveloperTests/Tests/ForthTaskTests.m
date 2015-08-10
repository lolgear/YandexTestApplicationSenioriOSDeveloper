//
//  ForthTaskTests.m
//  YandexTestApplicationSenioriOSDeveloper
//
//  Created by Lobanov Dmitry on 09.08.15.
//  Copyright (c) 2015 TestExample. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <objc/runtime.h>

@interface ForthTaskTests : XCTestCase

@end

@implementation ForthTaskTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)downloadImageFromURL:(NSURL *)URL intoCell:(UITableViewCell *)cell {
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            // do something
            NSLog(@"error: %@", connectionError);
        }
        else {
            NSLog(@"image loaded!");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                cell.imageView.image = [UIImage imageWithData:data];
            }];
        }
    }];
}

- (void)testImageDownloading {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any"];
    NSURL *url = [NSURL URLWithString:@"http://creationview.com/image/Birds4F.jpg"];
    [self downloadImageFromURL:url intoCell:cell];
    sleep(5);
    XCTAssertTrue(YES);
}

@end
