//
//  ILReversibleCoreography.m
//  ViewControllers
//
//  Created by ∞ on 25/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILReversibleCoreography.h"
#define ILAssertImplemented() [NSException raise:@"ILCoreographyUnimplementedException" format:@"Class %@ does not implement abstract method %s.", [self class], __func__]


@implementation ILReversibleCoreography

- (void) prepareForReversing;
{}

- (void) reverse;
{
	ILAssertImplemented();
}

@end
