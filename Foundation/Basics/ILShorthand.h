
#ifndef ILShorthand_H
#define ILShorthand_H 1

#ifdef __OBJC__

#define ILInit() do { \
	self = [super init]; \
	if (!self)\
		return nil; \
} while (0)

#define ILRetain(to, what) do { \
	[(to) autorelease]; \
	to = [(what) retain]; \
} while (0)

#define ILCopy(to, what) do { \
	[(to) autorelease]; \
	to = [(what) copy]; \
} while (0)

#define ILRelease(to)  do { \
	[(to) release]; \
	to = nil; \
} while (0)

#define ILAs(cls, exp) ILRequireOfClass([cls class], (exp))

static inline id ILRequireOfClass(Class c, id obj) {
	return [obj isKindOfClass:c]? obj : nil;
}

#define ILIsCopy copy, nonatomic
#define ILIsReadOnly readonly, nonatomic

#if ILABS_USES_ARC

	#define ILIsStrong strong, nonatomic
	#define ILIsWeak weak, nonatomic

#else

	#define ILIsStrong retain, nonatomic
	#define ILIsWeak assign, nonatomic

#endif

#endif

#endif // ILShorthand_H