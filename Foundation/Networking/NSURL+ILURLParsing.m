//
//  NSURL_ILURLParsing.m
//  Diceshaker
//
//  Created by ∞ on 11/02/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSURL+ILURLParsing.h"


@implementation NSURL (ILURLParsing)

- (NSDictionary*) dictionaryByDecodingQueryString;
{
	NSString* query = [self query];
	if (!query) {
		NSString* resSpecifier = [self resourceSpecifier];
		NSRange r = [resSpecifier rangeOfString:@"?"];
		
		if (r.location == NSNotFound || r.location == [resSpecifier length] - 1)
			return [NSDictionary dictionary];
		else
			query = [resSpecifier substringFromIndex:r.location + 1];
	}
	
	return [query dictionaryByDecodingQueryString];
}

@end

@implementation NSString (ILURLParsing)

- (NSDictionary*) dictionaryByDecodingQueryString;
{
	NSArray* keyValuePairs = [self componentsSeparatedByString:@"&"];
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	for (NSString* pair in keyValuePairs) {
		NSArray* splitPair = [pair componentsSeparatedByString:@"="];
		NSAssert([splitPair count] > 0, @"At least one element out of componentsSeparatedByString:");
		NSString* key = [splitPair objectAtIndex:0];
		
		NSString* value;
		if ([splitPair count] > 2) {
			NSMutableArray* splitPairWithoutKey = [NSMutableArray arrayWithArray:splitPair];
			[splitPairWithoutKey removeObjectAtIndex:0];
			value = [splitPairWithoutKey componentsJoinedByString:@"="];
		} else if ([splitPair count] == 2)
			value = [splitPair objectAtIndex:1];
		else
			value = nil;
		
		if (value)
			[dict setObject:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		else
			[dict setObject:[NSNull null] forKey:[key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		
	}
	
	return dict;
}

@end

@implementation NSDictionary (ILURLParsing)

- (NSString*) queryString;
{
	NSMutableString* queryString = [NSMutableString string];
	
	BOOL first = YES;
	for (NSString* key in self) {
		if (!first)
			[queryString appendString:@"&"];
		
		NSString* toAppend = [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) key, NULL, (CFStringRef) @"+&=", kCFStringEncodingUTF8)) autorelease];
		toAppend = [toAppend stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
		[queryString appendString:toAppend];
		
		id value = [self objectForKey:key];
		if (![value isEqual:[NSNull null]]) {
			[queryString appendString:@"="];
			NSString* toAppend = [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) value, NULL, (CFStringRef) @"+&=", kCFStringEncodingUTF8)) autorelease];
			toAppend = [toAppend stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
			[queryString appendString:toAppend];
		}
		
		first = NO;
	}
	
	return queryString;
}

@end
