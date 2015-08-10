//
//  FifthTaskTests.m
//  YandexTestApplicationSenioriOSDeveloper
//
//  Created by Lobanov Dmitry on 09.08.15.
//  Copyright (c) 2015 TestExample. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ThreadSafeDictionary.h"

@interface FifthTaskTests : XCTestCase

@end

@implementation FifthTaskTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAggressiveThreadSafeDictionary {
    
    __block ThreadSafeDictionary *dictionary = [ThreadSafeDictionary new];
    dispatch_queue_t firstQueue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t secondQueue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_async(firstQueue, ^{
        for (int i = 1; i < 10; ++i) {
            [dictionary setObject:@(i + 100) forKey:@"c"];
            NSLog(@"first queue: I set: %@", @(i + 100));
            NSLog(@"first queue: have: %@", [dictionary objectForKey:@"d"]);
        };
    });
    
    dispatch_async(secondQueue, ^{
        for (int i = 1; i < 10; ++i) {
            [dictionary setObject:@(i) forKey:@"d"];
            NSLog(@"second queue: I set: %@", @(i));
            NSLog(@"second queue: have: %@", [dictionary objectForKey:@"c"]);
        }
    });

//    dispatch_group_notify(group, firstQueue, ^{
//        NSLog(@"I've DONE IT!");
//    });
//    
//    dispatch_group_notify(group, secondQueue, ^{
//        NSLog(@"ME TOO!");
//    });
//    
//    
//    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC));

    NSLog(@"dictionary is: %@", dictionary);
    sleep(10);
    //XCTAssert([dictionary count] == 1);
}
@end
