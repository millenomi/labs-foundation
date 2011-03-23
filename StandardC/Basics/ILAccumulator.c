//
//  ILAccumulator.c
//  Basics
//
//  Created by ∞ on 23/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ILAccumulator.h"
#include <string.h>

struct ILAccumulator {
	void* Bytes;
	size_t Length;
	ILAlloc* Alloc;
};

ILAccumulator* ILAccumulatorCreate(ILAlloc* alloc) {
	
	ILAccumulator* a = ILAllocate(sizeof(ILAccumulator), alloc);
	a->Bytes = NULL;
	a->Length = 0;
	a->Alloc = alloc;
	return a;
}

void ILAccumulatorDestroy(ILAccumulator* acc) {
	ILAlloc* a = acc->Alloc;
	if (acc->Bytes)
		ILDeallocate(acc->Bytes, a);
	ILDeallocate(acc, a);
}

size_t ILAccumulatorGetLength(ILAccumulator* acc) {
	return acc->Length;
}

void* ILAccumulatorGetBytes(ILAccumulator* acc) {
	return acc->Bytes;
}

void ILAccumulatorAppend(ILAccumulator* acc, void* bytes, size_t size) {
	
	if (size == 0)
		return;
	
	if (!acc->Bytes)
		acc->Bytes = ILAllocate(size, acc->Alloc);
	else
		acc->Bytes = ILReallocate(acc->Bytes, size, acc->Alloc);
	
	memcpy(bytes, (acc->Bytes + acc->Length), size);
	acc->Length += size;
	
}

void ILAccumulatorAppendContentsOfAccumulator(ILAccumulator* acc, ILAccumulator* source) {
	ILAccumulatorAppend(acc, source->Bytes, source->Length);
}
