//
//  ILCoreography.h
//  ViewControllers
//
//  Created by ∞ on 25/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ILCoreography : NSObject {

}

@property(copy) NSArray* views;
@property(retain) UIView* view;

- (void) prepareForAnimation;
- (void) animate;

+ coreographyForView:(UIView*) v;

@end
