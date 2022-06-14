include "util.dfy"

/**
 * Simple Virtual Machine consists of a stack, some random access 
 * memory, a sequence of bytecode instructions (and operands) and,
 * finally, a program counter.
 */
type SVM = (stack<u16>,memory<u16>,seq<u8>,int)

/**
 * Extract stack from machine state.
 */ 
function stck(vm:SVM) : stack<u16> { vm.0 }		

/**
 * Extract data store from machine state.
 */
function mem(vm:SVM) : memory<u16> { vm.1 }

/**
 * Extract code sequence from machine state.
 */
function code(vm:SVM) : seq<u8> { vm.2 }
		
/**
 * Extract program counter from machine state.
 */
function pc(vm:SVM) : int { vm.3 }

/**
 * Machine is considered to be halted if the program counter 
 * is out-of-bounds.
 */
function halted(vm:SVM) : bool { pc(vm) >= |code(vm)| }

/**
 * A valid Simple Virtual Machine requires a valid stack and a 
 * valid memory.  The program counter must also be valid with 
 * respect to the bytecode sequence.
 */		
function validSVM(vm : SVM) : bool {
		validStack(stck(vm)) && validMemory(mem(vm)) && pc(vm) <= |code(vm)|
}

// =============================================================================
// Instructions
// =============================================================================

