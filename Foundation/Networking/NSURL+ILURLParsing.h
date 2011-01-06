//
//  NSURL_ILURLParsing.h
//  Diceshaker
//
//  Created by ∞ on 11/02/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURL (ILURLParsing)

- (NSDictionary*) dictionaryByDecodingQueryString;

@end

@interface NSDictionary (ILURLParsing)

- (NSString*) queryString;

@end
