//
//  FirstTaskTests.m
//  YandexTestApplicationSenioriOSDeveloper
//
//  Created by Lobanov Dmitry on 09.08.15.
//  Copyright (c) 2015 TestExample. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface FirstTaskTests : XCTestCase

@end

@implementation FirstTaskTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (UIImage *)syncProcessData:(NSData *)data {
    
    __block UIImage *resultImage = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self asyncProcessData:data success:^(UIImage *image) {
        NSLog(@"image is: %@", image);
        resultImage = image;
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSError *failure) {
        NSLog(@"failure is %@", failure);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return resultImage;
}

- (void)asyncProcessData:(NSData *)data
                 success:(void(^)(UIImage *image))success
                 failure:(void(^)(NSError *failure))failure {
    
    BOOL result = YES;
    if (result) {
        if (success) {
            success([UIImage new]);
        };
    }
    else {
        if (failure) {
            failure(nil);
        }
    }
}

- (void)testSync {
    XCTAssertTrue([self syncProcessData:nil] != nil);
}

@end
