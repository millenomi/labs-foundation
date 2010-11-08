//
//  ILFauxActionSheetWindow.h
//  ViewControllers
//
//  Created by ∞ on 07/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ILFauxActionSheetDelegate;

@interface ILFauxActionSheetWindow : UIWindow

- (id) initWithContentView:(UIView*) view;

- (void) showAnimated:(BOOL) ani;
- (void) dismissAnimated:(BOOL) ani;

@property(assign) id <ILFauxActionSheetDelegate> fauxActionSheetDelegate;

@end


@protocol ILFauxActionSheetDelegate <NSObject>

@optional
- (void) fauxActionSheetWindow:(ILFauxActionSheetWindow*) window willAppearWithAnimationDuration:(CGFloat) duration curve:(UIViewAnimationCurve) curve finalContentViewFrame:(CGRect) frame;

- (void) fauxActionSheetWindowWillDismiss:(ILFauxActionSheetWindow*) window;
- (void) fauxActionSheetWindowDidDismiss:(ILFauxActionSheetWindow*) window;

@end