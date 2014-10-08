//
//  IMBase.h
//  pobjc
//
//  Created by Brian Dewey on 6/23/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IMComparable.h"

@interface NSNumber (IMComparable) <IMComparable>

@end

@interface NSString (IMComparable) <IMComparable>

@end

extern NSString * const kSubclassMustOverride;
extern NSString * const kNotImplemented;
extern NSString * const kMismatchedComparisonTypes;

#define IM_SUBCLASS_MUST_OVERRIDE() do { @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:kSubclassMustOverride userInfo:nil]; } while (0)
#define IM_NOT_IMPLEMENTED() do { @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:kNotImplemented userInfo:nil]; } while (0)

