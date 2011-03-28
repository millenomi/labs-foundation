//
//  ILBuffer.c
//  Basics
//
//  Created by ∞ on 23/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ILBuffer.h"

#include <stdlib.h>

static void* ILMalloc(size_t size, ILAlloc* myself) {
	return malloc(size);
}

static void* ILRealloc(void* existing, size_t size, ILAlloc* myself) {
	return realloc(existing, size);
}

static void ILFree(void* existing, ILAlloc* myself) {
	free(existing);
}

static ILAlloc kILMallocContents = {
	&ILMalloc,
	&ILRealloc,
	&ILFree,
	NULL,
	NULL
};

ILAlloc* const kILMalloc = &kILMallocContents;


void* ILAllocate(size_t size, ILAlloc* alloc) {
	void* x = alloc->Alloc(size, alloc);
	if (!x) {
		ILAllocOnFailure handler = alloc->OnAllocFailure;
		if (!handler)
			handler = &IL__KO__CouldNotAllocateMemory;
		
		ILAllocFailure f;
		f.ExistingBuffer = NULL;
		f.NewSize = size;
		f.Myself = alloc;
		return handler(f);
	}
	
	return x;
}

void* ILReallocate(void* existing, size_t size, ILAlloc* alloc) {
	void* x = alloc->Realloc(existing, size, alloc);
	if (!x) {
		ILAllocOnFailure handler = alloc->OnAllocFailure;
		if (!handler)
			handler = &IL__KO__CouldNotAllocateMemory;
		
		ILAllocFailure f;
		f.ExistingBuffer = existing;
		f.NewSize = size;
		f.Myself = alloc;
		return handler(f);
	}
	
	return x;
}

void ILDeallocate(void* existing, ILAlloc* alloc) {
	alloc->Free(existing, alloc);
}

void* IL__KO__CouldNotAllocateMemory(ILAllocFailure f) {
	abort();
	return NULL;
}
