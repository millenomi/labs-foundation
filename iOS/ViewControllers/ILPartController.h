//
//  ILPartController.h
//  ILViewController
//
//  Created by ∞ on 20/04/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// A part controller is just the same as a view controller, except it does not come with the contract baggage of UIViewController. In particular, it's meant to be used with views that do NOT cover the entire screen.
// Typically, you don't subclass this class directly. Instead, controller classes that use part controllers will define a subclass suited to their particular situation and you'll subclass that (or use a protocol, in which case you'll subclass ILPartController and add that protocol).

@interface ILPartController : NSObject {
	NSString* nibName;
	NSBundle* nibBundle;
	
	UIView* view;
	
	NSMutableSet* managedOutlets;
}

// Designated.
- (id) initWithNibName:(NSString*) name bundle:(NSBundle*) b;

+ (NSBundle*) nibBundle;
- (id) init;

@property(retain) IBOutlet UIView* view;
@property(readonly, getter=isViewLoaded) BOOL viewLoaded;
- (void) loadView;
- (void) viewDidLoad;

- (void) didReceiveMemoryWarning;
- (void) viewDidUnload;

- (void) clearOutlets;
- (void) addManagedOutletKey:(NSString*) key;
- (void) addManagedOutletKeys:(NSString *)key, ...;

@end
