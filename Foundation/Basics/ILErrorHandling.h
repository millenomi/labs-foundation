//
//  ILErrorHandling.h
//  Basics
//
//  Created by ∞ on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ILAssertNoNSError(whatever) \
	({ \
		NSError* ERROR; \
		typeof(whatever) RESULT = whatever; \
		if (!RESULT) { \
			NSLog(@"Assertion failed: %s returned a NSError:", #whatever); \
			NSAssert(NO, @"A NSError was returned when we asserted none should be."); \
		} \
		RESULT; \
	})

#define ILCAssertNoNSError(whatever) \
	({ \
		NSError* ERROR; \
		typeof(whatever) RESULT = whatever; \
		if (!RESULT) { \
			NSLog(@"Assertion failed: %s returned a NSError:", #whatever); \
			NSCAssert(NO, @"A NSError was returned when we asserted none should be."); \
		} \
		RESULT; \
	})

#define ILAbstractMethod() \
	[NSException raise:@"ILAbstractMethodCalledException" format:@"Method %s is abstract and was not overridden by class %@ (called on %@)", __func__, [self class], self]
