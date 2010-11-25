//
//  ILPopCoreography.m
//  ViewControllers
//
//  Created by ∞ on 25/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILGrowFromPointCoreography.h"

@interface ILGrowFromPointCoreography ()

@property(readonly) CGPoint actualGrowCenter;

@end


@implementation ILGrowFromPointCoreography

- (void) dealloc
{
	self.growCenter = nil;
	[super dealloc];
}


@synthesize finalCenter, growCenter;

- (CGPoint) actualGrowCenter;
{
	return self.growCenter? [self.growCenter CGPointValue] : self.finalCenter;
}


- (void) prepareForAnimation;
{
	UIView* v = self.view;
	NSAssert(v, @"You must set only one view.");
	
	v.center = self.actualGrowCenter;
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
	
	v.center = self.actualGrowCenter;
	v.transform = CGAffineTransformMakeScale(0.1, 0.1);
	v.alpha = 0.0;
}

@end
