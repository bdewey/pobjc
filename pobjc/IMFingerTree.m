//
//  IMFingerTree.m
//  pobjc
//
//  Created by Brian Dewey on 6/22/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import "IMBase.h"
#import "IMFingerTree.h"

static NSString * const kEmptyDequeueMessage = @"Cannot dequeue from the empty queue";

@class _IMFingerTreeDigitTuple;
@class _IMFingerTreeDigit;

@interface _IMFingerTreeEmpty : IMFingerTree

@end

@interface _IMFingerTreeSingle : IMFingerTree

- (instancetype)initWithObject:(id)object NS_DESIGNATED_INITIALIZER;

@end

@interface _IMFingerTreeNode : IMFingerTree

@property (nonatomic, readonly, strong) _IMFingerTreeDigit *leftDigit;
@property (nonatomic, readonly, strong) IMFingerTree *tree;
@property (nonatomic, readonly, strong) _IMFingerTreeDigit *rightDigit;

- (instancetype)initWithLeftDigit:(_IMFingerTreeDigit *)leftDigit tree:(IMFingerTree *)tree rightDigit:(_IMFingerTreeDigit *)rightDigit NS_DESIGNATED_INITIALIZER;

@end

@interface _IMFingerTreeDigit : NSObject

@property (nonatomic, readonly, copy) NSArray *objects;

- (instancetype)initWithObjects:(NSArray *)objects;
- (id)peekLeft;
- (id)peekRight;
- (_IMFingerTreeDigitTuple *)enqueueLeft:(id)object;
- (_IMFingerTreeDigitTuple *)enqueueRight:(id)object;
- (_IMFingerTreeDigit *)dequeueLeft;
- (_IMFingerTreeDigit *)dequeueRight;

@end

@interface _IMFingerTreeDigitTuple : NSObject

@property (nonatomic, readonly, strong) _IMFingerTreeDigit *digit;
@property (nonatomic, readonly, strong) _IMFingerTreeDigit *extraDigit;

- (instancetype)initWithDigit:(_IMFingerTreeDigit *)digit extraDigit:(_IMFingerTreeDigit *)extraDigit NS_DESIGNATED_INITIALIZER;

@end

@implementation _IMFingerTreeEmpty

- (BOOL)isEmpty {
  return YES;
}

- (id)peekLeft {
  return nil;
}

- (id)peekRight {
  return nil;
}

- (id)dequeueLeft {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:kEmptyDequeueMessage userInfo:nil];
}

- (id)dequeueRight {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:kEmptyDequeueMessage userInfo:nil];
}

- (id)enqueueLeft:(id)object {
  return [[_IMFingerTreeSingle alloc] initWithObject:object];
}

- (id)enqueueRight:(id)object {
  return [[_IMFingerTreeSingle alloc] initWithObject:object];
}

@end

@implementation _IMFingerTreeSingle
{
  id _object;
}

- (instancetype)initWithObject:(id)object
{
  self = [super init];
  if (self) {
    _object = object;
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ %@", [super description], _object];
}

- (BOOL)isEmpty
{
  return NO;
}

- (id)peekLeft
{
  return _object;
}

- (id)peekRight
{
  return _object;
}

- (IMFingerTree *)enqueueLeft:(id)object
{
  return [self _treeWithLeftObject:object rightObject:_object];
}

- (IMFingerTree *)enqueueRight:(id)object
{
  return [self _treeWithLeftObject:_object rightObject:object];
}

- (IMFingerTree *)_treeWithLeftObject:(id)leftObject rightObject:(id)rightObject
{
  _IMFingerTreeDigit *leftDigit = [[_IMFingerTreeDigit alloc] initWithObjects:[NSArray arrayWithObject:leftObject]];
  _IMFingerTreeDigit *rightDigit = [[_IMFingerTreeDigit alloc] initWithObjects:[NSArray arrayWithObject:rightObject]];
  return [[_IMFingerTreeNode alloc] initWithLeftDigit:leftDigit tree:[IMFingerTree empty] rightDigit:rightDigit];
}

- (IMFingerTree *)dequeueLeft
{
  return [IMFingerTree empty];
}

- (IMFingerTree *)dequeueRight
{
  return [IMFingerTree empty];
}

@end

@implementation _IMFingerTreeNode

- (instancetype)initWithLeftDigit:(_IMFingerTreeDigit *)leftDigit
                             tree:(IMFingerTree *)tree
                       rightDigit:(_IMFingerTreeDigit *)rightDigit
{
  self = [super init];
  if (self != nil) {
    _leftDigit = leftDigit;
    _tree = tree;
    _rightDigit = rightDigit;
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<%@ %p: left = %@\n\ttree = %@\n\tright=%@\n>", NSStringFromClass([self class]), self, _leftDigit, _tree, _rightDigit];
}

- (BOOL)isEmpty
{
  return NO;
}

- (id)peekLeft
{
  return [_leftDigit peekLeft];
}

- (id)peekRight
{
  return [_rightDigit peekRight];
}

- (IMFingerTree *)enqueueLeft:(id)object
{
  IMFingerTree *tree = _tree;
  _IMFingerTreeDigitTuple *tuple = [_leftDigit enqueueLeft:object];
  if (tuple.extraDigit != nil) {
    tree = [_tree enqueueLeft:tuple.extraDigit];
  }
  return [[_IMFingerTreeNode alloc] initWithLeftDigit:tuple.digit tree:tree rightDigit:_rightDigit];
}

- (IMFingerTree *)enqueueRight:(id)object
{
  IMFingerTree *tree = _tree;
  _IMFingerTreeDigitTuple *tuple = [_rightDigit enqueueRight:object];
  if (tuple.extraDigit != nil) {
    tree = [_tree enqueueRight:tuple.extraDigit];
  }
  return [[_IMFingerTreeNode alloc] initWithLeftDigit:_leftDigit tree:tree rightDigit:tuple.digit];
}

- (IMFingerTree *)dequeueLeft
{
  _IMFingerTreeDigit *updatedLeft = [_leftDigit dequeueLeft];
  if (updatedLeft != nil) {
    return [[_IMFingerTreeNode alloc] initWithLeftDigit:updatedLeft tree:_tree rightDigit:_rightDigit];
  }
  if (!_tree.empty) {
    updatedLeft = [_tree peekLeft];
    IMFingerTree *updatedTree = [_tree dequeueLeft];
    return [[_IMFingerTreeNode alloc] initWithLeftDigit:updatedLeft tree:updatedTree rightDigit:_rightDigit];
  }
  id stolenFromRight = [_rightDigit peekLeft];
  _IMFingerTreeDigit *updatedRight = [_rightDigit dequeueLeft];
  if (updatedRight != nil) {
    return [[_IMFingerTreeNode alloc] initWithLeftDigit:[[_IMFingerTreeDigit alloc] initWithObjects:[NSArray arrayWithObject:stolenFromRight]] tree:[IMFingerTree empty] rightDigit:updatedRight];
  } else {
    return [[_IMFingerTreeSingle alloc] initWithObject:stolenFromRight];
  }
}

- (IMFingerTree *)dequeueRight
{
  _IMFingerTreeDigit *updatedRight = [_rightDigit dequeueRight];
  if (updatedRight != nil) {
    return [[_IMFingerTreeNode alloc] initWithLeftDigit:_leftDigit tree:_tree rightDigit:updatedRight];
  }
  if (!_tree.empty) {
    updatedRight = [_tree peekRight];
    IMFingerTree *updatedTree = [_tree dequeueRight];
    return [[_IMFingerTreeNode alloc] initWithLeftDigit:_leftDigit tree:updatedTree rightDigit:updatedRight];
  }
  id stolenFromLeft = [_leftDigit peekRight];
  _IMFingerTreeDigit *updatedLeft = [_leftDigit dequeueRight];
  if (updatedLeft != nil) {
    return [[_IMFingerTreeNode alloc] initWithLeftDigit:updatedLeft tree:[IMFingerTree empty] rightDigit:[[_IMFingerTreeDigit alloc] initWithObjects:[NSArray arrayWithObject:stolenFromLeft]]];
  } else {
    return [[_IMFingerTreeSingle alloc] initWithObject:stolenFromLeft];
  }
}

@end

static const NSUInteger kIMFingerTreeDigitMaxObjects = 4;

@implementation _IMFingerTreeDigit
{
  NSUInteger _count;
}

- (instancetype)initWithObjects:(NSArray *)objects
{
  self = [super init];
  if (self != nil) {
    _objects = objects;
    _count = _objects.count;
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ %@", [super description], _objects];
}

- (id)peekLeft
{
  return _objects[0];
}

- (id)peekRight
{
  return _objects[_count-1];
}

- (_IMFingerTreeDigitTuple *)enqueueLeft:(id)object
{
  if (_count < kIMFingerTreeDigitMaxObjects) {
    NSMutableArray *updatedObjects = [_objects mutableCopy];
    [updatedObjects insertObject:object atIndex:0];
    _IMFingerTreeDigit *updatedDigit = [[_IMFingerTreeDigit alloc] initWithObjects:updatedObjects];
    return [[_IMFingerTreeDigitTuple alloc] initWithDigit:updatedDigit extraDigit:nil];
  } else {
    NSArray *firstArray = [[NSArray alloc] initWithObjects:object, _objects[0], nil];
    NSArray *secondArray = [[NSArray alloc] initWithObjects:_objects[1], _objects[2], _objects[3], nil];
    _IMFingerTreeDigit *digit = [[_IMFingerTreeDigit alloc] initWithObjects:firstArray];
    _IMFingerTreeDigit *extraDigit = [[_IMFingerTreeDigit alloc] initWithObjects:secondArray];
    return [[_IMFingerTreeDigitTuple alloc] initWithDigit:digit extraDigit:extraDigit];
  }
}

- (_IMFingerTreeDigitTuple *)enqueueRight:(id)object
{
  if (_count < kIMFingerTreeDigitMaxObjects) {
    NSMutableArray *updatedObjects = [_objects mutableCopy];
    [updatedObjects addObject:object];
    _IMFingerTreeDigit *updatedDigit = [[_IMFingerTreeDigit alloc] initWithObjects:updatedObjects];
    return [[_IMFingerTreeDigitTuple alloc] initWithDigit:updatedDigit extraDigit:nil];
  } else {
    NSArray *firstArray = [[NSArray alloc] initWithObjects:_objects[3], object, nil];
    NSArray *secondArray = [[NSArray alloc] initWithObjects:_objects[0], _objects[1], _objects[2], nil];
    _IMFingerTreeDigit *digit = [[_IMFingerTreeDigit alloc] initWithObjects:firstArray];
    _IMFingerTreeDigit *extraDigit = [[_IMFingerTreeDigit alloc] initWithObjects:secondArray];
    return [[_IMFingerTreeDigitTuple alloc] initWithDigit:digit extraDigit:extraDigit];
  }
}

- (_IMFingerTreeDigit *)dequeueLeft
{
  if (_count == 1) {
    return nil;
  }
  NSMutableArray *updatedObjects = [_objects mutableCopy];
  [updatedObjects removeObjectAtIndex:0];
  return [[_IMFingerTreeDigit alloc] initWithObjects:updatedObjects];
}

- (_IMFingerTreeDigit *)dequeueRight
{
  if (_count == 1) {
    return nil;
  }
  NSMutableArray *updatedObjects = [_objects mutableCopy];
  [updatedObjects removeLastObject];
  return [[_IMFingerTreeDigit alloc] initWithObjects:updatedObjects];
}

@end

@implementation _IMFingerTreeDigitTuple

- (instancetype)initWithDigit:(_IMFingerTreeDigit *)digit extraDigit:(_IMFingerTreeDigit *)extraDigit
{
  self = [super init];
  if (self != nil) {
    _digit = digit;
    _extraDigit = extraDigit;
  }
  return self;
}

@end

@implementation IMFingerTree

+ (IMFingerTree *)empty {
  static _IMFingerTreeEmpty *empty;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    empty = [[_IMFingerTreeEmpty alloc] init];
  });
  return empty;
}

- (BOOL)isEmpty {
  IM_SUBCLASS_MUST_OVERRIDE();
}

- (id)peekLeft {
  IM_SUBCLASS_MUST_OVERRIDE();
}

- (id)peekRight {
  IM_SUBCLASS_MUST_OVERRIDE();
}

- (id)enqueueLeft:(id)object {
  IM_SUBCLASS_MUST_OVERRIDE();
}

- (id)enqueueRight:(id)object {
  IM_SUBCLASS_MUST_OVERRIDE();
}

- (id)dequeueLeft {
  IM_SUBCLASS_MUST_OVERRIDE();
}

- (id)dequeueRight {
  IM_SUBCLASS_MUST_OVERRIDE();
}

@end
