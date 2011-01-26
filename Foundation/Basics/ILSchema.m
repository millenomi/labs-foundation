//
//  JSSchema.m
//  Subject
//
//  Created by ∞ on 22/10/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILSchema.h"
#import <objc/runtime.h>

@implementation NSError (ILSchemaErrorDisplay)

- (NSString*) ILSchemaErrorDescription;
{
	if (![[self domain] isEqual:kILSchemaErrorDomain])
		return @"<not a ILSchema error>";
	
	NSMutableString* s = [NSMutableString stringWithString:@"(ILSchema error) -- "];

#define ILSchemaErrorCaseFor(constant) \
	case constant: [s appendString:@#constant]; break;
	
	switch ([self code]) {
		ILSchemaErrorCaseFor(kILSchemaErrorInitValueNotADictionary)
		ILSchemaErrorCaseFor(kILSchemaErrorValueFailedValidation)
		ILSchemaErrorCaseFor(kILSchemaErrorRequiredValueMissing)
		ILSchemaErrorCaseFor(kILSchemaErrorArrayValueFailedValidation)
		ILSchemaErrorCaseFor(kILSchemaErrorDictionaryValueFailedValidation)
		ILSchemaErrorCaseFor(kILSchemaErrorNoValidValueForProperty)
		default:
			[s appendString:@"(unknown error)"]; break;
	}
	
	NSMutableDictionary* d = [[[self userInfo] mutableCopy] autorelease];
	[d removeObjectForKey:NSUnderlyingErrorKey];
	[s appendString:[d description]];	
	
//	NSUInteger countOfUnknownKeys = [[self userInfo] count];
	if ([[self userInfo] objectForKey:NSUnderlyingErrorKey]) {
		[s appendFormat:@"\nUnderlying error: %@", [[[self userInfo] objectForKey:NSUnderlyingErrorKey] ILSchemaErrorDescription]];
//		countOfUnknownKeys--;
	}
		
	return s;
}

@end


CF_INLINE NSString* SJStringByUppercasingFirstLetter(NSString* x) {
	return [[[x substringToIndex:1] uppercaseString] stringByAppendingString:[x substringFromIndex:1]];
}

@interface ILSchema ()

- (id) validatedValueForValue:(id)value validClass:(Class)cls validArrayValueClass:(Class)arrayValueCls validDictionaryValueClass:(Class)dictionaryValueCls error:(NSError**) e;

- (id) valueForCallingSelector;

@end


@implementation ILSchema

+ (NSDictionary*) classDynamicPropertyGettersByProperty;
{
	if (self == [ILSchema class])
		return [NSDictionary dictionary];
	
	unsigned int propCount;
	objc_property_t* props = class_copyPropertyList(self, &propCount);
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	
	unsigned int i; for (i = 0; i < propCount; i++) {
		
		const char* name = property_getName(props[i]);
		NSString* propertyName = [NSString stringWithUTF8String:name];
		
		const char* attrs = property_getAttributes(props[i]);

		NSArray* attributes = [[NSString stringWithUTF8String:attrs] componentsSeparatedByString:@","];
		
		// If the property is @dynamic...
		if ([attributes containsObject:@"D"]) {

			NSString* getterName = nil;
			
			for (NSString* attribute in attributes) {
				if ([attribute hasPrefix:@"G"]) {
					getterName = [attribute substringFromIndex:1];
					break;
				}
			}
			
			if (!getterName)
				getterName = propertyName;
			
			[dict setObject:getterName forKey:propertyName];
		}
		
	}
	
	if (props)
		free(props);
	
	return dict;
}

- (id) initWithValue:(id) value error:(NSError**) e;
{
	if ((self = [super init])) {
		if (![value isKindOfClass:[NSDictionary class]]) {
			if (e) *e = [NSError errorWithDomain:kILSchemaErrorDomain code:kILSchemaErrorInitValueNotADictionary userInfo:nil];
			[self release];
			return nil;
		}
		
		NSMutableDictionary* finalValues = [NSMutableDictionary dictionary];
		NSMutableSet* unspecifieds = [NSMutableSet set];
		
		// TODO subclassing, if useful.
		NSDictionary* properties = [[self class] classDynamicPropertyGettersByProperty];
		
		for (NSString* prop in properties) {
			
			// We use getter names as the JSON dictionary keys to look up.
			NSString* getter = [properties objectForKey:prop];
			id subvalue = [value objectForKey:getter];
			
			NSString* uppercasePropName = SJStringByUppercasingFirstLetter(prop);

			if (!subvalue || subvalue == [NSNull null]) {
				BOOL optional = NO;
				
				SEL isValueOptionalSelector = NSSelectorFromString([NSString stringWithFormat:@"isValueOptionalFor%@Key", uppercasePropName]);
				
				if ([self respondsToSelector:isValueOptionalSelector]) {
					NSMethodSignature* sig = [self methodSignatureForSelector:isValueOptionalSelector];
					NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
					
					[invo setTarget:self];
					[invo setSelector:isValueOptionalSelector];
					[invo invoke];
					
					[invo getReturnValue:&optional];
				}
				
				if (!optional) {
					if (e) *e = [NSError errorWithDomain:kILSchemaErrorDomain code:kILSchemaErrorRequiredValueMissing userInfo:[NSDictionary dictionaryWithObject:prop forKey:kILSchemaErrorSourceKey]];
					[self release];
					return nil;
				} else {
					[unspecifieds addObject:getter];
					continue;
				}
			}
			
			
			Class validClass = Nil, validArrayValueClass = Nil, validDictionaryValueClass = Nil;
			
			SEL validToOneClassSelector = NSSelectorFromString([NSString stringWithFormat:@"validClassFor%@Key", uppercasePropName]);
						
			SEL validValueClassForArraySelector = NSSelectorFromString([NSString stringWithFormat:@"validClassForValuesOf%@ArrayKey", uppercasePropName]);

			SEL validValueClassForDictSelector = NSSelectorFromString([NSString stringWithFormat:@"validClassForValuesOf%@DictionaryKey", uppercasePropName]);

			if ([self respondsToSelector:validValueClassForDictSelector]) {
				validClass = [NSDictionary class];
				validDictionaryValueClass = [self performSelector:validValueClassForDictSelector];
			} else if ([self respondsToSelector:validValueClassForArraySelector]) {
				validClass = [NSArray class];
				validArrayValueClass = [self performSelector:validValueClassForArraySelector];
			} else
				validClass = [self performSelector:validToOneClassSelector];
			
			if (!validClass) {
				[self release];
				[NSException raise:@"ILSchemaUnknownPropertyType" format:@"You MUST implement one of %@, %@, or %@ in class %@ to specify the type of property %@",
					[NSString stringWithFormat:@"validClassFor%@Key", uppercasePropName],
					[NSString stringWithFormat:@"validClassForValuesOf%@ArrayKey", uppercasePropName],
					[NSString stringWithFormat:@"validClassForValuesOf%@DictionaryKey", uppercasePropName],
					[self class],
					prop];
				return nil;
			}
			
			NSError* e2;
			id validatedSubvalue = [self validatedValueForValue:subvalue validClass:validClass validArrayValueClass:validArrayValueClass validDictionaryValueClass:validDictionaryValueClass error:&e2];
			
			if (!validatedSubvalue) {
				NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
										  prop, kILSchemaErrorSourceKey,
										  e2, NSUnderlyingErrorKey,
										  nil];
				if (e) *e = [NSError errorWithDomain:kILSchemaErrorDomain code:kILSchemaErrorNoValidValueForProperty userInfo:userInfo];
				
				[self release];
				return nil;
			} else
				[finalValues setObject:validatedSubvalue forKey:getter];
			
		}
		
		values = [finalValues copy];
		unspecifiedOptionalValues = [unspecifieds copy];

		if (![self validateAndReturnError:e]) {
			[self release];
			return nil;
		}
		
	}
	
	return self;
}

- (void) dealloc
{
	[values release];
	[unspecifiedOptionalValues release];
	[super dealloc];
}


- (id) validatedValueForValue:(id)value validClass:(Class)cls validArrayValueClass:(Class)arrayValueCls validDictionaryValueClass:(Class)dictionaryValueCls error:(NSError**) e;
{
	
	if (![cls isSubclassOfClass:[ILSchema class]]) {

		if (![value isKindOfClass:cls]) {
			NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:value forKey:kILSchemaErrorInvalidObjectKey];
			if (value) {
				[userInfo setObject:[value class] forKey:kILSchemaErrorActualClassKey];
				[userInfo setObject:cls forKey:kILSchemaErrorExpectedClassKey];
			}
			
			if (e) *e = [NSError errorWithDomain:kILSchemaErrorDomain code:kILSchemaErrorValueFailedValidation userInfo:userInfo];
			return nil;
		}
		
		if (arrayValueCls) {
			
			if (![value isKindOfClass:[NSArray class]]) {
				NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:value forKey:kILSchemaErrorInvalidObjectKey];
				if (value) {
					[userInfo setObject:[value class] forKey:kILSchemaErrorActualClassKey];
					[userInfo setObject:[NSArray class] forKey:kILSchemaErrorExpectedClassKey];
				}
				
				if (e) *e = [NSError errorWithDomain:kILSchemaErrorDomain code:kILSchemaErrorValueFailedValidation userInfo:userInfo];
				return nil;
			}
			
			NSMutableArray* arr = [NSMutableArray array];
			
			NSInteger i = 0;
			
			for (id x in value) {
				NSError* e2;
				id v = [self validatedValueForValue:x validClass:arrayValueCls validArrayValueClass:nil validDictionaryValueClass:nil error:&e2];

				if (!v) {
					if (e) {
						NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSNumber numberWithInteger:i], kILSchemaErrorSourceKey,
											  value, kILSchemaErrorInvalidObjectKey,
											  e2, NSUnderlyingErrorKey,
											  nil];
						*e = [NSError errorWithDomain:kILSchemaErrorDomain code:kILSchemaErrorArrayValueFailedValidation userInfo:userInfo];
					}
					
					return nil;
				}
				
				[arr addObject:v];
			}
			
			return arr;
			
		} else if (dictionaryValueCls) {
			
			if (![value isKindOfClass:[NSDictionary class]]) {
				NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:value forKey:kILSchemaErrorInvalidObjectKey];
				if (value) {
					[userInfo setObject:[value class] forKey:kILSchemaErrorActualClassKey];
					[userInfo setObject:[NSDictionary class] forKey:kILSchemaErrorExpectedClassKey];
				}
								
				if (e) *e = [NSError errorWithDomain:kILSchemaErrorDomain code:kILSchemaErrorValueFailedValidation userInfo:userInfo];
				return nil;
			}
			
			NSMutableDictionary* dict = [NSMutableDictionary dictionary];
			
			for (id x in value) {
				id preV = [value objectForKey:x];
				NSError* e2;
				id v = [self validatedValueForValue:preV validClass:dictionaryValueCls validArrayValueClass:nil validDictionaryValueClass:nil error:&e2];

				if (!v) {
					if (e) {
						NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
												  x, kILSchemaErrorSourceKey,
												  preV ?: [NSNull null], kILSchemaErrorInvalidObjectKey,
												  e2, NSUnderlyingErrorKey,
												  nil];
						*e = [NSError errorWithDomain:kILSchemaErrorDomain code:kILSchemaErrorDictionaryValueFailedValidation userInfo:userInfo];
					}
					
					return nil;
				}
				
				[dict setObject:v forKey:x];
			}
			
			return dict;
			
		} else
			return value;
		
	} else
		return [[[cls alloc] initWithValue:value error:e] autorelease];
}

- (NSMethodSignature*) methodSignatureForSelector:(SEL)aSelector;
{
	NSString* prop = NSStringFromSelector(aSelector);
	if ([values objectForKey:prop] || [unspecifiedOptionalValues containsObject:prop])
		return [super methodSignatureForSelector:@selector(valueForCallingSelector)];
	else
		return [super methodSignatureForSelector:aSelector];
}

- (BOOL) respondsToSelector:(SEL)aSelector;
{
	NSString* prop = NSStringFromSelector(aSelector);
	return ([values objectForKey:prop] || [unspecifiedOptionalValues containsObject:prop]) || [super respondsToSelector:aSelector];
}

- (id) valueForCallingSelector;
{ /* used for its signature only */ return nil; }

- (void) forwardInvocation:(NSInvocation *)anInvocation;
{
	NSString* prop = NSStringFromSelector([anInvocation selector]);
	id x = [values objectForKey:prop];
	
	if (x)
		[anInvocation setReturnValue:&x];
	else if ([unspecifiedOptionalValues containsObject:prop]) {
		id nilVar = nil;
		[anInvocation setReturnValue:&nilVar];
	} else
		[self doesNotRecognizeSelector:[anInvocation selector]];
}

- (NSString *) description;
{
	return [NSString stringWithFormat:@"%@ (missing = %@, values = %@)", [super description], unspecifiedOptionalValues, values];
}

- (NSUInteger) hash;
{
	return [values hash] ^ [unspecifiedOptionalValues hash] ^ [[self class] hash];
}

- (BOOL) isEqual:(id)object;
{
	return object == self || ([object isKindOfClass:[self class]] && [[object underlyingSpecifiedSchemaValues] isEqual:values] && [[object underlyingMissingOptionalValueKeys] isEqual:unspecifiedOptionalValues]);
}

- (NSDictionary *) underlyingSpecifiedSchemaValues;
{
	return values;
}

- (NSSet *) underlyingMissingOptionalValueKeys;
{
	return unspecifiedOptionalValues;
}

- (BOOL) validateAndReturnError:(NSError**) e;
{
	return YES;
}

- (id) copyWithZone:(NSZone *)zone;
{
	return [self retain];
}

@end
