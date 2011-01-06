//
//  ILTCPServer.h
//  Networking
//
//  Created by ∞ on 01/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ILTCPServerDelegate;


// This is basically a cleaned-up version of TCPServer.m from the Apple samples.

#define kILTCPServerErrorDomain @"ILTCPServerErrorDomain"

enum {
	kILTCPServerErrorSocketsUnavailable = 1,
	kILTCPServerErrorNoAddressesAvailableToBind,
	kILTCPServerErrorDelegateRequiredToStart,
};

// Used in kILTCPServerErrorNoAddressesAvailableToBind's user info dictionary to specify what protocol family was picked (and caused the error).
#define kILTCPProtocolFamily @"ILTCPProtocolFamily"


@interface ILTCPServer : NSObject {
@private
	id <ILTCPServerDelegate> delegate;
	id socket;
	uint16_t port;
}

@property(nonatomic, assign) id <ILTCPServerDelegate> delegate;
@property(nonatomic, readonly) uint16_t port;

- (BOOL) start:(NSError **)e;
- (void) stop;

@end


@protocol ILTCPServerDelegate <NSObject>

- (void) TCPServer:(ILTCPServer*) server didAcceptConnectionFromAddress:(NSData*) address inputStream:(NSInputStream*) input outputStream:(NSOutputStream*) output;

@end
