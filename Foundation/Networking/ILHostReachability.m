//
//  ILReachability.m
//  Mover3
//
//  Created by ∞ on 04/12/10.
//  Copyright 2010 Infinite Labs (Emanuele Vulcano). All rights reserved.
//

#import "ILHostReachability.h"

@interface ILHostReachability ()

- (void) updateNetworkWithFlags:(SCNetworkReachabilityFlags) flags;

@property(assign) BOOL reachabilityKnown;

@property(assign) BOOL reachable;
@property(assign) BOOL requiresRoutingOnWWAN;


@end


@implementation ILHostReachability

@synthesize reachable, reachabilityKnown, requiresRoutingOnWWAN;

static void ILHostReachabilityDidChangeNetworkState(SCNetworkReachabilityRef reach, SCNetworkReachabilityFlags flags, void* info) {

	[(ILHostReachability*)info updateNetworkWithFlags:flags];
	
}

- (id) initWithHostAddressString:(NSString*) host;
{
	if ((self = [super init])) {
		
		reach = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [host UTF8String]);
		
		SCNetworkReachabilityContext selfContext = {0, self, NULL, NULL, &CFCopyDescription};
		SCNetworkReachabilitySetCallback(reach, &ILHostReachabilityDidChangeNetworkState, &selfContext);
		SCNetworkReachabilityScheduleWithRunLoop(reach, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
		
		SCNetworkReachabilityFlags flags;
		if (SCNetworkReachabilityGetFlags(reach, &flags))
			[self updateNetworkWithFlags:flags];
		
	}
	
	return self;
}

- (void) dealloc
{
	[self stop];
	[super dealloc];
}


- (void) stop;
{
	if (reach) {
		SCNetworkReachabilityUnscheduleFromRunLoop(reach, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
		CFRelease(reach);
		reach = NULL;
	}
}

@synthesize delegate;
- (void) setDelegate:(id <ILHostReachabilityDelegate>) d;
{
	if (d != delegate) {
		delegate = d;
		
		if (self.reachabilityKnown)
			[delegate hostReachabilityDidChange:self];
	}
}

- (void) updateNetworkWithFlags:(SCNetworkReachabilityFlags) flags;
{
	self.reachabilityKnown = YES;
	self.reachable = (flags & kSCNetworkReachabilityFlagsReachable);
	self.requiresRoutingOnWWAN = 
#if TARGET_OS_IPHONE
	(flags & kSCNetworkReachabilityFlagsIsWWAN)
#else
	NO
#endif
	;
	
	[self.delegate hostReachabilityDidChange:self];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kILHostReachabilityDidChangeStateNotification object:self];
}

@end
