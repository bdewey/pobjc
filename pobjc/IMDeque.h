//
//  IMDeque.h
//  pobjc
//
//  Created by Brian Dewey on 6/22/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

@protocol IMDeque <NSObject>

@property (nonatomic, readonly, assign, getter = isEmpty) BOOL empty;
- (id)peekLeft;
- (id)peekRight;
- (id)enqueueLeft:(id)object;
- (id)enqueueRight:(id)object;
- (id)dequeueLeft;
- (id)dequeueRight;

@end