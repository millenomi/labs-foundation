//
//  ILViewController.h
//  ILViewController
//
//  Created by ∞ on 07/04/10.
//

// The contents of this file are in the public domain.

#import <UIKit/UIKit.h>

enum {
	kILRotateIdiomDefault = 0, // setting to this will really pick the 'default' one below.
	
	kILRotatePortrait, // portrait. on iPhone, straight up only. on iPad, both portrait orientations.
		// default on iPhone.
	
	kILRotateLandscape, // both landscape orientations
	kILRotateAny, // on iPhone, any except upside down. on iPad, any orientation.
		// default on iPad.
};
typedef NSInteger ILRotationStyle;

@interface ILViewController : UIViewController {
	ILRotationStyle rotationStyle;
	
	BOOL changesNavigationBarStyle;
	UIBarStyle navigationBarStyle;
	UIColor* navigationBarTintColor;
	BOOL navigationBarTranslucent;
	
	BOOL changesStatusBarStyle;
	UIStatusBarStyle statusBarStyle;

	BOOL restoresNavigationBarStyleOnDisappearing, hasOlderNavigationBarStyle;
	UIBarStyle oldNavigationBarStyle;
	UIColor* oldNavigationBarTintColor;
	BOOL oldNavigationBarTranslucent;
	
	BOOL restoresStatusBarStyleOnDisappearing, hasOlderStatusBarStyle;
	UIStatusBarStyle oldStatusBarStyle;
	
	BOOL isHoldingRestoresForNavBarPush;
	
	NSMutableSet* managedOutlets;
}

@property ILRotationStyle rotationStyle;

@property BOOL changesNavigationBarStyle;
@property UIBarStyle navigationBarStyle;
@property(retain) UIColor* navigationBarTintColor;
@property BOOL navigationBarTranslucent;

@property BOOL restoresNavigationBarStyleOnDisappearing;

@property BOOL changesStatusBarStyle;
@property UIStatusBarStyle statusBarStyle;

@property BOOL restoresStatusBarStyleOnDisappearing;

// quickly sets up style changes that go together with the given bar style.
// it sets up the VC to restore older styles on disappearing, sets the navigation bar style/translucency/tint to match the constant passed, and if translucent also sets the VC to go fullscreen.
- (void) setChangesBarStyle:(UIStatusBarStyle) style;


// Returns the bundle instances of this class should search NIBs in. Default impl returns the bundle for this class.
+ (NSBundle*) nibBundle;

// convenience initializer; will call initWithNibName:bundle: with a nib name equal to the class name and the nib bundle returned by the class's +nibBundle method (the main bundle for the default implementation of that method).
- (id) init;

// creates a view controller hierarchy that can be presented modally. the returned view controller is not an instance of this class, but a wrapper that can be presented modally.
// the variable whose pointer is passed as argument, if that pointer is not NULL, will on return be set to the instance of this class that's contained in the view controller hierarchy just returned (autoreleased as per THE RULES).
// the default implementation creates a UINavigationController wrapping a new instance of the receiver class (produced via -init).
+ (UIViewController*) modalPaneForViewController:(id*) vc;

#if 30200 <= __IPHONE_OS_VERSION_MAX_ALLOWED
// same as +modalPaneForViewController:, except it returns a popover controller containing a view controller hierarchy rather than a modally presentable vc hierarchy.
// the default implementation returns the view controller hierarchy returned by modalPaneForViewController:, wrapped in a popover controller.
// on platforms where popover controllers are not supported, this returns nil.
+ (UIPopoverController*) popoverControllerForViewController:(id*) vc;
#endif

// dismisses this view controller from being modally presented, with animation. useful for UIBarButtonItems.
- (IBAction) dismiss;


// pushes a view controller on the navigation controller this view controller is contained in, if any.
// This method will examine the view controller argument to determine if it's a ILViewController and whether it's going to change the status bar style. It will coordinate with it so as not to produce incorrect animations.
- (void) pushViewController:(UIViewController*) vc animated:(BOOL) ani;

// same. calls above with animated:YES.
- (void) pushViewController:(UIViewController*) vc;


// Called at -dealloc and -viewDidUnload times to clear outlets. The default impl calls setValue:nil forKey:k for each k in the managed outlets sets (see below).
- (void) clearOutlets;

// Adds an outlet to the managed outlets set. These will be cleared by the default implementation of -clearOutlets, called at every view unload and at dealloc.
- (void) addManagedOutletKey:(NSString*) key;

// Convenience for adding many keys at once. End the list with nil.
- (void) addManagedOutletKeys:(NSString *)key, ... __attribute__((sentinel));

@end
