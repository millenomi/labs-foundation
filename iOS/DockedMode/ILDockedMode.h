//
//  ILDockedMode.h
//  DockedMode
//
//  Created by ∞ on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#if NS_BLOCKS_AVAILABLE

@protocol ILDockedModeDelegate;

typedef void (^ILDockedModeShouldBeginResponse)(BOOL shouldBegin);

@interface ILDockedMode : NSObject {
	BOOL hasSwizzledSendEvents;
}

@property(nonatomic, getter=isMonitoringForDockedMode) BOOL monitoringForDockedMode;
@property(nonatomic, assign) id <ILDockedModeDelegate> delegate;

@property(nonatomic, readonly, getter=isInDockedMode) BOOL inDockedMode;

@end


@protocol ILDockedModeDelegate <NSObject>

- (void) dockedModeDidBegin:(ILDockedMode*) dm;
- (void) dockedModeDidEnd:(ILDockedMode*) dm;

- (void) dockedMode:(ILDockedMode*) dm shouldBeginWithinTimeout:(NSTimeInterval) to responseBlock:(ILDockedModeShouldBeginResponse) response;

@end

#endif
