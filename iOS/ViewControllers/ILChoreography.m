//
//  ILCoreography.m
//  ViewControllers
//
//  Created by ∞ on 25/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILChoreography.h"
#define ILAssertImplemented() [NSException raise:@"ILCoreographyUnimplementedException" format:@"Class %@ does not implement abstract method %s.", [self class], __func__]

@implementation ILChoreography

- (id) init;
{
	if ((self = [super init]))
		mutableViews = [NSMutableDictionary new];
	
	return self;
}

- (void) dealloc
{
	[mutableViews release];
	[super dealloc];
}



- (NSDictionary *) views;
{
	return mutableViews;
}

- (void) setViews:(NSDictionary *) d;
{
	[mutableViews setDictionary:d];
}

- (void) setView:(UIView *)v forRole:(NSString*) role;
{
	if (v)
		[mutableViews setObject:v forKey:role];
	else
		[mutableViews removeObjectForKey:role];
}

- (UIView*) viewForRole:(NSString*) role;
{
	return [mutableViews objectForKey:role];
}

- (CGRect) finalFrameForViewWithRole:(NSString*) role;
{
	UIView* v = [self viewForRole:role];
	return v? v.frame : CGRectNull;
}

- (UIView *) view;
{
	return [self viewForRole:kILChoreographyDefaultViewRole];
}

- (void) setView:(UIView *) v;
{
	[self setView:v forRole:kILChoreographyDefaultViewRole];
}

- (CGRect) finalFrame;
{
	return [self finalFrameForViewWithRole:kILChoreographyDefaultViewRole];
}

- (void) animate;
{
	ILAssertImplemented();
}

- (void) prepareForAnimation;
{}

+ choreographyForView:(UIView*) v;
{
	ILChoreography* c = [self choreography];
	c.view = v;
	return c;
}

+ choreography;
{
	return [[self new] autorelease];
}

@end
