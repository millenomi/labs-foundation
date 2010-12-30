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
@property(nonatomic) BOOL waitingForDelegateToRespond;

@end


@implementation ILDockedMode

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.disablesIdleTimerDuringDockedMode = YES;
	}
	return self;
}

- (void) dealloc
{
	self.monitoringForDockedMode = NO;
	[super dealloc];
}


@synthesize disablesIdleTimerDuringDockedMode;
- (void) setDisablesIdleTimerDuringDockedMode:(BOOL) d;
{
	if (d != disablesIdleTimerDuringDockedMode) {
		disablesIdleTimerDuringDockedMode = d;
		
		if (self.inDockedMode)
			[UIApplication sharedApplication].idleTimerDisabled = YES;
	}
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
			
			if (self.waitingForDelegateToRespond) {
				[self.delegate dockedModeWillNoLongerBeginAutomatically:self];
				self.waitingForDelegateToRespond = NO;
			}
			
		}
	}
}

@synthesize inDockedMode;
- (void) setInDockedMode:(BOOL) m;
{
	if (m != inDockedMode) {
		inDockedMode = m;
		
		if (m) {
			
			self.waitingForDelegateToRespond = NO;
			
			[self.checkTimer invalidate];
			self.checkTimer = nil;
			
			if (self.disablesIdleTimerDuringDockedMode)
				[UIApplication sharedApplication].idleTimerDisabled = YES;
			
			[self.delegate dockedModeDidBegin:self];
			
		} else {

			[self.delegate dockedModeDidEnd:self];

			if (self.disablesIdleTimerDuringDockedMode)
				[UIApplication sharedApplication].idleTimerDisabled = NO;
			
			if (self.monitoringForDockedMode && !self.checkTimer)
				self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(check:) userInfo:nil repeats:YES];
						
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
		
		self.waitingForDelegateToRespond = YES;
		[self.delegate dockedMode:self willBeginAutomaticallyWithin:kILDockedModeSecondsBeforeStarting - secondsWithoutEvents];
		
	} else if (secondsWithoutEvents > kILDockedModeSecondsBeforeStarting) {

		self.waitingForDelegateToRespond = NO;
		self.inDockedMode = YES;
		
	} else if (self.waitingForDelegateToRespond) {
				
		[self.delegate dockedModeWillNoLongerBeginAutomatically:self];
		self.waitingForDelegateToRespond = NO;
		
	}
}

@synthesize checkTimer, waitingForDelegateToRespond;

@end
