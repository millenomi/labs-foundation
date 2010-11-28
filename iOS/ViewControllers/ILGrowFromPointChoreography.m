//
//  ILPopCoreography.m
//  ViewControllers
//
//  Created by ∞ on 25/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILGrowFromPointChoreography.h"

@interface ILGrowFromPointChoreography ()

@end


@implementation ILGrowFromPointChoreography

- (void) dealloc
{
	self.growCenterValue = nil;
	[super dealloc];
}


@synthesize finalCenter, growCenterValue;

- (CGPoint) growCenter;
{
	return self.growCenterValue? [self.growCenterValue CGPointValue] : self.finalCenter;
}

- (void) setGrowCenter:(CGPoint) c;
{
	self.growCenterValue = [NSValue valueWithCGPoint:c];
}

- (void) prepareForAnimation;
{
	UIView* v = self.view;
	NSAssert(v, @"You must set only one view.");
	
	v.center = self.growCenter;
	v.transform = CGAffineTransformMakeScale(0.1, 0.1);
	v.alpha = 0.0;
}

- (void) animate;
{
	UIView* v = self.view;
	NSAssert(v, @"You must set only one view.");
	
	v.center = self.finalCenter;
	v.transform = CGAffineTransformIdentity;
	v.alpha = 1.0;
}

- (void) reverse;
{
	UIView* v = self.view;
	NSAssert(v, @"You must set only one view.");
	
	v.center = self.growCenter;
	v.transform = CGAffineTransformMakeScale(0.1, 0.1);
	v.alpha = 0.0;
}

@end
