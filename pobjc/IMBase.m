//
//  IMBase.m
//  pobjc
//
//  Created by Brian Dewey on 6/23/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import "IMBase.h"

NSString * const kSubclassMustOverride = @"Subclass must override this method";
NSString * const kNotImplemented = @"Not implemented";
NSString * const kMismatchedComparisonTypes = @"Mismatched types for comparison";

@implementation NSNumber (IMComparable)

- (NSComparisonResult)im_compare:(id)otherObject
{
  if (![otherObject isKindOfClass:[NSNumber class]]) {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:kMismatchedComparisonTypes userInfo:nil];
  }
  NSNumber *otherNumber = (NSNumber *)otherObject;
  return [self compare:otherNumber];
}

@end

@implementation NSString (IMComparable)

- (NSComparisonResult)im_compare:(id)otherObject
{
  if (![otherObject isKindOfClass:[NSString class]]) {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:kMismatchedComparisonTypes userInfo:nil];
  }
  return [self compare:otherObject];
}

@end