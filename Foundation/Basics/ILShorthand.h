
#ifndef ILShorthand_H
#define ILShorthand_H 1

#ifdef __OBJC__

#define ILInit() do { \
	self = [super init]; \
	if (!self)\
		return nil; \
} while (0)

#endif

#endif // ILShorthand_H