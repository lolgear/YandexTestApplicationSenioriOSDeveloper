//
//  ThreadSafeDictionary.m
//  YandexTestApplicationSenioriOSDeveloper
//
//  Created by Lobanov Dmitry on 09.08.15.
//  Copyright (c) 2015 TestExample. All rights reserved.
//

#import "ThreadSafeDictionary.h"

@interface ThreadSafeDictionary() {
    dispatch_queue_t _queue;
}

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation ThreadSafeDictionary

#pragma mark - Instantiation
- (instancetype) init {
    self = [super init];
    if (self) {
        self.dictionary = @{};
        _queue = dispatch_queue_create("com.threadSafeDictionary", NULL);
    }
    return self;
}

#pragma mark - Public Methods
- (NSUInteger)count {
    // doesn't work if we add something to it
    __block NSUInteger localCount;
    dispatch_sync(_queue, ^{
        localCount = self.dictionary.count;
    });
    return localCount;
}

- (id)objectForKey:(id)aKey {
    // we should read it well if we could ( others should not write to it )
    __block id localObject = nil;
    
    dispatch_sync(_queue, ^{
        if (aKey) {
            localObject = self.dictionary[aKey];
        }
        // nil otherwise
    });
    
    return localObject;
}

- (void) removeAllObjects {
    // we should block others and remove them
    dispatch_barrier_async(_queue, ^{
        self.dictionary = @{};
    });
}

- (void) setObject:(id)object forKey:(id)aKey {
    // we should block others
    dispatch_barrier_async(_queue, ^{
        NSMutableDictionary *mutableDictionary = [self.dictionary mutableCopy];

        if (!aKey) {
            return;
        }
        
        if (object == nil) {
            [mutableDictionary removeObjectForKey:aKey];
        }
        else {
            mutableDictionary[aKey] = object;
        }
        
        self.dictionary = [mutableDictionary copy];
    });
}

// for debug only
- (NSString *)description {
    return [self.dictionary description];
}

@end
