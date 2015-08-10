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

static char kMostFrequentCharacter = 'w';
static NSString *kTestDataFilename = @"SixthTestsData";
// helpers
// generate items

// perl -e 'print map { (q(a)..q(z))[rand(26)] } 1 .. 10_000_000' > SixthTestsData.txt

// count items

// cat SixthTestsData.txt | perl -le '$_ = <>; my %s = (); map{ $s{$_} += 1; }(split //, $_); do { print "$_ => $s{$_}"; } for sort {$s{$a} <=> $s{$b}} keys %s'


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

char mostFrequentCharacterStraight(const char*str, int size) {
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
    
    
    int allLettersCount = 256;
    int *firstLetters = calloc(allLettersCount, sizeof(int));
    
    // compute characters frequency
    int count = 0;
    char character = '\0';
    for (int i = 0; i < size; ++i) {
        
        int characterCount = ++firstLetters[ str[ i ] ];
        
        if (count < characterCount) {
            count = characterCount;
            character = i;
        }
        
    }
    
    return character;
}

char mostFrequentCharacterFast(const char*str, int size) {
    
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
        
        for (int i = 0; i < halfSize; ++i) {
            firstLetters[ str[i] ]++;
        }
        
    });
    
    dispatch_group_async(group, secondQueue, ^{
        for (int i = halfSize; i < size; ++i) {
            secondLetters[ str[i] ]++;
        }
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    int count = 0;
    char character = '\0';
    for (int i = 0; i < allLettersCount; ++i) {
        
        int characterCount = (firstLetters[i] + secondLetters[i]);
        
        if (count < characterCount) {
            count = characterCount;
            character = i;
        }

    }
    
    return character;
}

- (void) testFastVersionPerformance {
    NSError *error = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:kTestDataFilename ofType:@"txt"];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"error: %@", error);
        return;
    }
    
    self.string = string;
    const char *cString = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int size = (int)string.length;

    [self measureBlock:^{
        mostFrequentCharacterFast(cString, size);
    }];
}

- (void) testSlowVersionPerformance {
    NSError *error = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:kTestDataFilename ofType:@"txt"];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"error: %@", error);
        return;
    }
    
    self.string = string;
    const char *cString = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int size = (int)string.length;

    [self measureBlock:^{
        mostFrequentCharacterStraight(cString, size);
    }];
}

- (void) testSearchMostFrequentLetter {
    NSError *error = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:kTestDataFilename ofType:@"txt"];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"error: %@", error);
        return;
    }
    
    self.string = string;
    const char *cString = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int size = (int)string.length;
    
    char actual = kMostFrequentCharacter;
    __block char expected;
    NSLog(@"size of: %d", size);
    [self measureBlock:^{
        expected = mostFrequentCharacterFast(cString, size);
    }];
    
    XCTAssert(actual == expected);
    
    // special cases
    // size less than zero
    size = -1;
    actual = '\0';
    expected = mostFrequentCharacterFast(cString, size);
    XCTAssert(actual == expected);
    
    // size equal zero
    size = 0;
    actual = '\0';
    expected = mostFrequentCharacterFast(cString, size);
    XCTAssert(actual == expected);

    // size equal one
    size = 1;
    actual = cString[0];
    expected = mostFrequentCharacterFast(cString, size);
    XCTAssert(actual == expected);
    
    // size equal two
    size = 2;
    actual = cString[1];
    expected = mostFrequentCharacterFast(cString, size);
    XCTAssert(actual == expected);
    
}
@end
