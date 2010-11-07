//
//  NSData+ILIPAddressTools.h
//  MuiKit
//
//  Created by ∞ on 19/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	kILIPAddressVersion4,
	kILIPAddressVersion6,
};
typedef NSInteger ILIPAddressVersion;

@interface NSData (ILIPAddressTools)

- (BOOL) socketAddressIsIPAddressOfVersion:(ILIPAddressVersion) v;
- (BOOL) socketAddressIsEqualToAddress:(NSData*) d;
- (NSString*) socketAddressStringValue;

@end
