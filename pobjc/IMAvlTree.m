//
//  IMAvlTree.m
//  pobjc
//
//  Created by Brian Dewey on 6/23/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import "IMBase.h"
#import "IMAvlTree.h"
#import "IMComparable.h"

@class _IMAvlTreeNode;

@interface IMAvlTree ()

- (id)lookupValueForKey:(id<IMComparable>)key hash:(NSUInteger)hash;
- (void)_addToRecursiveDescription:(NSMutableString *)recursiveDescription indentLevel:(NSUInteger)indentLevel;

@end

@interface _IMAvlTreeEmpty : IMAvlTree

@end

@interface _IMAvlTreeNode : IMAvlTree

// Set properties
@property (nonatomic, readonly, copy) id<IMComparable, NSCopying> key;
@property (nonatomic, readonly, strong) id value;
@property (nonatomic, readonly, strong) IMAvlTree *leftNode;
@property (nonatomic, readonly, strong) IMAvlTree *rightNode;

// Computed properties
@property (nonatomic, readonly, assign) NSUInteger height;

- (instancetype)initWithKey:(id<NSObject, NSCopying>)key
                      value:(id)value
                   leftNode:(IMAvlTree *)leftNode
                  rightNode:(IMAvlTree *)rightNode NS_DESIGNATED_INITIALIZER;

@end

@implementation _IMAvlTreeEmpty

- (NSUInteger)count
{
  return 0;
}

- (NSUInteger)height
{
  return 0;
}

- (BOOL)isEmpty
{
  return YES;
}

- (id)objectForKey:(id<NSCopying>)key
{
  return nil;
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key
{
  return nil;
}

- (id)lookupValueForKey:(id<IMComparable>)key hash:(NSUInteger)hash
{
  return nil;
}

- (IMAvlTree *)setObject:(id)object forKey:(id<IMComparable,NSCopying>)key
{
  return [[_IMAvlTreeNode alloc] initWithKey:key value:object leftNode:self rightNode:self];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
  return 0;
}

- (void)_addToRecursiveDescription:(NSMutableString *)recursiveDescription indentLevel:(NSUInteger)indentLevel
{
  return;
}

@end

@implementation _IMAvlTreeNode
{
  NSUInteger _height;
  NSUInteger _count;
}

- (instancetype)initWithKey:(id<NSObject, NSCopying>)key
                      value:(id)value
                   leftNode:(IMAvlTree *)leftNode
                  rightNode:(IMAvlTree *)rightNode
{
  self = [super init];
  if (self != nil) {
    _key = [key copyWithZone:NULL];
    _value = value;
    _leftNode = leftNode;
    _rightNode = rightNode;
    _height = 1 + MAX(leftNode.height, rightNode.height);
    _count = 1 + leftNode.count + rightNode.count;
#if !NS_BLOCK_ASSERTIONS
    NSInteger heightDelta = (NSInteger)leftNode.height - (NSInteger)rightNode.height;
    NSAssert(heightDelta <= 1 && heightDelta >= -1, @"Balance requirement violated");
#endif
  }
  return self;
}

- (instancetype)initAndRotateRightWithKey:(id<NSObject, NSCopying>)key
                                    value:(id)value
                                 leftNode:(_IMAvlTreeNode *)leftNode
                                rightNode:(IMAvlTree *)rightNode
{
  _IMAvlTreeNode *updatedRightNode = [[_IMAvlTreeNode alloc] initWithKey:key value:value leftNode:leftNode.rightNode rightNode:rightNode];
  return [self initWithKey:leftNode.key value:leftNode.value leftNode:leftNode.leftNode rightNode:updatedRightNode];
}

- (instancetype)initAndRotateLeftWithKey:(id<NSObject, NSCopying>)key
                                    value:(id)value
                                 leftNode:(IMAvlTree *)leftNode
                                rightNode:(_IMAvlTreeNode *)rightNode
{
  _IMAvlTreeNode *updatedLeftNode = [[_IMAvlTreeNode alloc] initWithKey:key value:value leftNode:leftNode rightNode:rightNode.leftNode];
  return [self initWithKey:rightNode.key value:rightNode.value leftNode:updatedLeftNode rightNode:rightNode.rightNode];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<%@ %p: key = %@ value = %@ count = %u height = %u>", NSStringFromClass([self class]), self, _key, _value, _count, _height];
}

- (void)_addToRecursiveDescription:(NSMutableString *)recursiveDescription indentLevel:(NSUInteger)indentLevel
{
  for (NSUInteger i = 0; i < indentLevel; i++) {
    [recursiveDescription appendString:@"  "];
  }
  [recursiveDescription appendString:[self description]];
  [recursiveDescription appendString:@"\n"];
  [_leftNode _addToRecursiveDescription:recursiveDescription indentLevel:indentLevel+1];
  [_rightNode _addToRecursiveDescription:recursiveDescription indentLevel:indentLevel+1];
}

- (NSUInteger)height
{
  return _height;
}

- (NSUInteger)count
{
  return _count;
}

- (BOOL)isEmpty
{
  return NO;
}

- (id)lookupValueForKey:(id<IMComparable>)key hash:(NSUInteger)hash
{
  if ((key == _key) || [key isEqual:_key]) {
    return _value;
  }
  if ([key im_compare:_key] == NSOrderedAscending) {
    return [_leftNode lookupValueForKey:key hash:hash];
  } else {
    return [_rightNode lookupValueForKey:key hash:hash];
  }
}

- (IMAvlTree *)setObject:(id)value forKey:(id<IMComparable,NSCopying>)key
{
  if ((key == _key) || [key isEqual:_key]) {
    return [[_IMAvlTreeNode alloc] initWithKey:key value:value leftNode:_leftNode rightNode:_rightNode];
  }
  NSComparisonResult comparisonResult = [key im_compare:_key];
  if (comparisonResult == NSOrderedAscending) {
    _IMAvlTreeNode *updatedLeftChild = (_IMAvlTreeNode *)[_leftNode setObject:value forKey:key];
    if (updatedLeftChild.height > _rightNode.height + 1) {
      if (updatedLeftChild.rightNode.height > updatedLeftChild.leftNode.height) {
        updatedLeftChild = [updatedLeftChild _rotateLeft];
      }
      return [[_IMAvlTreeNode alloc] initAndRotateRightWithKey:_key value:_value leftNode:updatedLeftChild rightNode:_rightNode];
    }
    return [[_IMAvlTreeNode alloc] initWithKey:_key value:_value leftNode:updatedLeftChild rightNode:_rightNode];
  } else {
    _IMAvlTreeNode *updatedRightChild = (_IMAvlTreeNode *)[_rightNode setObject:value forKey:key];
    if (updatedRightChild.height > _leftNode.height + 1) {
      if (updatedRightChild.leftNode.height > updatedRightChild.rightNode.height) {
        updatedRightChild = [updatedRightChild _rotateRight];
      }
      return [[_IMAvlTreeNode alloc] initAndRotateLeftWithKey:_key value:_value leftNode:_leftNode rightNode:updatedRightChild];
    }
    return [[_IMAvlTreeNode alloc] initWithKey:_key value:_value leftNode:_leftNode rightNode:updatedRightChild];
  }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
  const NSUInteger kItemsInBufferIndex = 0;
  const NSUInteger kOffsetIntoTreeIndex = 1;
  const NSUInteger kItemsToSkipThisIterationIndex = 2;
  if (state->state == 0) {
    state->mutationsPtr = (unsigned long *)objc_unretainedPointer(self);
    state->state = 1;
    state->extra[kOffsetIntoTreeIndex] = 0;
  }
  if (state->mutationsPtr == objc_unretainedPointer(self)) {
    state->itemsPtr = buffer;
    
    // extra[0] holds how many items we've copied into the buffer so far
    state->extra[kItemsInBufferIndex] = 0;
    state->extra[kItemsToSkipThisIterationIndex] = state->extra[kOffsetIntoTreeIndex];
  }
  if (state->extra[kItemsToSkipThisIterationIndex] >= _leftNode.count) {
    state->extra[kItemsToSkipThisIterationIndex] -= _leftNode.count;
  } else {
    [_leftNode countByEnumeratingWithState:state objects:buffer count:len];
  }
  if (state->extra[kItemsToSkipThisIterationIndex] > 0) {
    // We're supposed to skip this item instead of copying it into the buffer.
    state->extra[kItemsToSkipThisIterationIndex]--;
  } else if (state->extra[kItemsInBufferIndex] < len) {
    buffer[state->extra[kItemsInBufferIndex]] = _key;
    state->extra[kItemsInBufferIndex]++;
  }
  if (state->extra[kItemsInBufferIndex] < len) {
    [_rightNode countByEnumeratingWithState:state objects:buffer count:len];
  }
  if (state->mutationsPtr == objc_unretainedPointer(self)) {
    state->extra[kOffsetIntoTreeIndex] += state->extra[kItemsInBufferIndex];
  }
  return state->extra[kItemsInBufferIndex];
}

- (_IMAvlTreeNode *)_rotateLeft
{
  NSAssert([_rightNode isKindOfClass:[_IMAvlTreeNode class]], @"Expected an _IMAvlTreeNode");
  _IMAvlTreeNode *rightNode = (_IMAvlTreeNode *)_rightNode;
  return [[_IMAvlTreeNode alloc] initAndRotateLeftWithKey:_key value:_value leftNode:_leftNode rightNode:rightNode];
}

- (_IMAvlTreeNode *)_rotateRight
{
  NSAssert([_leftNode isKindOfClass:[_IMAvlTreeNode class]], @"Expected an _IMAvlTreeNode");
  _IMAvlTreeNode *leftNode = (_IMAvlTreeNode *)_leftNode;
  return [[_IMAvlTreeNode alloc] initAndRotateRightWithKey:_key value:_value leftNode:leftNode rightNode:_rightNode];
}

@end

@implementation IMAvlTree

+ (IMAvlTree *)empty
{
  static _IMAvlTreeEmpty *empty;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    empty = [[_IMAvlTreeEmpty alloc] init];
  });
  return empty;
}

- (NSUInteger)count
{
  IM_SUBCLASS_MUST_OVERRIDE();
}

- (NSUInteger)height
{
  IM_SUBCLASS_MUST_OVERRIDE();
}

- (BOOL)isEmpty
{
  IM_SUBCLASS_MUST_OVERRIDE();
}

- (IMAvlTree *)setObject:(id)object forKey:(id<IMComparable, NSCopying>)key
{
  IM_SUBCLASS_MUST_OVERRIDE();
}

- (id)lookupValueForKey:(id<IMComparable>)key hash:(NSUInteger)hash
{
  IM_SUBCLASS_MUST_OVERRIDE();
}

- (id)objectForKey:(id<IMComparable, NSCopying>)key
{
  return [self lookupValueForKey:key hash:[key hash]];
}

- (id)objectForKeyedSubscript:(id<IMComparable, NSCopying>)key
{
  return [self lookupValueForKey:key hash:[key hash]];
}

- (NSString *)recursiveDescription
{
  NSMutableString *result = [NSMutableString new];
  [self _addToRecursiveDescription:result indentLevel:0];
  return result;
}

- (void)_addToRecursiveDescription:(NSMutableString *)recursiveDescription indentLevel:(NSUInteger)indentLevel
{
  IM_SUBCLASS_MUST_OVERRIDE();
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
  IM_SUBCLASS_MUST_OVERRIDE();
}

@end
