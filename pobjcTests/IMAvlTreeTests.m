//
//  IMAvlTreeTests.m
//  pobjc
//
//  Created by Brian Dewey on 6/23/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IMAvlTree.h"
#import "IMBase.h"

static NSUInteger kDictionarySize = 1000;
static NSUInteger kPerformanceTestDictionarySize = 30000;

@interface IMAvlTreeTests : XCTestCase

@end

@implementation IMAvlTreeTests

- (void)testEmpty
{
  IMAvlTree *empty = [IMAvlTree empty];
  XCTAssertTrue(empty.empty, @"");
}

- (void)testInsertSingleItemTree
{
  IMAvlTree *tree = [IMAvlTree empty];
  static NSString *key = @"foo";
  static NSString *value = @"bar";
  tree = [tree setObject:value forKey:key];
  XCTAssertEqual(value, tree[key], @"");
  XCTAssertNil(tree[@"invalid key"], @"");
}

- (void)testDenseLookup
{
  IMAvlTree *tree = [self _treeWithMultiplesOfTwo:kDictionarySize];
  XCTAssertEqual((NSUInteger)1000, tree.count, @"");
  XCTAssertEqual((NSUInteger)10, tree.height, @"");
  for (NSInteger i = 0; i < kDictionarySize * 2; i++) {
    id value = tree[@(i)];
    if (i % 2) {
      XCTAssertNil(value, @"");
    } else {
      XCTAssertEqualObjects(@(i / 2), value, @"");
    }
  }
}

- (void)testInsertionAndLookupPerformance
{
  [self measureBlock:^{
    IMAvlTree *tree = [self _treeWithMultiplesOfTwo:kPerformanceTestDictionarySize];
    for (NSInteger i = 0; i < kPerformanceTestDictionarySize * 2; i++) {
      id value = tree[@(i)];
      if (i % 2) {
        XCTAssertNil(value, @"");
      } else {
        XCTAssertEqual((NSUInteger)i / 2, [value unsignedIntegerValue], @"");
      }
    }
  }];
}

- (void)testEnumeration
{
  const NSUInteger kEnumerationSize = 82;
  IMAvlTree *tree = [self _treeWithMultiplesOfTwo:kEnumerationSize];
  NSInteger runningSum = 0;
  
  // Closed form to calculate the sum of (0..kPerformanceDictionarySize-1) * 2, assuming kPerformanceDictionarySize is even.
  NSInteger expectedSum = (kEnumerationSize - 1) * kEnumerationSize;
  NSInteger lastKey = 0;
  for (NSNumber *key in tree) {
    NSInteger currentKey = [key integerValue];
    runningSum += currentKey;
    
    // We enumerate in hash order.
    XCTAssertGreaterThanOrEqual(currentKey, lastKey, @"");
    lastKey = currentKey;
  }
  XCTAssertEqual(expectedSum, runningSum, @"");
}

- (IMAvlTree *)_treeWithMultiplesOfTwo:(NSUInteger)size
{
  IMAvlTree *tree = [IMAvlTree empty];
  for (NSInteger i = 0; i < size; i++) {
    tree = [tree setObject:@(i) forKey:@(i * 2)];
  }
  return tree;
}

@end
