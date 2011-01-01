//
//  JSSchema.h
//  Subject
//
//  Created by ∞ on 22/10/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

#define kILSchemaErrorDomain @"net.infinite-labs.tools.ILSchema.ErrorDomain"
enum {
	kILSchemaErrorInitValueNotADictionary = 1,
	kILSchemaErrorRequiredValueMissing = 2,
	kILSchemaErrorNoValidValueForProperty = 3,
	kILSchemaErrorArrayValueFailedValidation = 4,
	kILSchemaErrorDictionaryValueFailedValidation = 5,
	kILSchemaErrorValueFailedValidation = 6,
};

// A specifier that says what part of the object failed validation.
// For kILSchemaErrorRequiredValueMissing, this is the missing property that couldn't be filled in from the dictionary.
#define kILSchemaErrorSourceKey @"ILSchemaErrorSource"

// The object that cause validation to fail.
#define kILSchemaErrorInvalidObjectKey @"ILSchemaErrorInvalidObject"

@interface ILSchema : NSObject <NSCopying> {
	NSDictionary* values;
	NSSet* unspecifiedOptionalValues;
}

// If the passed-in value is not a dictionary or fails validation, returns nil.
- (id) initWithValue:(id) value error:(NSError**) e;

// TO USE THIS CLASS:
// Subclass it, then add readonly properties for JSON types or ILSchema subclasses to it, eg.

// @property(readonly) NSString* name;

// Then, in the .m, do this:

// @dynamic name;
// - (Class) validClassForNameKey { return [NSString class]; }

// You can use a key in the dictionary that's different from the property name by using it as the getter. In that case, use the PROPERTY's name in the valid... method name:
// @property(getter=sorting_order) NSNumber* sortingOrder;
// @dynamic sortingOrder;
// - (Class) validClassForSortingOrderKey /* NOT validClassForSorting_orderKey! */

// TO-MANY PROPERTIES:

// Arrays:
// @dynamic ages;
// - (Class) validClassForValuesOfAgesArrayKey { return [NSNumber class]; }

// Dictionaries:
// @dynamic agesByName;
// - (Class) validClassForValuesOfAgesByNameDictionaryKey { return [NSNumber class]; }

// SCHEMA NESTING:
// @dynamic peopleByName;
// - (Class) validClassForValuesOfPeopleByNameDictionaryKey { return [XYZPeople class]; } // where XYZPeople : ILSchema

// Works with all the valid... method names; the returned object will be of the given class (and required to validate to that schema, of course).

// OPTIONAL VALUES:
// - (BOOL) isValueOptionalForXYZKey { return YES; }

@property(readonly) NSDictionary* underlyingSpecifiedSchemaValues;
@property(readonly) NSSet* underlyingMissingOptionalValueKeys;

// Can be used to check for more complex stuff than the above. It's called at the end of -init after everything has been decoded (assuming it has passed all the above validity check stuff).
- (BOOL) validateAndReturnError:(NSError**) e;

@end

