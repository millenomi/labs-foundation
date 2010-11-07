//
//  ILStretchableImageButton.m
//  Controls
//
//  Created by ∞ on 07/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILStretchableImageButton.h"


@implementation ILStretchableImageButton

- (void) setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
{
	if (state == UIControlStateNormal) {
		if (image != actualBackgroundImage) {
			[actualBackgroundImage release];
			actualBackgroundImage = [image retain];
		}
	}
	
	[super setBackgroundImage:image forState:state];
}

@synthesize backgroundImageCaps;
- (void) setBackgroundImageCaps:(CGSize) caps;
{
	if (!actualBackgroundImage)
		actualBackgroundImage = [[self backgroundImageForState:UIControlStateNormal] retain];
	
	if (caps.width != 0 || caps.height != 0)
		[super setBackgroundImage:[actualBackgroundImage stretchableImageWithLeftCapWidth:caps.width topCapHeight:caps.height] forState:UIControlStateNormal];
	
	backgroundImageCaps = caps;
}

- (void) dealloc
{
	[actualBackgroundImage release];
	[super dealloc];
}


@end
