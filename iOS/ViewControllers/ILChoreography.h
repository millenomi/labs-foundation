//
//  ILCoreography.h
//  ViewControllers
//
//  Created by ∞ on 25/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kILChoreographyDefaultViewRole @"ILChoreographyDefaultViewRole"

@interface ILChoreography : NSObject {
	NSMutableDictionary* mutableViews;
}

@property(copy) NSDictionary* views;

- (void) setView:(UIView *)v forRole:(NSString*) role;
- (UIView*) viewForRole:(NSString*) role;

- (CGRect) finalFrameForViewWithRole:(NSString*) role;

@property(retain) UIView* view;
@property(readonly) CGRect finalFrame;

- (void) prepareForAnimation;
- (void) animate;

+ choreographyForView:(UIView*) v;
+ choreography;

@end
