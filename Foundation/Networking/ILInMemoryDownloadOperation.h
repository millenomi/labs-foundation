//
//  ILInMemoryDownloadOperation.h
//  Networking
//
//  Created by ∞ on 21/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILURLConnectionOperation.h"

#define kILInMemoryDownloadOperationErrorDomain @"ILInMemoryDownloadOperationErrorDomain"
enum {
	kILInMemoryDownloadOperationErrorResourceTooLarge = 1,
};

@interface ILInMemoryDownloadOperation : ILURLConnectionOperation {
@private
	NSMutableData* mutableDownloadedData;
	size_t maximumResourceSize;
}

@property(nonatomic) size_t maximumResourceSize; // 0 means no limit
@property(nonatomic, readonly) NSData* downloadedData; // its length is <= .maximumResourceSize if that size is nonzero.

@end
