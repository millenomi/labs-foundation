//
//  ILCoreography.m
//  ViewControllers
//
//  Created by ∞ on 25/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILCoreography.h"
#define ILAssertImplemented() [NSException raise:@"ILCoreographyUnimplementedException" format:@"Class %@ does not implement abstract method %s.", [self class], __func__]

@implementation ILCoreography

- (void) dealloc
{
	self.views = nil;
	[super dealloc];
}



@synthesize views;

- (UIView *) view;
{
	return ([self.views count] == 1? [self.views objectAtIndex:0] : nil);
}

- (void) setView:(UIView *) v;
{
	self.views = [NSArray arrayWithObject:v];
}

- (void) animate;
{
	ILAssertImplemented();
}

- (void) prepareForAnimation;
{}

+ coreographyForView:(UIView*) v;
{
	ILCoreography* c = [[self new] autorelease];
	c.view = v;
	return c;
}

@end
