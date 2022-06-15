include "svm.dfy"

import opened Int
import opened SVM		

// Initialise a Simple Virtual Machine where both stack and data have
// a capacity of 4 words.
function init(codes:seq<u8>) : SVM.SVM
  requires |codes| < MAX_U16 {
    SVM.create([0,0,0,0],[0,0,0,0],codes)				
}

// ==========================================================
// Concrete Tests
// ==========================================================

// Check most simple program possible
method test_01() {
  // Initialise SVM
  var vm := init([NOP]);
  // Execute program
  vm := SVM.run(vm,10);
  // Check what we know
  assert halted(vm);
  assert Stack.size(vm.stack) == 0;
  assert vm.data.contents == [0,0,0,0];	
}

// Check can put something on the stack
method test_02() {
  // Initialise SVM
  var vm := init([LDC,123]);
  // Execute program
  vm := SVM.run(vm,10);
  // Check what we know
  assert vm.pc == 2;
  assert Stack.size(vm.stack) == 1;
  assert Stack.peek(vm.stack,1) == 123;
}

// Check can take something off stack
method test_03() {
  // Initialise SVM
  var vm := init([LDC, 123, POP]);
  // Execute program
  vm := SVM.run(vm,10);
  // Check what we know
  assert vm.pc == 3;
  assert Stack.size(vm.stack) == 0;
  assert vm.data.contents == [0,0,0,0];
}

// Check can write to memory
method test_04() {
  // Initialise SVM
  var vm := init([LDC,123, STORE, 1]);
  // Execute program
  vm := SVM.run(vm,10);
  // Check what we know
  assert vm.pc == 4;
  assert Stack.size(vm.stack) == 0;
  assert vm.data.contents == [0,123,0,0];
}

// Check can read from memory
method test_05() {
  // Initialise SVM
  var vm := init([LOAD, 1]);
  vm := write(vm,1,123);
  // Execute program
  vm := SVM.run(vm,10);
  // Check what we know
  assert vm.pc == 2;
  assert Stack.size(vm.stack) == 1;
  assert Stack.peek(vm.stack,1) == 123;  
  assert vm.data.contents == [0,123,0,0];
}

// Check can write and read from memory
method test_06() {
  // Initialise SVM
  var vm := init([LDC,123,STORE,1,LOAD,1]);
  // Execute program
  vm := SVM.run(vm,10);
  // Check what we know
  assert vm.pc == 6;
  assert Stack.size(vm.stack) == 1;
  assert Stack.peek(vm.stack,1) == 123;  
  assert vm.data.contents == [0,123,0,0];
}

// Check can add two operands
method test_07() {
  // Initialise SVM
  var vm := init([LDC,1,LDC,2,ADD]);
  // Execute program
  vm := SVM.run(vm,10);
  // Check what we know
  assert vm.pc == 5;
  assert Stack.size(vm.stack) == 1;
  assert Stack.peek(vm.stack,1) == 3;
}

// Check can add two operands and write
method test_08() {
  // Initialise SVM
  var vm := init([LDC,1,LDC,2,ADD,STORE,2]);
  // Execute program
  vm := SVM.run(vm,10);
  // Check what we know
  assert vm.pc == 7;
  assert Stack.size(vm.stack) == 0;
  assert vm.data.contents == [0,0,3,0];
}

// ==========================================================
// Symbolic Tests
// ==========================================================

// Check loading symbolic data
method test_10(x:u16) {
  // Initialise SVM
  var vm := init([LOAD, 1]);
  vm := write(vm,1,x);
  // Execute program
  vm := SVM.run(vm,10);
  // Check what we know
  assert vm.pc == 2;
  assert Stack.size(vm.stack) == 1;
  assert Stack.peek(vm.stack,1) == x;
}

// Check swaping symbolic data
method test_11(x:u16, y:u16) {
  // Initialise SVM
  var vm := init([LOAD,1, LOAD,2, STORE,1, STORE,2]);
  vm := write(vm,1,x);
  vm := write(vm,2,y);  
  // Execute program
  vm := SVM.run(vm,10);
  // Check what we know
  assert vm.pc == 8;
  assert Stack.size(vm.stack) == 0;
  assert vm.data.contents == [0,y,x,0];
}
