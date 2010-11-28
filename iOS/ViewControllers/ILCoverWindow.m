//
//  ILFauxActionSheetWindow.m
//  ViewControllers
//
//  Created by ∞ on 07/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILCoverWindow.h"
#import "ILReversibleChoreography.h"
#import "ILSlideFromBottomChoreography.h"

@interface ILCoverWindow ()

- (ILReversibleChoreography*) choreography;
@property(retain) ILReversibleChoreography* currentChoreography;

@property(readonly) CGRect frameForContentView;

- (void) prepare;

@end


@implementation ILCoverWindow

- (id) initWithContentView:(UIView*) view;
{
	if ((self = [self init])) {		
		[self prepare];
		self.contentView = view;
	}
	
	return self;
}

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle;
{
	if ((self = [self init])) {
		if (!bundle)
			bundle = [NSBundle bundleForClass:[self class]];
		
		[bundle loadNibNamed:nibName owner:self options:nil];
		NSAssert(self.contentView, @"If you load a cover window's content view using a NIB, you must set the cover window's .coverView outlet!");
		[self prepare];
	}
	
	return self;
}

- (void) prepare;
{
	self.opaque = NO;
	
	// above windows, below alerts.
	self.windowLevel = (UIWindowLevelNormal + UIWindowLevelAlert) / 2;
	
	self.backgroundColor = [UIColor clearColor];
	
	self.screen = [UIScreen mainScreen];
	self.frame = [[UIScreen mainScreen] bounds];
}

- (void) dealloc
{
	self.contentView = nil;
	self.currentChoreography = nil;
	[super dealloc];
}


@synthesize contentView;
- (void) setContentView:(UIView *) v;
{
	if (v != contentView) {
		[contentView removeFromSuperview];
		[contentView release];
		
		contentView = [v retain];
		[self addSubview:contentView];
	}
}

@synthesize coverDelegate;
@synthesize currentChoreography;
@synthesize contentViewInsets;

- (CGRect) frameForContentView;
{	
	if (!self.currentChoreography)
		return CGRectNull;
	else
		return self.currentChoreography.finalFrame;
}

- (ILReversibleChoreography*) choreography;
{
	ILReversibleChoreography* c = nil;
	if ([self.coverDelegate respondsToSelector:@selector(choreographyForContentViewOfCoverWindow:)])
		c = [self.coverDelegate choreographyForContentViewOfCoverWindow:self];
	
	if (!c)
		c = [[ILSlideFromBottomChoreography new] autorelease];
	
	c.view = self.contentView;
	return c;
}

- (void) showAnimated:(BOOL) ani;
{
	if (ani) {
		
		self.currentChoreography = [self choreography];
		[self.currentChoreography prepareForAnimation];

		if ([self.coverDelegate respondsToSelector:@selector(coverWindow:willAppearWithAnimationDuration:curve:finalContentViewFrame:)]) {
			
			[self.coverDelegate coverWindow:self willAppearWithAnimationDuration:0.28 curve:UIViewAnimationCurveEaseInOut finalContentViewFrame:UIEdgeInsetsInsetRect(self.frameForContentView, self.contentViewInsets)];
			
		}
				
		[self makeKeyAndVisible];
		
		[UIView animateWithDuration:0.28 delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 
							 self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
							 [self.currentChoreography animate];
							 
						 }
						 completion:^(BOOL done) {
							 
							 if ([self.coverDelegate respondsToSelector:@selector(coverWindow:didAppearWithFinalContentViewFrame:)]) {
								 CGRect r = self.contentView.frame;
								 [self.coverDelegate coverWindow:self didAppearWithFinalContentViewFrame:UIEdgeInsetsInsetRect(r, self.contentViewInsets)];
							 }
							 
						 }];
		
		
	} else {
		
		if ([self.coverDelegate respondsToSelector:@selector(coverWindow:willAppearWithAnimationDuration:curve:finalContentViewFrame:)]) {
			
			[self.coverDelegate coverWindow:self willAppearWithAnimationDuration:0 curve:UIViewAnimationCurveLinear finalContentViewFrame:UIEdgeInsetsInsetRect(self.frameForContentView, self.contentViewInsets)];
			
		}
		
		// self.contentView.frame = self.frameForContentView;
		self.currentChoreography = [self choreography];
		[self.currentChoreography prepareForAnimation];
		[self.currentChoreography animate];
		
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
		[self makeKeyAndVisible];
		
		if ([self.coverDelegate respondsToSelector:@selector(coverWindow:didAppearWithFinalContentViewFrame:)]) {
			CGRect r = self.contentView.frame;
			[self.coverDelegate coverWindow:self didAppearWithFinalContentViewFrame:UIEdgeInsetsInsetRect(r, self.contentViewInsets)];
		}
	}
}

- (void) dismissAnimated:(BOOL) ani;
{
	if ([self.coverDelegate respondsToSelector:@selector(coverWindowWillDismiss:)])
		[self.coverDelegate coverWindowWillDismiss:self];
	
	if (ani) {
		[self.currentChoreography prepareForReversing];
		
		[UIView animateWithDuration:0.28 delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 
							 self.backgroundColor = [UIColor clearColor];
							 [self.currentChoreography reverse];
							 
						 }
						 completion:^(BOOL done) {
							 
							 self.hidden = YES;
							 if ([self.coverDelegate respondsToSelector:@selector(coverWindowDidDismiss:)])
								 [self.coverDelegate coverWindowDidDismiss:self];
							 
							 self.currentChoreography = nil;
							 
						 }];
		
	} else {
		self.hidden = YES;
		[self.currentChoreography prepareForReversing];
		[self.currentChoreography reverse];
		self.currentChoreography = nil;
		
		if ([self.coverDelegate respondsToSelector:@selector(coverWindowDidDismiss:)])
			[self.coverDelegate coverWindowDidDismiss:self];
	}
}

@end
