//
//  ILBuffer.h
//  Basics
//
//  Created by ∞ on 23/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef ILBuffer_h
#define ILBuffer_h 1

#include <sys/types.h>
#include "ILAlloc.h"

typedef struct ILBuffer ILBuffer;

extern ILBuffer* ILBufferCreate(ILAlloc* alloc);
extern void ILBufferDestroy(ILBuffer* acc);

extern size_t ILBufferGetLength(ILBuffer* acc);
extern void* ILBufferGetBytes(ILBuffer* acc);

extern void ILBufferAppend(ILBuffer* acc, void* bytes, size_t size);
extern void ILBufferAppendContentsOfBuffer(ILBuffer* acc, ILBuffer* source);

#endif // #ifndef ILBuffer_h