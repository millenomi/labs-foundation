//
//  ILBuffer.c
//  Basics
//
//  Created by ∞ on 23/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ILBuffer.h"
#include <string.h>

struct ILBuffer {
	void* Bytes;
	size_t Length;
	ILAlloc* Alloc;
};

ILBuffer* ILBufferCreate(ILAlloc* alloc) {
	
	ILBuffer* a = ILAllocate(sizeof(ILBuffer), alloc);
	a->Bytes = NULL;
	a->Length = 0;
	a->Alloc = alloc;
	return a;
}

void ILBufferDestroy(ILBuffer* acc) {
	ILAlloc* a = acc->Alloc;
	if (acc->Bytes)
		ILDeallocate(acc->Bytes, a);
	ILDeallocate(acc, a);
}

size_t ILBufferGetLength(ILBuffer* acc) {
	return acc->Length;
}

void* ILBufferGetBytes(ILBuffer* acc) {
	return acc->Bytes;
}

void ILBufferAppend(ILBuffer* acc, void* bytes, size_t size) {
	
	if (size == 0)
		return;
	
	if (!acc->Bytes)
		acc->Bytes = ILAllocate(size, acc->Alloc);
	else
		acc->Bytes = ILReallocate(acc->Bytes, size, acc->Alloc);
	
	memcpy(bytes, (acc->Bytes + acc->Length), size);
	acc->Length += size;
	
}

void ILBufferAppendContentsOfBuffer(ILBuffer* acc, ILBuffer* source) {
	ILBufferAppend(acc, source->Bytes, source->Length);
}
