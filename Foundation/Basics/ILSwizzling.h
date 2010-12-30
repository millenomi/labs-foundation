//
//  ILSwizzling.h
//  Basics
//
//  Created by ∞ on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ILSwizzling)

+ (void) exchangeImplementationForSelector:(SEL) method withImplementationForSelector:(SEL) swizzle;

@end
