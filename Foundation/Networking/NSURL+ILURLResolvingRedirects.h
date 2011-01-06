//
//  NSURL+ILURLResolvingRedirects.h
//  MuiKit
//
//  Created by ∞ on 17/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __BLOCKS__
typedef void (^ILURLResolvingDidEndBlock)(NSURL*);
#endif

@interface NSURL (ILURLResolvingRedirects)

- (void) beginResolvingRedirectsWithDelegate:(id) delegate selector:(SEL) selector;

#if __BLOCKS__
- (void) beginResolvingRedirectsAndInvoke:(ILURLResolvingDidEndBlock) block;
#endif

@end
