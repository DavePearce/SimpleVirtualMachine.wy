include "svm.dfy"

import opened Int
import opened SVM		

// Initialise a Simple Virtual Machine where both stack and data have
// a capacity of 4 words.
function init(codes:seq<u8>) : SVM.SVM
		requires |codes| < MAX_U16 {
				SVM.create([0,0,0,0],[0,0,0,0],codes)				
}

method test() {
		// Initialise SVM
		var vm := init([LDC,1,STORE,2]);
		//
		assert !halted(vm);		
		// Execute a single step
		vm := SVM.run(vm,100);
		// Check what we know
		assert Stack.size(vm.stack) == 0;
		assert Memory.read(vm.data,2) == 1;
		//assert Stack.peek(vm.stack,1) == ;
}
		
