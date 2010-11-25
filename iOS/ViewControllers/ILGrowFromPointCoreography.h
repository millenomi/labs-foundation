//
//  ILPopCoreography.h
//  ViewControllers
//
//  Created by ∞ on 25/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILReversibleCoreography.h"

@interface ILGrowFromPointCoreography : ILReversibleCoreography {}

@property CGPoint finalCenter;

// if nil, uses the view's final center (as determined by finalCenter).
@property(copy) NSValue* growCenter;

@end
