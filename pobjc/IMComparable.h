//
//  IMComparable.h
//  pobjc
//
//  Created by Brian Dewey on 7/6/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMComparable <NSObject>

- (NSComparisonResult)im_compare:(id)otherObject;

@end