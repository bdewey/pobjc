//
//  IMAvlTree.h
//  pobjc
//
//  Created by Brian Dewey on 6/23/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMComparable;

@interface IMAvlTree : NSObject <NSFastEnumeration>

@property (nonatomic, readonly, assign) NSUInteger count;
@property (nonatomic, readonly, assign, getter=isEmpty) BOOL empty;
@property (nonatomic, readonly, assign) NSUInteger height;
@property (nonatomic, readonly, copy) NSString *recursiveDescription;

+ (IMAvlTree *)empty;
- (IMAvlTree *)setObject:(id)object forKey:(id<IMComparable, NSCopying>)key;
- (id)objectForKey:(id<IMComparable, NSCopying>)key;
- (id)objectForKeyedSubscript:(id<IMComparable, NSCopying>)key;

@end
