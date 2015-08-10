//
//  ThreadSafeDictionary.h
//  YandexTestApplicationSenioriOSDeveloper
//
//  Created by Lobanov Dmitry on 09.08.15.
//  Copyright (c) 2015 TestExample. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreadSafeDictionary : NSObject

- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (void)removeAllObjects;
- (void)setObject:(id)object forKey:(id)aKey;
- (NSArray *)allKeys;
@end
