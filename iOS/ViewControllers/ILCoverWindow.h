//
//  ILFauxActionSheetWindow.h
//  ViewControllers
//
//  Created by ∞ on 07/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ILReversibleChoreography;

@protocol ILCoverWindowDelegate;


@interface ILCoverWindow : UIWindow

- (id) init;
- (id) initWithNibName:(NSString*) nibName bundle:(NSBundle*) bundle;
- (id) initWithContentView:(UIView*) view;

- (void) showAnimated:(BOOL) ani;
- (void) dismissAnimated:(BOOL) ani;

@property(assign, nonatomic) id <ILCoverWindowDelegate> coverDelegate;

@property UIEdgeInsets contentViewInsets;

@property(retain, nonatomic) IBOutlet UIView* contentView;

- (IBAction) dismiss; // dismissAnimated:YES

- (void) loadNIBIfNeeded;

@property(nonatomic) BOOL rotateWithStatusBarOrientation;
@property(nonatomic) UIInterfaceOrientation orientation;

@property(nonatomic) BOOL debugUseColoredBackgroundForContentView; // for debugging

@end


@protocol ILCoverWindowDelegate <NSObject>

@optional
- (void) coverWindow:(ILCoverWindow*) window willAppearWithAnimationDuration:(CGFloat) duration curve:(UIViewAnimationCurve) curve finalContentViewFrame:(CGRect) frame;
- (void) coverWindow:(ILCoverWindow*) window didAppearWithFinalContentViewFrame:(CGRect) frame;

- (void) coverWindowWillDismiss:(ILCoverWindow*) window;
- (void) coverWindowDidDismiss:(ILCoverWindow*) window;

- (void) coverWindowDidLoadContentView:(ILCoverWindow*) window;
- (void) coverWindowDidUnloadContentView:(ILCoverWindow*) window;

- (ILReversibleChoreography*) choreographyForContentViewOfCoverWindow:(ILCoverWindow*) window;

@end