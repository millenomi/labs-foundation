//
//  ILFauxActionSheetWindow.m
//  ViewControllers
//
//  Created by ∞ on 07/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILFauxActionSheetWindow.h"
#import "ILReversibleChoreography.h"
#import "ILSlideFromBottomChoreography.h"

@interface ILFauxActionSheetWindow ()

@property(retain) UIView* contentView;

- (ILReversibleChoreography*) coreography;
@property(retain) ILReversibleChoreography* currentCoreography;

@end


@implementation ILFauxActionSheetWindow

- (id) initWithContentView:(UIView*) view;
{
	if ((self = [super init])) {
		
		self.opaque = NO;
		
		// above windows, below alerts.
		self.windowLevel = (UIWindowLevelNormal + UIWindowLevelAlert) / 2;
		
		self.backgroundColor = [UIColor clearColor];
		
		self.screen = [UIScreen mainScreen];
		self.frame = [[UIScreen mainScreen] bounds];
		
		self.contentView = view;
		[self addSubview:view];
	}
	
	return self;
}

- (void) dealloc
{
	self.contentView = nil;
	self.currentCoreography = nil;
	[super dealloc];
}

@synthesize fauxActionSheetDelegate;
@synthesize contentView;
@synthesize currentCoreography;

- (CGRect) frameForContentView;
{	
	CGRect bounds = self.bounds;
	CGRect viewFrame = self.contentView.frame;
	
	viewFrame.origin.x = 0;
	viewFrame.origin.y = bounds.size.height - viewFrame.size.height;
	
	return viewFrame;
}

- (ILReversibleChoreography*) coreography;
{
	ILReversibleChoreography* c = nil;
	if ([self.fauxActionSheetDelegate respondsToSelector:@selector(coreographyForContentViewOfFauxActionSheetWindow:)])
		c = [self.fauxActionSheetDelegate coreographyForContentViewOfFauxActionSheetWindow:self];
	
	if (!c)
		c = [[ILSlideFromBottomChoreography new] autorelease];
	
	c.view = self.contentView;
	return c;
}

- (void) showAnimated:(BOOL) ani;
{
	if (ani) {
		
		if ([self.fauxActionSheetDelegate respondsToSelector:@selector(fauxActionSheetWindow:willAppearWithAnimationDuration:curve:finalContentViewFrame:)]) {
			
			[self.fauxActionSheetDelegate fauxActionSheetWindow:self willAppearWithAnimationDuration:0.28 curve:UIViewAnimationCurveEaseInOut finalContentViewFrame:self.frameForContentView];
			
		}
		
		self.currentCoreography = [self coreography];
		[self.currentCoreography prepareForAnimation];
		
		[self makeKeyAndVisible];
		
		[UIView animateWithDuration:0.28 delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 
							 self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
							 [self.currentCoreography animate];
							 
						 }
						 completion:^(BOOL done) {
							 
							 if ([self.fauxActionSheetDelegate respondsToSelector:@selector(fauxActionSheetWindow:didAppearWithFinalContentViewFrame:)])
								 [self.fauxActionSheetDelegate fauxActionSheetWindow:self didAppearWithFinalContentViewFrame:self.contentView.frame];
							 
						 }];
		
		
	} else {
		
		if ([self.fauxActionSheetDelegate respondsToSelector:@selector(fauxActionSheetWindow:willAppearWithAnimationDuration:curve:finalContentViewFrame:)]) {
			
			[self.fauxActionSheetDelegate fauxActionSheetWindow:self willAppearWithAnimationDuration:0 curve:UIViewAnimationCurveLinear finalContentViewFrame:self.frameForContentView];
			
		}
		
		self.contentView.frame = self.frameForContentView;
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
		[self makeKeyAndVisible];
		
		if ([self.fauxActionSheetDelegate respondsToSelector:@selector(fauxActionSheetWindow:didAppearWithFinalContentViewFrame:)])
			[self.fauxActionSheetDelegate fauxActionSheetWindow:self didAppearWithFinalContentViewFrame:self.contentView.frame];		
	}
}

- (void) dismissAnimated:(BOOL) ani;
{
	if ([self.fauxActionSheetDelegate respondsToSelector:@selector(fauxActionSheetWindowWillDismiss:)])
		[self.fauxActionSheetDelegate fauxActionSheetWindowWillDismiss:self];
	
	if (ani) {
		[self.currentCoreography prepareForReversing];
		
		[UIView animateWithDuration:0.28 delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 
							 self.backgroundColor = [UIColor clearColor];
							 [self.currentCoreography reverse];
							 
						 }
						 completion:^(BOOL done) {
							 
							 self.hidden = YES;
							 if ([self.fauxActionSheetDelegate respondsToSelector:@selector(fauxActionSheetWindowDidDismiss:)])
								 [self.fauxActionSheetDelegate fauxActionSheetWindowDidDismiss:self];
							 
							 self.currentCoreography = nil;
							 
						 }];
		
	} else {
		self.hidden = YES;
		if ([self.fauxActionSheetDelegate respondsToSelector:@selector(fauxActionSheetWindowDidDismiss:)])
			[self.fauxActionSheetDelegate fauxActionSheetWindowDidDismiss:self];
	}
}

@end
