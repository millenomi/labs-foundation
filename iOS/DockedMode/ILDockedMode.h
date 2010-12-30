//
//  ILDockedMode.h
//  DockedMode
//
//  Created by ∞ on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/* A docked mode controller, implemented by the ILDockedMode class below, checks whether the device is in a "docked" ("photo frame") mode and warns its delegate accordingly.
 
 The device is considered to be in a "docked" mode whenever:
 * It's connected to a power outlet, and
 * It hasn't been used for some time.
 
 Currently the docked mode controller waits for 45 seconds without user events to enter docked mode. (This allows the app to always be able to enter docked mode even if the user chooses the lowest setting for the OS-wide idle timer, which is 60 seconds.)
 
 During docked mode, the application should change the UI so that it's visible from a distance and does not require user interaction. The application should provide its own controls to exit from docked mode.
 You can manually enter or exit docked mode by setting the .inDockedMode property to YES or NO respectively, which will cause the appropriate delegate methods to be called.
 Typically, the docked mode controller will disable the OS-wide idle timer while in docked mode (this can be controlled using the .disablesIdleTimerDuringDockedMode property).
 
 The controller will also warn the delegate a few seconds before entering docked mode automatically by sending a -dockedMode:willBeginAutomaticallyWithin: message. This is a good place to show or emphasize UI allowing the user to switch to docked mode automatically, or turn it off (which can help the user discover and control the feature).
 If the controller ever determines it will no longer begin automatically, it will send a -dockedModeWillNoLongerBeginAutomatically: message. This is a good place to include measures to hide the UI shown by …willBeginAutomatically above.
 
 Note that if you design your app as above, dockedModeWillNoLongerBeginAutomatically: will be called in response to user events that include manipulating the UI brought forth by …willBeginAutomatically. Consider hiding the UI only after a timeout, to allow the user to make a choice. 
 
*/

@protocol ILDockedModeDelegate;

typedef void (^ILDockedModeShouldBeginResponse)(BOOL shouldBegin);

@interface ILDockedMode : NSObject {}

@property(nonatomic, assign) id <ILDockedModeDelegate> delegate;

// If YES, the OS-wide idle timer controlled by UIApplication will be disabled when entering docked mode, and re-enabled on exit. Set to NO if you don't want this (eg. you want to control the idle timer yourself).
// Defaults to YES.
@property(nonatomic) BOOL disablesIdleTimerDuringDockedMode;

// If set to YES, the controller will monitor conditions to automatically enter docked mode. Defaults to NO.
@property(nonatomic, getter=isMonitoringForDockedMode) BOOL monitoringForDockedMode;

// YES while the app is in docked mode, NO otherwise. You can enter or exit docked mode programmatically by changing this property.
@property(nonatomic, getter=isInDockedMode) BOOL inDockedMode;

@end


@protocol ILDockedModeDelegate <NSObject>

// Sent when docked mode begins. The app should change its UI to match.
// Unlike many Cocoa delegate methods, this is also invoked when docked mode begins programmatically (by setting .inDockedMode to YES).
- (void) dockedModeDidBegin:(ILDockedMode*) dm;

// Sent when docked mode ends. The app should return its UI to normal.
// Unlike many Cocoa delegate methods, this is also invoked when docked mode ends programmatically (by setting .inDockedMode to NO).
- (void) dockedModeDidEnd:(ILDockedMode*) dm;

// Sent when docked mode is about to begin automatically. It will start in around 'to' seconds if nothing happens.
// In response to this method, you should show a UI to either enter docked mode manually (by setting .inDockedMode to YES), or disable monitoring (by setting .monitoringForDockedMode) to NO.
// This method is either followed by a call to -dockedModeDidBegin:, or one to -dockedModeWillNoLongerBeginAutomatically:.
- (void) dockedMode:(ILDockedMode*) dm willBeginAutomaticallyWithin:(NSTimeInterval) to;

// Sent when an event or setting change will prevent automatically entering docked mode. This is only sent after a corresponding dockedMode:willBeginAutomaticallyWithin: call.
// Note that this is also sent if the user produces an event that will cause the docked mode to not occur (eg. the user begins using the app again). This may include operating the UI mentioned in the dockedMode:willBeginAutomaticallyWithin: comment; take this into account.
- (void) dockedModeWillNoLongerBeginAutomatically:(ILDockedMode*) dm;

@end
