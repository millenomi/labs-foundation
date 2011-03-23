//
//  ILStateMachine.h
//  Basics
//
//  Created by ∞ on 23/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef ILStateMachine_h
#define ILStateMachine_h 1

#include "ILAlloc.h"

typedef struct ILStateMachine ILStateMachine;

extern ILStateMachine* ILStateMachineCreate(ILAlloc* alloc);
extern void ILStateMachineDestroy(ILStateMachine* machine);

typedef enum {
	
	kILStateMachineAvailable,
	kILStateMachineFinished,
	kILStateMachineNoStartingState,
	kILStateMachineError,
	
} ILStateMachineStatus;


typedef ILStateMachineStatus (*ILStateMachineStateCallback)(ILStateMachine* machine, void* input);

extern void ILStateMachineSetState(ILStateMachine* machine, ILStateMachineStateCallback callback);

extern void* ILStateMachineGetExtras(ILStateMachine* machine);
extern void ILStateMachineSetExtras(ILStateMachine* machine, void* extras);

extern ILStateMachineStatus ILStateMachineProceed(ILStateMachine* m, void* input);

#endif
