//
//  ILStretchableImageButton.h
//  Controls
//
//  Created by ∞ on 07/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ILStretchableImageButton : UIButton {
	UIImage* actualBackgroundImage;
	CGSize backgroundImageCaps;
}

@property CGSize backgroundImageCaps;

@end
