include "util/int.dfy"	
include "util/stack.dfy"
include "util/memory.dfy"
include "util/code.dfy"	

import opened Int

/**
 * Simple Virtual Machine consists of a stack, some random access 
 * memory, a sequence of bytecode instructions (and operands) and,
 * finally, a program counter.
 */
datatype RawSVM = SVM(
	stack:Stack.T<u16>,
	mem:Memory.T<u16>,
	code:Code.T<u8>,
	pc:u16)

/**
 * A valid Simple Virtual Machine requires a valid stack and a 
 * valid memory.  The program counter must also be valid with 
 * respect to the bytecode sequence.
 */		
type SVM = vm:RawSVM | vm.pc <= Code.size(vm.code)
witness SVM(stack:=Stack.empty(),mem:=Memory.empty(),code:=Code.empty(),pc:=0)
	
/**
 * Machine is considered to be halted if the program counter 
 * is out-of-bounds.
 */
function halted(vm:SVM) : bool { vm.pc >= Code.size(vm.code) }

/**
 * Force the machine into a halted state.
 */
function halt(vm:SVM) : SVM {
	// Set pc to maximum position.
	SVM(stack:=vm.stack, mem:=vm.mem, code:=vm.code, pc:=Code.size(vm.code))
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
	// Virtual machine cannot be halted.
	requires !halted(vm) {
		// decode
		var (vm',opcode) := decode(vm);
		//
		if opcode == ADD then stepADD(vm')
		else if opcode == LDC then stepLDC(vm')
		else if opcode == LOAD then stepLOAD(vm')
		else if opcode == NOP then stepNOP(vm')
		else if opcode == STORE then stepSTORE(vm')				
		else 
		 	halt(vm')
}

/**
 * Execute an ADD instruction which pops two operands from the stack, and
 * pushes their sum back.
 */
function stepADD(vm:SVM) : SVM {
		if !halted(vm) && operands(vm,2)
			then
			var rhs := peek(vm,1) as int;
			var lhs := peek(vm,2) as int;
			var sum := (lhs + rhs) % 65536;
			push(pop(pop(vm)),sum as u16)
		else
				halt(vm)
}

/**
 * Execute an LDC instruction which pushes a constant onto the stack.
 */
function stepLDC(vm:SVM) : SVM {
		if !halted(vm) && operands(vm,1) && available(vm,1)
			then
			// Decode operand
			var (vm',k) := decode_operand(vm);
			// Push operand on stack
			push(vm',k)
		else 
			halt(vm)
}

/**
 * Execute a LOAD instruction which writes the top of the stack into 
 * a given (static) memory location.  The location is provided as an 
 * operand.
 */
function stepLOAD(vm:SVM) : SVM {
		if !halted(vm) && available(vm,1)
			then
			// Decode operand
			var (vm',k) := decode_operand(vm);
			// Sanity check valid address
			if k < Memory.size(vm.mem)
			// Push operand on stack
			then push(vm',read(vm, k))
			else
				halt(vm')
		else 
				halt(vm)		
}

/**
 * Execute a NOP instruction which leaves the SVM unchanged.
 */
function stepNOP(vm:SVM) : SVM { vm }

/**
 * Execute a STORE instruction which pushes the contents of a 
 * given (static) memory location onto the stack.  The location 
 * is provided as an operand.
 */
function stepSTORE(vm:SVM) : SVM {
		if !halted(vm) && operands(vm,1)
			then
			// Decode operand
			var (vm',k) := decode_operand(vm);
			// Identify value on top of stack
			var v := peek(vm',1);
			// Sanity check valid address
			if k < Memory.size(vm.mem)
			// Write item to memory (and pop stack).
			then write(pop(vm'), k, v)
			else
				halt(vm')
		else 
				halt(vm)		
}

// =============================================================================
// Microcode
// =============================================================================

/**
 * Check at least k operands on the stack.
 */
function operands(vm:SVM, k:int) : bool {
	Stack.size(vm.stack) >= k
}

/**
 * Check sufficient space to push k items onto the stack.
 */
function available(vm:SVM, k:int) : bool {
	Stack.size(vm.stack) <= Stack.capacity(vm.stack) - k
}

/**
 * Decode next opcode from machine.
 */
function decode(vm:SVM) : (SVM,u8)
	requires !halted(vm) {
		(goto(vm,vm.pc+1),Code.decode_u8(vm.code,vm.pc))
}

/**
 * Decode next operand from machine.
 */
function decode_operand(vm:SVM) : (SVM,u16)
	requires !halted(vm) {
		var (vm',k) := decode(vm);
		(vm',k as u16)
}

/**
 * Move program counter to a given location.
 */
function goto(vm:SVM, k:u16) : SVM
	requires k <= Code.size(vm.code) {
	SVM(stack:=vm.stack,mem:=vm.mem,code:=vm.code,pc:=k)
}

/**
 * Push byte onto stack.
 */
function push(vm:SVM, v:u16) : SVM
requires Stack.size(vm.stack) < Stack.capacity(vm.stack) {
	SVM(
		stack:= Stack.push(vm.stack,v),
		mem:=vm.mem,
		code:=vm.code,
		pc:=vm.pc)
}

/**
 * Peek word from a given position on the stack, where "1" is the 
 * topmost position, "2" is the next position and so on.
 */
function peek(vm:SVM, k:int) : u16
  // Sanity check peek possible
	requires k > 0 && k <= Stack.size(vm.stack) {
		Stack.peek(vm.stack,k)
} 

/**
 * Pop word from stack.
 */
function pop(vm:SVM) : SVM
	// Cannot pop from empty stack
	requires Stack.size(vm.stack) >= 1 {
		SVM(stack:=Stack.pop(vm.stack),
			mem:=vm.mem,
			code:=vm.code,
			pc:=vm.pc)		
}

/**
 * Read word from data memory.
 */
function read(vm:SVM, k:u16) : u16
// Address must be within bounds		
requires k < Memory.size(vm.mem) {
		Memory.read(vm.mem,k)
}

/**
 * Write word into data memory.
 */
function write(vm:SVM, k:u16, v:u16) : SVM
// Address must be within bounds		
requires k < Memory.size(vm.mem) {
		SVM(stack:=vm.stack,
				mem:=Memory.write(vm.mem,k,v),
				code:=vm.code,
				pc:=vm.pc)
}
