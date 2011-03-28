//
//  ILBuffer.h
//  Basics
//
//  Created by ∞ on 23/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef ILAlloc_h
#define ILAlloc_h 1

#include <sys/types.h>

// The allocation primitives.

// Values of this type specify the interface to an allocator. You pass these structs to IL...Create() methods, which will then use the allocator to perform any allocation business.
typedef struct ILAlloc ILAlloc;

// A collection of information regarding an allocation failure.
typedef struct ILAllocFailure ILAllocFailure;

struct ILAllocFailure {
	// The allocator that failed.
	ILAlloc* Myself;
	
	// The buffer that was about to be reallocated. NULL if a failure occurred during initial allocation of a buffer.
	void* ExistingBuffer;
	
	// The final size requested for the buffer that could not be allocated.
	size_t NewSize;
};


// A function called every time there is a failure. Useful for debugging. The argument contains information on the failure. If it returns anything, this will be the return value of the ILAllocate or ILReallocate function that invoked it.
typedef void* (*ILAllocOnFailure)(ILAllocFailure f);


// The contents of a ILAlloc structure.
struct ILAlloc {
	
	// This function should allocate a portion of memory at least 'size' bytes long and return a pointer to it. The semantics are the same as malloc().
	void* (*Alloc)(size_t size, ILAlloc* myself);
	
	// This function should reallocate a portion of memory so that it is now 'newSize' bytes long. The semantics are the same as realloc().
	void* (*Realloc)(void* existing, size_t newSize, ILAlloc* myself);
	
	// This function should deallocate a portion of memory. The semantics are the same as free().
	void (*Free)(void* existing, ILAlloc* myself);
	
	// This function is called when there is a failure for this allocator. May be NULL. If NULL, IL__KO__CouldNotAllocateMemory() is called instead.
	ILAllocOnFailure OnAllocFailure;
	
	// Used by implementations to store private information.
	void* Extras;
	
};


// An ILAlloc implementation that uses malloc(), realloc() and free().
extern ILAlloc* const kILMalloc; // 99.8% of the time, you'll just pass this to any ILAlloc* parameter you see. Stuff will then Just Work.

// Call these functions to use a ILAlloc structure.
extern void* ILAllocate(size_t size, ILAlloc* alloc);
extern void* ILReallocate(void* existing, size_t size, ILAlloc* alloc);
extern void ILDeallocate(void* existing, ILAlloc* alloc);


// Default on-failure handler. Debugging symbol. Do not call (breakpoint on it).
extern void* IL__KO__CouldNotAllocateMemory(ILAllocFailure f);


#endif // #ifndef ILAlloc_h
