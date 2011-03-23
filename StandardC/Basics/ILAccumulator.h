//
//  ILAccumulator.h
//  Basics
//
//  Created by ∞ on 23/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef ILAccumulator_h
#define ILAccumulator_h 1

#include <sys/types.h>
#include "ILAlloc.h"

typedef struct ILAccumulator ILAccumulator;

extern ILAccumulator* ILAccumulatorCreate(ILAlloc* alloc);
extern void ILAccumulatorDestroy(ILAccumulator* acc);

extern size_t ILAccumulatorGetLength(ILAccumulator* acc);
extern void* ILAccumulatorGetBytes(ILAccumulator* acc);

extern void ILAccumulatorAppend(ILAccumulator* acc, void* bytes, size_t size);
extern void ILAccumulatorAppendContentsOfAccumulator(ILAccumulator* acc, ILAccumulator* source);

#endif // #ifndef ILAccumulator_h