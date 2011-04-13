//
//  ILTCPServer.m
//  Networking
//
//  Created by ∞ on 01/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ILTCPServer.h"
#import "NSData+ILIPAddressTools.h"

#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#else
#import <CoreFoundation/CoreFoundation.h>
#endif

#import <sys/socket.h>
#import <netinet/in.h>
#import <unistd.h>

@interface ILTCPServer ()

@property(nonatomic, retain) id socket;
@property(nonatomic) uint16_t port;

- (BOOL) acceptConnectionWithNativeSocketHandle:(CFSocketNativeHandle) handle;

@end


@implementation ILTCPServer

@synthesize socket;

- (void) dealloc;
{
	[self stop];
	[super dealloc];
}

static void ILTCPServerDidReceiveEvent(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void* data, void* info);

#pragma mark Starting and stopping

@synthesize delegate;
- (void) setDelegate:(id <ILTCPServerDelegate>) d;
{
	if (d != delegate) {
		delegate = d;
		
		if (!delegate)
			[self stop];
	}
}

@synthesize port;

- (BOOL) start:(NSError**) e;
{
	CFSocketRef serverSocket = NULL;
	
	if (self.socket)
		return YES; // we're already started.
	
	if (!self.delegate) {
		if (e) *e = [NSError errorWithDomain:kILTCPServerErrorDomain code:kILTCPServerErrorDelegateRequiredToStart userInfo:nil];
		goto error;
	}
	
	/* original comment from WiTap: */
	// Start by trying to do everything with IPv6.  This will work for both IPv4 and IPv6 clients 
    // via the miracle of mapped IPv4 addresses.	

	/* So we start by harnessing the power of HoNkInG mIrAcLeS! */
	
	SInt32 pickedProtocolFamily;
	
	CFSocketContext selfAsSocketContext = {0, self, NULL, NULL, NULL};
	serverSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET6, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack) &ILTCPServerDidReceiveEvent, &selfAsSocketContext);
	
	if (serverSocket) {
		pickedProtocolFamily = PF_INET6;
		// YAY
	} else {
		pickedProtocolFamily = PF_INET;
		serverSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack) &ILTCPServerDidReceiveEvent, &selfAsSocketContext);
	}
	
	if (!serverSocket) {
		if (e) *e = [NSError errorWithDomain:kILTCPServerErrorDomain code:kILTCPServerErrorSocketsUnavailable userInfo:nil];
		goto error;
	}
	
	// Set SO_REUSEADDR so we don't get stupid POSIXy behavior on socket close.
	
	const int pleaseDoSo = 1;
	setsockopt(CFSocketGetNative(serverSocket), SOL_SOCKET, SO_REUSEADDR, (const void*) &pleaseDoSo, sizeof(pleaseDoSo));
	
	// Now we need to set up the address this thing listens to! This is easy, but we need to bifurcate depending on what protocol family we picked above.
	
	NSData* address;
	if (pickedProtocolFamily == PF_INET6) {
		struct sockaddr_in6 addressStruct6;
		memset(&addressStruct6, 0, sizeof(addressStruct6));
		addressStruct6.sin6_len = sizeof(addressStruct6);
		addressStruct6.sin6_family = AF_INET6;
		addressStruct6.sin6_port = 0;
		addressStruct6.sin6_flowinfo = 0;
		addressStruct6.sin6_addr = in6addr_any;

		address = [NSData dataWithBytes:&addressStruct6 length:sizeof(addressStruct6)];
	} else {
		struct sockaddr_in addressStruct4;
		memset(&addressStruct4, 0, sizeof(addressStruct4));
		addressStruct4.sin_len = sizeof(addressStruct4);
		addressStruct4.sin_family = AF_INET;
		addressStruct4.sin_port = 0;
		addressStruct4.sin_addr.s_addr = htonl(INADDR_ANY);
		
		address = [NSData dataWithBytes:&addressStruct4 length:sizeof(addressStruct4)];
	}
	
	if (CFSocketSetAddress(serverSocket, (CFDataRef) address) != kCFSocketSuccess) {
		if (e) *e = [NSError errorWithDomain:kILTCPServerErrorDomain
										code:kILTCPServerErrorNoAddressesAvailableToBind
									userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithLong:(long) pickedProtocolFamily] forKey:kILTCPProtocolFamily]];
		goto error;
	}
	
	NSData* actualAddress = [NSMakeCollectable(CFSocketCopyAddress(serverSocket)) autorelease];
	if ([actualAddress socketAddressIsIPAddressOfVersion:kILIPAddressVersion6])
		self.port = ntohs(((struct sockaddr_in6*) [actualAddress bytes])->sin6_port);
	else
		self.port = ntohs(((struct sockaddr_in*) [actualAddress bytes])->sin_port);
	
	CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, serverSocket, 0);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
	CFRelease(source);
	
	self.socket = (id) serverSocket;

	return YES;
	
error:
	if (serverSocket) {
		CFSocketInvalidate(serverSocket);
		CFRelease(serverSocket);
	}
	
	return NO;
}

- (void) stop;
{
	if (self.socket) {
		CFSocketInvalidate((CFSocketRef) self.socket);
		self.socket = nil;
	}
}

#pragma mark Accepting connections

static void ILTCPServerDidReceiveEvent(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void* data, void* info) {

	if (type == kCFSocketAcceptCallBack) {
		
		ILTCPServer* me = (ILTCPServer*) info;
		CFSocketNativeHandle nativeSocket = *((CFSocketNativeHandle*) data);
		
		if (![me acceptConnectionWithNativeSocketHandle:nativeSocket])
			close(nativeSocket);
	}
	
}

- (BOOL) acceptConnectionWithNativeSocketHandle:(CFSocketNativeHandle) handle;
{
	// Grab the address of the party of the third party. Er, the remote peer.
	uint8_t addressStruct[SOCK_MAXADDRLEN];
	socklen_t addressStructLength = sizeof(addressStruct);
	
	NSData* address = nil;
	if (getpeername(handle, (struct sockaddr*) addressStruct, &addressStructLength) == 0)
		address = [NSData dataWithBytes:addressStruct length:addressStructLength];
	
	// Set up the streams
	NSInputStream* input = nil;
	NSOutputStream* output = nil;
	
	CFStreamCreatePairWithSocket(kCFAllocatorDefault, handle, (CFReadStreamRef*) &input, (CFWriteStreamRef*) &output);
	
	if (!input || !output)
		return NO;
	
	[input setProperty:[NSNumber numberWithBool:YES] forKey:(id) kCFStreamPropertyShouldCloseNativeSocket];
	[output setProperty:[NSNumber numberWithBool:YES] forKey:(id) kCFStreamPropertyShouldCloseNativeSocket];
	
	// and off it goes
	[self.delegate TCPServer:self didAcceptConnectionFromAddress:address inputStream:input outputStream:output];

	return YES;
}

@end
