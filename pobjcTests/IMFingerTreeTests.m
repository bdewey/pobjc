//
//  IMFingerTreeTests.m
//  pobjc
//
//  Created by Brian Dewey on 6/22/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IMFingerTree.h"

static const NSInteger kNumIterations = 1000;

@interface IMFingerTreeTests : XCTestCase

@end

@implementation IMFingerTreeTests

- (void)testEnqueueLeft
{
  IMFingerTree *tree = [self _treeFromSuccessiveLeftEnqueue];
  for (NSInteger i = 0; i < kNumIterations; i++) {
    NSInteger dequeued = [[tree peekRight] integerValue];
    XCTAssertEqual(dequeued, i, @"");
    tree = [tree dequeueRight];
  }
  XCTAssertEqual(tree, [IMFingerTree empty], @"");
}

- (void)testEnqueueRightDequeueRight
{
  IMFingerTree *tree = [self _treeFromSuccessiveRightEnqueue];
  for (NSInteger i = 0; i < kNumIterations; i++) {
    NSInteger expected = kNumIterations - i - 1;
    NSInteger actual = [[tree peekRight] integerValue];
    XCTAssertEqual(expected, actual, @"");
    tree = [tree dequeueRight];
  }
}

- (void)testEnqueueRightDequeueLeft
{
  IMFingerTree *tree = [self _treeFromSuccessiveRightEnqueue];
  for (NSInteger i = 0; i < kNumIterations; i++) {
    NSInteger value = [[tree peekLeft] integerValue];
    XCTAssertEqual(value, i, @"");
    tree = [tree dequeueLeft];
  }
}

- (void)testPerformanceEnqueue {
  [self measureBlock:^{
    [self _treeFromSuccessiveLeftEnqueue];
  }];
}

- (void)testPerformanceDequeue {
  IMFingerTree *tree = [self _treeFromSuccessiveLeftEnqueue];
  [self measureBlock:^{
    IMFingerTree *blockTree = tree;
    for (NSInteger i = 0; i < kNumIterations; i++) {
      blockTree = [blockTree dequeueRight];
    }
    XCTAssertEqual(blockTree, [IMFingerTree empty], @"");
  }];
}

- (IMFingerTree *)_treeFromSuccessiveLeftEnqueue
{
  IMFingerTree *tree = [IMFingerTree empty];
  for (NSInteger i = 0; i < kNumIterations; i++) {
    tree = [tree enqueueLeft:@(i)];
  }
  return tree;
}

- (IMFingerTree *)_treeFromSuccessiveRightEnqueue
{
  IMFingerTree *tree = [IMFingerTree empty];
  for (NSInteger i = 0; i < kNumIterations; i++) {
    tree = [tree enqueueRight:@(i)];
  }
  return tree;
}

- (void)testPerformanceArrayAppend {
  [self measureBlock:^{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:kNumIterations];
    for (NSInteger i = 0; i < kNumIterations; i++) {
      [array addObject:@(i)];
    }
  }];
}

@end
