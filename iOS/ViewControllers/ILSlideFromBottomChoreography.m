//
//  ILEnterCoreography.m
//  ViewControllers
//
//  Created by ∞ on 25/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILSlideFromBottomChoreography.h"

@interface ILSlideFromBottomChoreography ()

@property(readonly) CGRect frameForView;
@property(readonly) CGRect entranceAnimationFrameForView;
@property(readonly) CGRect exitAnimationFrameForView;

@end



@implementation ILSlideFromBottomChoreography

- (void) dealloc
{
	self.slideContainerView = nil;
	[super dealloc];
}



@synthesize slideContainerView;

- (CGRect) finalFrameForViewWithRole:(NSString *)role;
{
	if ([role isEqual:kILChoreographyDefaultViewRole])
		return self.frameForView;
	else
		return CGRectNull;
}

- (CGRect) frameForView;
{	
	UIView* v = self.view;
	NSAssert(v, @"Set exactly one view to use a slide coreography.");
	
	UIView* container = self.slideContainerView ?: v.superview;
	NSAssert(container, @"The view must be in a superview to slide.");

	CGRect bounds = container.bounds;
	CGRect viewFrame = v.frame;
	
	viewFrame.origin.x = 0;
	viewFrame.origin.y = bounds.size.height - viewFrame.size.height;
	
	return viewFrame;
}

- (CGRect) entranceAnimationFrameForView;
{
	UIView* v = self.view;
	NSAssert(v, @"Set exactly one view to use a slide coreography.");
	
	UIView* container = self.slideContainerView ?: v.superview;
	NSAssert(container, @"The view must be in a superview to slide.");

	CGRect bounds = container.bounds;
	CGRect viewFrame = v.frame;
	
	viewFrame.origin.x = 0;
	viewFrame.origin.y = bounds.size.height;
	
	return viewFrame;
}

- (CGRect) exitAnimationFrameForView;
{
	return self.entranceAnimationFrameForView;
}


- (void) prepareForAnimation;
{
	self.view.frame = self.entranceAnimationFrameForView;
}

- (void) animate;
{			 
	 self.view.frame = self.frameForView;
}

- (void) prepareForReversing;
{
	self.view.frame = self.frameForView;
}

- (void) reverse;
{
	 self.view.frame = self.exitAnimationFrameForView;
}

@end
