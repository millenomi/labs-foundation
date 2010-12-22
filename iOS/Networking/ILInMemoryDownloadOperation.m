//
//  ILInMemoryDownloadOperation.m
//  Networking
//
//  Created by ∞ on 21/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILInMemoryDownloadOperation.h"

@interface ILInMemoryDownloadOperation ()

@end


@implementation ILInMemoryDownloadOperation

- (void) dealloc
{
	[mutableDownloadedData release];
	[super dealloc];
}


- (void) willBeginOperation;
{
	mutableDownloadedData = [NSMutableData new];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
	if (self.maximumResourceSize && [data length] + [mutableDownloadedData length] > self.maximumResourceSize) {
		[self endWithError:[NSError errorWithDomain:kILInMemoryDownloadOperationErrorDomain code:kILInMemoryDownloadOperationErrorResourceTooLarge userInfo:nil]];
	}
	
	[mutableDownloadedData appendData:data];
}

- (NSData *) downloadedData;
{
	return mutableDownloadedData;
}

@synthesize maximumResourceSize;

@end
