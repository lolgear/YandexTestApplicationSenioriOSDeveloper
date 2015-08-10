//
//  SecondTaskTests.m
//  YandexTestApplicationSenioriOSDeveloper
//
//  Created by Lobanov Dmitry on 09.08.15.
//  Copyright (c) 2015 TestExample. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface SecondTaskTests : XCTestCase

@end

@implementation SecondTaskTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)processItem:(id)item
          revision:(NSInteger)revision
        completion:(void(^)(NSInteger newRevision, id item))completion {
    if (completion) {
        completion( [self newRevisionForItem:item withOldRevision:revision], item );
    }
}

- (NSInteger) newRevisionForItem:(id)item withOldRevision:(NSInteger)revision {
    return [item doubleValue] + revision;
}

-(void)processItems:(NSArray *)items
           revision:(NSInteger)revision
         completion:(void(^)(NSInteger newRevision))completion {
    
    dispatch_queue_t queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, DISPATCH_QUEUE_SERIAL);
    
    __block NSInteger currentRevision = revision;
    dispatch_apply(items.count, queue, ^(size_t i) {
        [self processItem:items[i] revision:currentRevision completion:^(NSInteger newRevision, id item) {
            currentRevision = newRevision;
            NSLog(@"current element: %@ with revision: %ld", item, (long)currentRevision);
            completion(currentRevision);
        }];
    });
}


- (void) testSyncRevision {
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    
    __block NSInteger revision = 0;
    
    NSArray *expectedRevisions = @[];
    NSInteger oldRevision = revision;

    for (id item in array) {
        NSInteger newRevision = [self newRevisionForItem:item withOldRevision:oldRevision];
        expectedRevisions = [expectedRevisions arrayByAddingObject:@(newRevision)];
        oldRevision = newRevision;
    }
    
    __block NSArray *revisions = @[];
    dispatch_queue_t queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        [self processItems:array revision:revision completion:^(NSInteger newRevision) {
            // do something
            NSLog(@"current revision: %ld", (long)newRevision);
            revisions = [revisions arrayByAddingObject:@(newRevision)];
        }];
    });
    
    NSLog(@"revisions: %@ and expected: %@",revisions, expectedRevisions);
    XCTAssert([revisions isEqualToArray:expectedRevisions]);
}

@end
