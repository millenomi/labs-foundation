//
//  ILDownloadOperation.m
//  Download
//
//  Created by ∞ on 14/09/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ILURLConnectionOperation.h"
#import "NSDateFormatter-RFC2822.h"

@interface ILURLConnectionOperation ()
@property(nonatomic, retain) NSURLConnection* connection;
@property(retain) NSError* error;

#if __BLOCKS__
@property(nonatomic, copy) void (^privateCompletionBlock)(void);
#endif

@end

static BOOL ILURLConnectionHasBlocksSupport() {
#if __BLOCKS__
	#if TARGET_OS_IPHONE
		return NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_4_0;
	#else
		return NSFoundationVersionNumber >= NSFoundationVersionNumber10_6;
	#endif
#else
	return NO;
#endif
}

@implementation ILURLConnectionOperation

- (id) initWithRequest:(NSURLRequest*) rq;
{
    if ((self = [super init]))
        self.request = rq;
    
    return self;
}

- (void)dealloc {
	self.request = nil;
	self.error = nil;
	self.privateCompletionBlock = nil;
	self.lastAccessDate = nil;
	self.etag = nil;
    [super dealloc];
}

- (void) main;
{	
	if ([[[self.request URL] scheme] isEqual:@"http"] || [[[self.request URL] scheme] isEqual:@"https"])
		self.request = [self modifiedRequestForHTTPRequest:self.request];

	[self willBeginOperation];

	self.connection = [[[NSURLConnection alloc] initWithRequest:self.request delegate:self] autorelease];
	    
    while (!finished && ![self isCancelled]) {
        NSDate* d = [[NSDate alloc] initWithTimeIntervalSinceNow:2.0];
        [[NSRunLoop currentRunLoop] runUntilDate:d];
        [d release];
    }
    
	NSError* e = [self isCancelled]? [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil] : nil;
	[self endWithError:e];
}

- (void) done;
{
	if (finished)
		return;
	
	[self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    finished = YES;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
	
	if (!ILURLConnectionHasBlocksSupport() && self.privateCompletionBlock) {
		(self.privateCompletionBlock)();
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
    [self endWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *) e;
{
    [self endWithError:e];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
	if (![response isKindOfClass:[NSHTTPURLResponse class]])
		return;
	
	NSHTTPURLResponse* r = (NSHTTPURLResponse*) response;
	
	if ([r statusCode] == 304 /* Not Modified */)
		resourceUnchanged = YES;
	
	id x = [[r allHeaderFields] objectForKey:@"Last-Modified"];
	self.lastAccessDate = x? [NSDateFormatter dateFromRFC2822String:x] : nil;
	self.etag = [[r allHeaderFields] objectForKey:@"Etag"];
}

@synthesize request, connection, lastAccessDate, etag, resourceUnchanged;

@synthesize error;
- (void) endWithError:(NSError *)e;
{
	if (finished)
		return;
	
    self.error = e;

	[self willEndOperation];

    [self.connection cancel];
	self.connection = nil;

    [self done];
}

- (void) willBeginOperation {}
- (void) willEndOperation {}

- (NSURLRequest *) modifiedRequestForHTTPRequest:(NSURLRequest *)r;
{
	if (!self.lastAccessDate && !self.etag)
		return r;
	
	NSMutableURLRequest* m = [[r mutableCopy] autorelease];
	
	if (self.lastAccessDate)
		[m setValue:[NSDateFormatter RFC2822StringFromDate:self.lastAccessDate] forHTTPHeaderField:@"If-Modified-Since"];
	
	if (self.etag)
		[m setValue:self.etag forHTTPHeaderField:@"Etag"];
	
	return m;
}

#if __BLOCKS__
@synthesize privateCompletionBlock;

- (void) setURLConnectionCompletionBlock:(void(^)(void)) block;
{
	if (ILURLConnectionHasBlocksSupport())
		[self setCompletionBlock:block];
	else
		self.privateCompletionBlock = (id) block;
}
#endif

@end

