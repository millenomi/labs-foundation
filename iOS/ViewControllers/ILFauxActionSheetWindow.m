//
//  ILFauxActionSheetWindow.m
//  ViewControllers
//
//  Created by ∞ on 07/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILFauxActionSheetWindow.h"

@interface ILFauxActionSheetWindow ()

@property(retain) UIView* contentView;

@property(readonly) CGRect frameForContentView;
@property(readonly) CGRect entranceAnimationFrameForContentView;
@property(readonly) CGRect exitAnimationFrameForContentView;

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
		view.frame = self.frameForContentView;
		[self addSubview:view];
	}
	
	return self;
}

- (void) dealloc
{
	self.contentView = nil;
	[super dealloc];
}

@synthesize fauxActionSheetDelegate;
@synthesize contentView;

- (CGRect) frameForContentView;
{	
	CGRect bounds = self.bounds;
	CGRect viewFrame = self.contentView.frame;
	
	viewFrame.origin.x = 0;
	viewFrame.origin.y = bounds.size.height - viewFrame.size.height;
	
	return viewFrame;
}

- (CGRect) entranceAnimationFrameForContentView;
{
	CGRect bounds = self.bounds;
	CGRect viewFrame = self.contentView.frame;
	
	viewFrame.origin.x = 0;
	viewFrame.origin.y = bounds.size.height;
	
	return viewFrame;
}

- (CGRect) exitAnimationFrameForContentView;
{
	return self.entranceAnimationFrameForContentView;
}

- (void) showAnimated:(BOOL) ani;
{
	if (ani) {
		
		self.contentView.frame = self.entranceAnimationFrameForContentView;
		
		[self makeKeyAndVisible];
		
		[UIView animateWithDuration:0.28 delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 
							 self.contentView.frame = self.frameForContentView;
							 self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
							 
						 }
						 completion:NULL];
		
		
	} else {
		
		self.contentView.frame = self.frameForContentView;
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
		[self makeKeyAndVisible];
		
	}
}

- (void) dismissAnimated:(BOOL) ani;
{
	if (ani) {
		[UIView animateWithDuration:0.28 delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 
							 self.contentView.frame = self.exitAnimationFrameForContentView;
							 self.backgroundColor = [UIColor clearColor];
							 
						 }
						 completion:^(BOOL done) {
							 
							 self.hidden = YES;
							 if ([self.fauxActionSheetDelegate respondsToSelector:@selector(fauxActionSheetWindowDidDismiss:)])
								 [self.fauxActionSheetDelegate fauxActionSheetWindowDidDismiss:self];
							 
						 }];
		
	} else {
		self.hidden = YES;
		if ([self.fauxActionSheetDelegate respondsToSelector:@selector(fauxActionSheetWindowDidDismiss:)])
			[self.fauxActionSheetDelegate fauxActionSheetWindowDidDismiss:self];
	}
}

@end
