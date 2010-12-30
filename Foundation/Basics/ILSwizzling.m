//
//  ILSwizzling.m
//  Basics
//
//  Created by ∞ on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILSwizzling.h"

#import <objc/runtime.h>

@implementation NSObject (ILSwizzling)

+ (void) exchangeImplementationForSelector:(SEL) method withImplementationForSelector:(SEL) swizzle;
{
	Method a = class_getInstanceMethod(self, method);
	Method b = class_getInstanceMethod(self, swizzle);
	
	method_exchangeImplementations(a, b);
}

@end
