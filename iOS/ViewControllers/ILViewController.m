//
//  ILViewController.m
//  ILViewController
//
//  Created by ∞ on 07/04/10.
//

// The contents of this file are in the public domain.

#import "ILViewController.h"

#if 30200 <= __IPHONE_OS_VERSION_MAX_ALLOWED
#define ILViewControllerIsOniPad() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define ILViewControllerIsOniPad() (NO)
#endif

@interface ILViewController ()

@property(retain) UIColor* oldNavigationBarTintColor;

@end


@implementation ILViewController

- (void) dealloc;
{
	[self clearOutlets];
	[managedOutlets release];
	
	[oldNavigationBarTintColor release];
	[navigationBarTintColor release];
	[super dealloc];
}

#pragma mark Navbar/status bar appearance

- (void) viewWillAppear:(BOOL)animated;
{
	[super viewWillAppear:animated];
	
	if (self.changesNavigationBarStyle && self.navigationController && !isHoldingRestoresForNavBarPush) {
		UINavigationBar* bar = self.navigationController.navigationBar;
		
		if (self.restoresStatusBarStyleOnDisappearing) {
			hasOlderNavigationBarStyle = YES;
			oldNavigationBarStyle = bar.barStyle;
			oldNavigationBarTranslucent = bar.translucent;
			self.oldNavigationBarTintColor = bar.tintColor;
		}
		
		bar.barStyle = self.navigationBarStyle;
		bar.translucent = self.navigationBarTranslucent;
		if (bar.barStyle == UIBarStyleDefault)
			bar.tintColor = self.navigationBarTintColor;
		
	}
	
	if (self.changesStatusBarStyle && !ILViewControllerIsOniPad() && !isHoldingRestoresForNavBarPush) {
		if (self.restoresStatusBarStyleOnDisappearing) {
			hasOlderStatusBarStyle = YES;
			oldNavigationBarStyle = [[UIApplication sharedApplication] statusBarStyle];
		}
		
		[[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle animated:animated];
	}	
}

- (void) viewDidAppear:(BOOL) animated;
{
	[super viewDidAppear:animated];
	isHoldingRestoresForNavBarPush = NO;
}

- (void) viewWillDisappear:(BOOL)animated;
{
	[super viewWillDisappear:animated];
	
	if (self.restoresNavigationBarStyleOnDisappearing && hasOlderNavigationBarStyle && !isHoldingRestoresForNavBarPush) {
		UINavigationBar* bar = self.navigationController.navigationBar;
		
		bar.barStyle = oldNavigationBarStyle;
		bar.translucent = oldNavigationBarTranslucent;
		bar.tintColor = oldNavigationBarTintColor;
		
		self.oldNavigationBarTintColor = nil;
		hasOlderNavigationBarStyle = NO;
	}
	
	if (self.restoresStatusBarStyleOnDisappearing && hasOlderStatusBarStyle && !ILViewControllerIsOniPad() && !isHoldingRestoresForNavBarPush) {
		[[UIApplication sharedApplication] setStatusBarStyle:oldStatusBarStyle animated:animated];
		hasOlderStatusBarStyle = NO;
	}
}

@synthesize restoresNavigationBarStyleOnDisappearing, oldNavigationBarTintColor;
@synthesize restoresStatusBarStyleOnDisappearing;

@synthesize changesNavigationBarStyle;
@synthesize navigationBarStyle;
@synthesize navigationBarTintColor;
@synthesize navigationBarTranslucent;

@synthesize changesStatusBarStyle;
@synthesize statusBarStyle;

- (void) setChangesBarStyle:(UIStatusBarStyle)style;
{
	self.changesStatusBarStyle = YES;
	self.changesNavigationBarStyle = YES;
	
	self.restoresNavigationBarStyleOnDisappearing = YES;
	self.restoresStatusBarStyleOnDisappearing = YES;
	self.statusBarStyle = style;
	self.navigationBarTintColor = nil;
	
	switch (style) {
		case UIStatusBarStyleDefault:
			self.navigationBarStyle = UIBarStyleDefault;
			self.navigationBarTranslucent = NO;
			break;
			
		case UIStatusBarStyleBlackOpaque:
			self.navigationBarStyle = UIBarStyleBlack;
			self.navigationBarTranslucent = NO;
			break;
			
		case UIStatusBarStyleBlackTranslucent:
			self.navigationBarStyle = UIBarStyleBlack;
			self.navigationBarTranslucent = YES;
			self.wantsFullScreenLayout = YES;
			break;
			
		default:
			break;
	}
}

#pragma mark Common initialization

+ (NSBundle*) nibBundle;
{
	return [NSBundle bundleForClass:self];
}

- (id) init;
{
	// we can't call -class on an object before we -init it, but we can access its isa pointer.
	return [self initWithNibName:NSStringFromClass(self->isa) bundle:[self->isa nibBundle]];
}

#pragma mark Modal presentation

+ (UIViewController*) modalPaneForViewController:(id*) vc;
{
	ILViewController* me = [[[self alloc] init] autorelease];
	UINavigationController* nc = [[[UINavigationController alloc] initWithRootViewController:me] autorelease];
	
	if (vc) *vc = me;
	return nc;
}

#if 30200 <= __IPHONE_OS_VERSION_MAX_ALLOWED

+ (UIPopoverController*) popoverControllerForViewController:(id*) vc;
{
	Class poc = NSClassFromString(@"UIPopoverController");
	if (!poc)
		return nil;
	
	UIPopoverController* pop = [[[poc alloc] initWithContentViewController:[self modalPaneForViewController:vc]] autorelease];
	return pop;
}

#endif // iPhone SDK 3.2+

- (IBAction) dismiss;
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Autorotation

@synthesize rotationStyle;
- (ILRotationStyle) rotationStyle;
{
	if (rotationStyle == kILRotateIdiomDefault)
		rotationStyle = ILViewControllerIsOniPad()? kILRotateAny : kILRotatePortrait;
	
	return rotationStyle;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) o;
{
	switch (self.rotationStyle) {
		case kILRotatePortrait:
			return ILViewControllerIsOniPad()? UIInterfaceOrientationIsPortrait(o) : o == UIInterfaceOrientationPortrait;

		case kILRotateLandscape:
			return UIInterfaceOrientationIsLandscape(o);
			
		case kILRotateAny:
			return ILViewControllerIsOniPad()? YES : o != UIInterfaceOrientationPortraitUpsideDown;
			
		default:
			return NO;
	}
}

#pragma mark Pushing

- (void) pushViewController:(UIViewController*) vc animated:(BOOL) ani;
{
	UINavigationController* nav = self.navigationController;
	NSAssert(nav, @"Must be contained in a navigation controller to use this method.");
	
	// If the new VC isn't a ILVC, we want to keep the current style -- not revert on disappear, even if we usually do.
	// If the new VC is a ILVC and changes the style, we want to revert it. If it doesn't, we want to keep it and not revert it.
	BOOL shouldKeepCurrentStyle = ![vc isKindOfClass:[ILViewController class]] || (![(ILViewController*)vc changesStatusBarStyle] && ![(ILViewController*)vc changesNavigationBarStyle]);
	
	isHoldingRestoresForNavBarPush = shouldKeepCurrentStyle;
	[nav pushViewController:vc animated:YES];
}

- (void) pushViewController:(UIViewController*) vc;
{
	[self pushViewController:vc animated:YES];
}

#pragma mark Automatic outlet management

- (void) clearOutlets;
{
	for (NSString* key in managedOutlets)
		[self setValue:nil forKey:key];
}

- (void) viewDidUnload;
{
	[super viewDidUnload];
	[self clearOutlets];
}

- (void) addManagedOutletKey:(NSString*) key;
{
	if (!managedOutlets)
		managedOutlets = [NSMutableSet new];
	
	[managedOutlets addObject:key];
}

- (void) addManagedOutletKeys:(NSString *)key, ...;
{
	[self addManagedOutletKey:key];
	
	va_list l;
	va_start(l, key);
	
	NSString* k = va_arg(l, NSString*);
	while (k) {
		[self addManagedOutletKey:k];
		k = va_arg(l, NSString*);
	}
	
	va_end(l);
}

@end
