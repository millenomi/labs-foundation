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

@interface ILCoverWindow () <ILCoverWindowDelegate>

- (ILReversibleChoreography*) choreography;
@property(retain) ILReversibleChoreography* currentChoreography;

@property(readonly) CGRect frameForContentView;

- (void) prepare;

@property(nonatomic, copy) NSString* nibName;
@property(nonatomic, retain) NSBundle* bundle;

@end


CF_INLINE void ILCoverWindowGetBoundsAndTransformForOrientation(UIInterfaceOrientation o, CGRect* bounds, CGAffineTransform* transform) {
	
	if (bounds) {
		
		CGRect screenFrame = [[UIScreen mainScreen] bounds];
		
		if (UIInterfaceOrientationIsLandscape(o))
			screenFrame.size = CGSizeMake(screenFrame.size.height, screenFrame.size.width);
		
		*bounds = screenFrame;
		
	}
	
	if (transform) {
		
		switch (o) {
			case UIInterfaceOrientationLandscapeLeft:
				*transform = CGAffineTransformMakeRotation(-M_PI_2);
				break;
			
			case UIInterfaceOrientationLandscapeRight:
				*transform = CGAffineTransformMakeRotation(M_PI_2);
				break;
			
			case UIInterfaceOrientationPortraitUpsideDown:
				*transform = CGAffineTransformMakeRotation(M_PI);	
				break;
				
			case UIInterfaceOrientationPortrait:
			default:
				*transform = CGAffineTransformIdentity;
				break;
		}
		
	}
	
}

@implementation ILCoverWindow

- (id) init;
{
	return [self initWithNibName:nil bundle:nil];
}

- (id) initWithContentView:(UIView*) view;
{
	if ((self = [super init])) {		
		[self prepare];
		self.contentView = view;
	}
	
	return self;
}

- (id) initWithNibName:(NSString*) nibName bundle:(NSBundle*) bundle;
{
	if ((self = [super init])) {
		
		if (!bundle)
			bundle = [NSBundle bundleForClass:[self class]];
		if (!nibName)
			nibName = NSStringFromClass([self class]);
 		
		self.nibName = nibName;
		self.bundle = bundle;
		
		[self prepare];
	}
	
	return self;
}

- (void) prepare;
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	
	self.opaque = NO;
	
	// above windows, below alerts.
	self.windowLevel = (UIWindowLevelNormal + UIWindowLevelAlert) / 2;
	
	self.backgroundColor = [UIColor clearColor];
	
	if ([self respondsToSelector:@selector(screen)])
	self.screen = [UIScreen mainScreen];
	
	CGRect frame; CGAffineTransform transform;
	ILCoverWindowGetBoundsAndTransformForOrientation(UIInterfaceOrientationPortrait, &frame, &transform);
	self.frame = frame;
	self.transform = transform;
	
	self.coverDelegate = self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.contentView = nil;
    self.landscapeContentView = nil;
	if (self.coverDelegate == self && [self respondsToSelector:@selector(coverWindowDidUnloadContentView:)])
		[self.coverDelegate coverWindowDidUnloadContentView:self];
	
	self.nibName = nil;
	self.bundle = nil;
	self.currentChoreography = nil;
	[super dealloc];
}

@synthesize nibName, bundle;

@synthesize contentView, landscapeContentView;

- (UIView *) contentView;
{
	[self loadNIBIfNeeded];	
	return contentView;
}

- (void) setContentView:(UIView *) v;
{
	if (v != contentView) {
		[contentView removeFromSuperview];
		[contentView release];
		
		contentView = [v retain];
        
        if (contentView)
            [self addSubview:contentView];
		
		if (self.debugUseColoredBackgroundForContentView)
			contentView.backgroundColor = [UIColor redColor];		
	}
}

- (UIView *)landscapeContentView;
{
    [self loadNIBIfNeeded];
    return landscapeContentView;
}

- (void) setLandscapeContentView:(UIView *) v;
{
	if (v != landscapeContentView) {
		[landscapeContentView removeFromSuperview];
		[landscapeContentView release];
		
		landscapeContentView = [v retain];
        
        if (landscapeContentView)
            [self addSubview:landscapeContentView];
		
		if (self.debugUseColoredBackgroundForContentView)
			landscapeContentView.backgroundColor = [UIColor redColor];		
	}
}


@synthesize debugUseColoredBackgroundForContentView;
- (void) setDebugUseColoredBackgroundForContentView:(BOOL) b;
{
	if (debugUseColoredBackgroundForContentView != b) {
		debugUseColoredBackgroundForContentView = b;
		
		if (b) {
			self.contentView.backgroundColor = [UIColor redColor];
            self.landscapeContentView.backgroundColor = [UIColor redColor];
        }
	}
}

- (void) loadNIBIfNeeded;
{
	if (contentView)
		return;
	
	[self.bundle loadNibNamed:self.nibName owner:self options:nil];
	NSAssert(self.contentView, @"If you load a cover window's content view using a NIB, you must set the cover window's .coverView outlet!");

	if ([self.coverDelegate respondsToSelector:@selector(coverWindowDidLoadContentView:)])
		[self.coverDelegate coverWindowDidLoadContentView:self];
}

- (void) didReceiveMemoryWarning:(NSNotification*) n;
{
	if (self.hidden && self.nibName) {
		self.contentView = nil;
        self.landscapeContentView = nil;
        
		if ([self.coverDelegate respondsToSelector:@selector(coverWindowDidUnloadContentView:)])
			[self.coverDelegate coverWindowDidUnloadContentView:self];
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
	
    if (self.landscapeContentView)
        c.view = (UIInterfaceOrientationIsLandscape(self.orientation)? self.landscapeContentView : self.contentView);
    else
        c.view = self.contentView;
    
	return c;
}

- (void) showAnimation:(NSString*) ani didFinish:(BOOL) finish context:(void*) context;
{
	if ([self.coverDelegate respondsToSelector:@selector(coverWindow:didAppearWithFinalContentViewFrame:)]) {
		CGRect r = self.contentView.frame;
		[self.coverDelegate coverWindow:self didAppearWithFinalContentViewFrame:UIEdgeInsetsInsetRect(r, self.contentViewInsets)];
	}
}	

- (void) showAnimated:(BOOL) ani;
{
	if (self.rotateWithStatusBarOrientation)
		self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (self.landscapeContentView) {
        self.contentView.hidden = UIInterfaceOrientationIsLandscape(self.orientation);
        self.landscapeContentView.hidden = UIInterfaceOrientationIsPortrait(self.orientation);
    } else
        self.contentView.hidden = NO;
	
	if (ani) {
		
		self.currentChoreography = [self choreography];
		[self.currentChoreography prepareForAnimation];

		if ([self.coverDelegate respondsToSelector:@selector(coverWindow:willAppearWithAnimationDuration:curve:finalContentViewFrame:)]) {
			
			[self.coverDelegate coverWindow:self willAppearWithAnimationDuration:0.28 curve:UIViewAnimationCurveEaseInOut finalContentViewFrame:UIEdgeInsetsInsetRect(self.frameForContentView, self.contentViewInsets)];
			
		}
				
		[self makeKeyAndVisible];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.28];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
		[self.currentChoreography animate];

		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(showAnimation:didFinish:context:)];
		
		[UIView commitAnimations];
		
		
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

- (void) dismissAnimation:(NSString*) ani didFinish:(BOOL) finished context:(void*) context;
{
	self.hidden = YES;
	if ([self.coverDelegate respondsToSelector:@selector(coverWindowDidDismiss:)])
		[self.coverDelegate coverWindowDidDismiss:self];
	
	self.currentChoreography = nil;
}

- (void) dismissAnimated:(BOOL) ani;
{
	if ([self.coverDelegate respondsToSelector:@selector(coverWindowWillDismiss:)])
		[self.coverDelegate coverWindowWillDismiss:self];
	
	if (ani) {
		[self.currentChoreography prepareForReversing];

		[UIView beginAnimations:nil context:NULL];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(dismissAnimation:didFinish:context:)];

		[UIView setAnimationDuration:0.28];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
							 
		self.backgroundColor = [UIColor clearColor];
		[self.currentChoreography reverse];
		
		[UIView commitAnimations];
		
	} else {
		self.hidden = YES;
		[self.currentChoreography prepareForReversing];
		[self.currentChoreography reverse];
		self.currentChoreography = nil;
		
		if ([self.coverDelegate respondsToSelector:@selector(coverWindowDidDismiss:)])
			[self.coverDelegate coverWindowDidDismiss:self];
	}
}

- (IBAction) dismiss;
{
	[self dismissAnimated:YES];
}

#pragma mark Orientation

@synthesize rotateWithStatusBarOrientation;

@synthesize orientation;
- (void) setOrientation:(UIInterfaceOrientation) o;
{
	if (o != orientation) {
		orientation = o;
		
		CGRect f; CGAffineTransform t;
		ILCoverWindowGetBoundsAndTransformForOrientation(o, &f, &t);
		
		self.transform = CGAffineTransformIdentity;
		self.bounds = f;
		
		self.center = CGPointMake(CGRectGetMidX([self.screen bounds]), CGRectGetMidY([self.screen bounds]));
		self.transform = t;
	}
}

@end
