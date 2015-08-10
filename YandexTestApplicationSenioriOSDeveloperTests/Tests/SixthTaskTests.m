//
//  SixthTaskTests.m
//  YandexTestApplicationSenioriOSDeveloper
//
//  Created by Lobanov Dmitry on 09.08.15.
//  Copyright (c) 2015 TestExample. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ThreadSafeDictionary.h"

@interface SixthTaskTests : XCTestCase
@property (nonatomic, strong) NSString *string;
@end

@implementation SixthTaskTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


// should do something
// helper
// cat SixthTest.txt | perl -le '$_ = <>; my %s = (); map{ $s{$_} += 1; }(split //, $_); do { print "$_ => $s{$_}"; } for sort {$s{$a} <=> $s{$b}} keys %s'
// frequent is z

char mostFrequentCharacterVeryFastVersion(const char*str, int size) {
    if (size < 0) {
        return '\0';
    }
    
    if (size < 3) {
        // special cases
        if (size == 0) {
            return '\0';
        }
        else
        if (size == 1) {
            return str[0];
        }
        else
        if (size == 2) {
            return str[1];
        }
    }
    
    int halfSize = size >> 1;
    
    dispatch_queue_t firstQueue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t secondQueue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    
    int allLettersCount = 256;
    int *firstLetters = calloc(allLettersCount, sizeof(int));
    int *secondLetters = calloc(allLettersCount, sizeof(int));
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, firstQueue, ^{
        
        for (int i = 0; i < size - halfSize; ++i) {
            
//            char c = str[i];
            firstLetters[ str[i] ]++;
//            NSNumber *key = @(c);
//            NSNumber *value = [secondDictionary objectForKey:key];
//            
//            if (!value) {
//                value = @(1);
//            }
//            
//            [secondDictionary setObject:@(value.intValue + 1) forKey:key];
        }
    });
    
    dispatch_group_async(group, secondQueue, ^{
        
        for (int i = 0; i < halfSize + 1; ++i) {
//            char c = str[size - i];
            secondLetters[ str[size - i] ]++;
//            NSNumber *key = @(c);
//            NSNumber *value = [firstDictionary objectForKey:key];
//            
//            if (!value) {
//                value = @(0);
//            }
//            
//            [firstDictionary setObject:@(value.intValue + 1) forKey:key];
        }
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    int count = 0;
    char letter = '\0';
    for (int i = 0; i < allLettersCount; ++i) {
        
        int letterCount = (firstLetters[i] + secondLetters[i]);
        
        if (count < letterCount) {
            count = letterCount;
            letter = i;
        }

    }
    
    return letter;
}

char mostFrequentCharacter(const char*str, int size) {

    if (size < 0) {
        return '\0';
    }
    
    if (size < 3) {
        // special cases
        if (size == 0) {
            return '\0';
        }
        else
        if (size == 1) {
            return str[0];
        }
        else
        if (size == 2) {
            return str[1];
        }
    }
    
    int halfSize = size >> 1;
    
    dispatch_queue_t firstQueue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t secondQueue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    ThreadSafeDictionary *firstDictionary = [ThreadSafeDictionary new];
    
    ThreadSafeDictionary *secondDictionary = [ThreadSafeDictionary new];

    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, firstQueue, ^{
        
        for (int i = 0; i < size - halfSize; ++i) {
            
            char c = str[i];
            NSNumber *key = @(c);
            NSNumber *value = [secondDictionary objectForKey:key];
            
            if (!value) {
                value = @(1);
            }
            
            [secondDictionary setObject:@(value.intValue + 1) forKey:key];
        }
    });
    
    dispatch_group_async(group, secondQueue, ^{
        
        for (int i = 0; i < halfSize + 1; ++i) {
            char c = str[size - i];
            NSNumber *key = @(c);
            NSNumber *value = [firstDictionary objectForKey:key];
            
            if (!value) {
                value = @(0);
            }
            
            [firstDictionary setObject:@(value.intValue + 1) forKey:key];
        }
        
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    // reduce
    for (NSNumber *key in [secondDictionary allKeys]) {
        NSNumber *second = [secondDictionary objectForKey:key];
        NSNumber *first = [firstDictionary objectForKey:key];
        if (!first) {
            first = second;
        }
        else {
            first = @(first.intValue + second.intValue);
        }
        
        [firstDictionary setObject:first forKey:key];
    }
    
    
    int count = 0;
    char letter = '\0';
    for (NSNumber *key in [firstDictionary allKeys]) {
        NSNumber *value = [firstDictionary objectForKey:key];
        if (count < value.intValue) {
            count = value.intValue;
            letter = key.charValue;
        }
    }
    
    // should be z
    return letter;
}

- (void) testSearchMostFrequentLetter {
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SixthTest" ofType:@"txt"];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    self.string = string;
    const char *cString = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int size = (int)string.length;
    
    char actual = 'w';
    __block char expected;
    NSLog(@"size of: %d", size);
    [self measureBlock:^{
        expected = mostFrequentCharacterVeryFastVersion(cString, size);
    }];
    
    XCTAssert(actual == expected);
//    
//    // special cases
//    // size less than zero
    size = -1;
    actual = '\0';
    expected = mostFrequentCharacter(cString, size);
    XCTAssert(actual == expected);
    
    // size equal zero
    size = 0;
    actual = '\0';
    expected = mostFrequentCharacter(cString, size);
    XCTAssert(actual == expected);

    // size equal one
    size = 1;
    actual = cString[0];
    expected = mostFrequentCharacter(cString, size);
    XCTAssert(actual == expected);
    
    // size equal two
    size = 2;
    actual = cString[1];
    expected = mostFrequentCharacter(cString, size);
    XCTAssert(actual == expected);
    
}
@end
