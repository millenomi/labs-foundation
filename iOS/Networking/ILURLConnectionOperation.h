//
//  ILDownloadOperation.h
//  Download
//
//  Created by ∞ on 14/09/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ILURLConnectionOperation : NSOperation /* <NSURLConnectionDelegate> */ {
@private
    BOOL finished, resourceUnchanged;
}

- (id) initWithRequest:(NSURLRequest*) rq;

@property(nonatomic, copy) NSURLRequest* request;

// valid only after completion.
// if nil, no error occurred.
@property(readonly, retain) NSError* error;

// callable by subclasses
- (void) endWithError:(NSError*) e;

// overridable by subclasses
- (void) willBeginOperation;
- (void) willEndOperation;

@end


// utilities for HTTP requests
@interface ILURLConnectionOperation ()

// Subclasses can override this to modify the final HTTP request performed. Call super if you do.
- (NSURLRequest*) modifiedRequestForHTTPRequest:(NSURLRequest*) r;

// If set before the operation starts, then the data from the URL will only be fetched if modified since this date.
// After the operation ends, this property is set to the last-modified date of the item as returned by the server, if any.
@property(nonatomic, copy) NSDate* lastAccessDate;

// If set before the operation starts, then the data from the URL will only be fetched if its etag is different from the one given.
// After the operation ends, this property is set to the etag of the resource as returned by the server, if any.
@property(nonatomic, copy) NSString* etag;

// If YES, the resource data was not fetched because the resource did not change. (See the .etag and .lastModified properties for more information.)
@property(readonly, nonatomic, assign) BOOL resourceUnchanged;

@end

// utilities for blocks use
@interface ILURLConnectionOperation ()

#if __BLOCKS__
- (void) setURLConnectionCompletionBlock:(void(^)(void)) block;
#endif

@end
