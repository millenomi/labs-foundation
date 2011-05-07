//
//  ILReachability.h
//  Mover3
//
//  Created by ∞ on 04/12/10.
//  Copyright 2010 Infinite Labs (Emanuele Vulcano). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#define kILHostReachabilityDidChangeStateNotification @"ILHostReachabilityDidChangeStateNotification"
@protocol ILHostReachabilityDelegate;

@interface ILHostReachability : NSObject {
@private
	SCNetworkReachabilityRef reach;
	id <ILHostReachabilityDelegate> delegate;
	
	BOOL reachabilityKnown;
	BOOL reachable;
	BOOL requiresRoutingOnWWAN;
}

- (id) initWithHostAddressString:(NSString*) host;

@property(nonatomic, assign) id <ILHostReachabilityDelegate> delegate;

@property(nonatomic, readonly, assign) BOOL reachabilityKnown;

@property(nonatomic, readonly, assign) BOOL reachable;
@property(nonatomic, readonly, assign) BOOL requiresRoutingOnWWAN;

- (void) stop;

@end

@protocol ILHostReachabilityDelegate <NSObject>

- (void) hostReachabilityDidChange:(ILHostReachability*) reach;

@end
