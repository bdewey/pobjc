//
//  IMFingerTree.h
//  pobjc
//
//  Created by Brian Dewey on 6/22/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMDeque.h"

@interface IMFingerTree : NSObject <IMDeque>

+ (IMFingerTree *)empty;

@end

