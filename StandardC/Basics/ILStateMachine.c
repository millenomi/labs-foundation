//
//  ILStateMachine.c
//  Basics
//
//  Created by ∞ on 23/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ILStateMachine.h"

#include <stdlib.h>

struct ILStateMachine {
	ILAlloc* Alloc;
	
	ILStateMachineStatus Status;
	ILStateMachineStateCallback StateCallback;
	
	void* Extras;
};

ILStateMachine* ILStateMachineCreate(ILAlloc* alloc) {
	ILStateMachine* me = ILAllocate(sizeof(ILStateMachine), alloc);
	me->Alloc = alloc;
	me->Status = kILStateMachineNoStartingState;
	me->StateCallback = NULL;
	return me;
}

void ILStateMachineDestroy(ILStateMachine* machine) {
	ILDeallocate(machine, machine->Alloc);
}

void ILStateMachineSetState(ILStateMachine* machine, ILStateMachineStateCallback callback) {
	machine->StateCallback = callback;
	
	if (machine->Status == kILStateMachineNoStartingState)
		machine->Status = kILStateMachineAvailable;
}

void* ILStateMachineGetExtras(ILStateMachine* machine) {
	return machine->Extras;
}

void ILStateMachineSetExtras(ILStateMachine* machine, void* extras) {
	machine->Extras = extras;
}

ILStateMachineStatus ILStateMachineProceed(ILStateMachine* m, void* input) {
	
	switch (m->Status) {
		case kILStateMachineNoStartingState:
		case kILStateMachineFinished:
		case kILStateMachineError:
			return m->Status;
			
		case kILStateMachineAvailable:
		{
			ILStateMachineStatus status = m->StateCallback(m, input);
			m->Status = status;
			return status;
		}
	}
	
}
