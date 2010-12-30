//
//  ILDockedMode.m
//  DockedMode
//
//  Created by ∞ on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILDockedMode.h"

#import "Foundation/Basics/ILSwizzling.h"

#pragma mark -
#pragma mark Idle Management

static CFAbsoluteTime ILDockedModeAbsoluteTimeForLastEvent;

@interface UIApplication (ILDockedModeIdleMonitoring)
- (void) ILDockedModeIdleMonitoring_sendEvent:(UIEvent*) e;
@end

@implementation UIApplication (ILDockedModeIdleMonitoring)

- (void) ILDockedModeIdleMonitoring_sendEvent:(UIEvent*) e;
{
	ILDockedModeAbsoluteTimeForLastEvent = CFAbsoluteTimeGetCurrent();
	[self ILDockedModeIdleMonitoring_sendEvent:e]; // goes to the regular implementation thanks to the MAGIC OF SWIZZLING.
}

@end


#pragma mark -
#pragma mark Docked Mode proper

static BOOL ILDockedModeHasSwizzledSendEvents = NO;

@interface ILDockedMode ()

@property(nonatomic, retain) NSTimer* checkTimer;
@property(nonatomic, getter=isInDockedMode) BOOL inDockedMode;

@property(nonatomic) uint64_t mostCurrentResponseIdentifier;

@end


@implementation ILDockedMode

- (void) dealloc
{
	self.monitoringForDockedMode = NO;
	[super dealloc];
}


@synthesize monitoringForDockedMode;
- (void) setMonitoringForDockedMode:(BOOL) m;
{
	if (m != monitoringForDockedMode) {
		monitoringForDockedMode = m;
		
		if (m) {
			
			if (!ILDockedModeHasSwizzledSendEvents) {
				[UIApplication exchangeImplementationForSelector:@selector(sendEvent:) withImplementationForSelector:@selector(ILDockedModeIdleMonitoring_sendEvent:)];
				
				ILDockedModeAbsoluteTimeForLastEvent = CFAbsoluteTimeGetCurrent();
				ILDockedModeHasSwizzledSendEvents = YES;
			}
			
			[UIDevice currentDevice].batteryMonitoringEnabled = YES;
			
			self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(check:) userInfo:nil repeats:YES];
			
		} else {
			
			[self.checkTimer invalidate];
			self.checkTimer = nil;
			
		}
	}
}

@synthesize inDockedMode;
- (void) setInDockedMode:(BOOL) m;
{
	if (m != inDockedMode) {
		inDockedMode = m;
		
		if (m) {
			
			[self.delegate dockedModeDidBegin:self];
			
		} else {

			[self.delegate dockedModeDidEnd:self];
			
		}
	}
}

@synthesize delegate;

#define kILDockedModeSecondsBeforePreparing 30.0
#define kILDockedModeSecondsBeforeStarting 45.0

- (void) check:(NSTimer*) t;
{
	UIDeviceBatteryState s = [UIDevice currentDevice].batteryState;
	BOOL chargerConnected = (s == UIDeviceBatteryStateCharging || s == UIDeviceBatteryStateFull);

	if (!chargerConnected)
		return;
	
	NSTimeInterval secondsWithoutEvents = CFAbsoluteTimeGetCurrent() - ILDockedModeAbsoluteTimeForLastEvent;
	
	if (secondsWithoutEvents > kILDockedModeSecondsBeforePreparing) {
		
		uint64_t ident = self.mostCurrentResponseIdentifier;
		
		[self.delegate dockedMode:self shouldBeginWithinTimeout:kILDockedModeSecondsBeforeStarting - secondsWithoutEvents responseBlock:^(BOOL response) {
			
			if (self.mostCurrentResponseIdentifier != ident)
				return;
			
			if (response)
				self.inDockedMode = YES;
			
		}];
		
	} else {
		
		self.mostCurrentResponseIdentifier++;
		self.inDockedMode = YES;
		
	}
}

@synthesize checkTimer, mostCurrentResponseIdentifier;

@end
