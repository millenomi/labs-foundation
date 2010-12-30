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

