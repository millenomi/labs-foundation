//
//  ILUTF8.h
//  Basics
//
//  Created by ∞ on 24/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef ILUTF8_h
#define ILUTF8_h 1

#include <stdint.h>
#include <stdbool.h>
#include <sys/types.h>

typedef uint16_t ILCodePoint;

typedef enum {
	kILUTF8ParsedIntermediate,
	kILUTF8ParsedLast,
	kILUTF8ParseError
} ILUTF8ParseResult;

/**
 
 Parses the code point in buffer at offset offsetToParseFrom.
 Returns the following:
 - If an error occurs, kILUTF8ParseError is returned.
 - If a code point is parsed, it is returned through the returnedCodePoint pointer and kILUTF8ParsedIntermediate or kILUTF8ParsedLast is returned.
 - If a code point potentially exists beyond the returned one, its offset is returned through the returnedNextCodePointOffset pointer and kILUTF8ParsedIntermediate is returned.
 
 The value of the memory pointed by returned... pointers is undefined on return, unless otherwise specified above.
 
 */
extern ILUTF8ParseResult ILUTF8ParseCodePointInBufferAtOffset(uint8_t* buffer, size_t bufferSize, off_t offsetToParseFrom, ILCodePoint* returnedCodePoint, off_t* returnedNextCodePointOffset);

/**
 Returns the size expected for the return buffer used in ILUTF8EncodeCodePoint().
 */
extern size_t ILUTF8GetEncodedCharacterBufferSize();

/**
 If possible, this function returns true and writes the UTF-8-encoded version of code point cp to the output buffer (which you must have allocated). On return, the first bytes of the buffer contain the encoded version of the code point (specifically, the exact length of the encoded byte is returned through returnedLengthUsedInOutputBuffer).
 Otherwise, returns false. In this case, the value of memory pointed to by outputBuffer or returnedLengthUsedInOutputBuffer on return is undefined.
 
 outputBuffer must have been allocated to be ILUTF8GetEncodedCharacterBufferSize() or more bytes in length.
 */
extern bool ILUTF8EncodeCodePoint(ILCodePoint cp, uint8_t* outputBuffer, size_t* returnedLengthUsedInOutputBuffer);


#endif // #ifndef ILUTF8_h