
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

#endif

#endif // ILShorthand_H