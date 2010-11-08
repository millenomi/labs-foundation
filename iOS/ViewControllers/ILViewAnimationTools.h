
#import <UIKit/UIKit.h>

CF_INLINE UIViewAnimationOptions ILViewAnimationOptionsForCurve(UIViewAnimationCurve c) {
	switch (c) {
		case UIViewAnimationCurveEaseIn:
			return UIViewAnimationOptionCurveEaseIn;
		case UIViewAnimationCurveEaseInOut:
			return UIViewAnimationOptionCurveEaseInOut;
		case UIViewAnimationCurveEaseOut:
			return UIViewAnimationOptionCurveEaseOut;
		case UIViewAnimationCurveLinear:
			return UIViewAnimationOptionCurveLinear;
			
		default:
			return 0;
	}
}
