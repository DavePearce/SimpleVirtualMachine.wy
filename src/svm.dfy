include "util.dfy"

/**
 * Simple Virtual Machine consists of a stack, some random access 
 * memory, a sequence of bytecode instructions (and operands) and,
 * finally, a program counter.
 */
type SVM = (stack<u16>,memory<u16>,seq<u8>,u16)

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
function pc(vm:SVM) : u16 { vm.3 }

/**
 * Machine is considered to be halted if the program counter 
 * is out-of-bounds.
 */
function halted(vm:SVM) : bool { pc(vm) >= (|code(vm)| as u16) }

/**
 * Force the machine into a halted state.
 */
function halt(vm:SVM) : SVM {
		(vm.0,vm.1,vm.2,|vm.2| as u16)
}
/**
 * A valid Simple Virtual Machine requires a valid stack and a 
 * valid memory.  The program counter must also be valid with 
 * respect to the bytecode sequence.
 */		
function validSVM(vm : SVM) : bool {
		validStack(stck(vm)) && validMemory(mem(vm)) && pc(vm) <= |code(vm)|
}

// =============================================================================
// Simple Virtual Machine Opcodes
// =============================================================================

const NOP:u8 := 0x00;
// Load constant onto stack
const LDC:u8 := 0x01
// Pop item off stack
const POP:u8 := 0x02
// Store top of stack to data
const STORE:u8 := 0x03
// Load data to stack
const LOAD:u8 := 0x04
// Add operands on stack
const ADD:u8 := 0x05

// =============================================================================
// Instructions
// =============================================================================

// Execute a "single step" of the current program.
function step(vm:SVM) : SVM
// Virtual machine must be valid		
requires validSVM(vm)
// Virtual machine cannot be halted.
requires !halted(vm) {
				// decode
				var opcode : u8 := svm_decode(vm);
				//
				var vm':SVM := svm_goto(vm, pc(vm)+1);
				//
				if opcode == NOP
				then
						stepNOP(vm')
				else
						// Opcodes requiring operand
						var k : u8 := svm_decode(vm');
						var vm'':SVM := svm_goto(vm', pc(vm')+1);
						//
						stepLDC(vm'',k)
				// else
				// 		halt(vm')
}

function stepNOP(vm:SVM) : SVM { vm }

function stepLDC(vm:SVM, k:u8) : SVM {
		if size(vm.0) < capacity(vm.0)
		then
				svm_push(vm,k)
		else 
				halt(vm)
}

// =============================================================================
// Microcode
// =============================================================================

function svm_decode(vm:SVM) : u8 { vm.2[vm.3] }

function svm_goto(vm:SVM, k:u16) : SVM { (vm.0,vm.1,vm.2,k) }

function svm_push(vm:SVM, k:u8) : SVM {
		(push(vm.0,k as u16),vm.1,vm.2,vm.3)
}

function svm_peek(vm:SVM) : u16 {
		peek(vm.0)
}

function svm_pop(vm:SVM) : SVM {
		(pop(vm.0),vm.1,vm.2,vm.3)
}
