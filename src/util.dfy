newtype{:nativeType "byte"} u8 = i:int | 0 <= i < 0x100
newtype{:nativeType "ushort"} u16 = i:int | 0 <= i < 0x10000	

const MAX_U16 : int := 65536;

// =============================================================================
// Machine Stack
// =============================================================================

type stack<T> = (seq<T>,int)

/**
 * A valid stack: (1) must have a stack pointer within bounds;
 * (2) the stack must be addressable with 16bits.
 */
function validStack<T>(st : stack<T>) : bool {
		st.1 >= 0 && st.1 <= |st.0| && |st.0| <= MAX_U16
}

/**
 * Get the capacity of this stack.
 */
function capacity<T>(st:stack<T>) : int { |st.0| }

/**
 * Get the number of items currently on this stack.
 */
function size<T>(st:stack<T>) : int { st.1 }

/**
 * Push a value onto this stack.  This requires that there is sufficient 
 * space for that item.
 */
function push<T>(st:stack<T>, val:T) : stack<T>
// Sanity check enough space.
requires capacity(st) < |st.0| {
	(st.0[st.1:=val],st.1+1)	
}

/**
 * Pop a value off of this stack.  This requires that there is actually 
 * something to pop!
 */
function pop<T>(st:stack<T>) : stack<T>
// Sanity check something to pop.
requires size(st) > 0 {
	(st.0,st.1-1)
}

// =============================================================================
// Random Access Memory
// =============================================================================
		
type memory<T> = seq<T>

/**
 * A valid memory must be addressable with 16bits
 */
function validMemory<T>(st : memory<T>) : bool { |st| < MAX_U16 }

/**
 * Read the value at a given address in memory.  This requires that the address 
 * is within bounds of the memory.
 */
function read<T>(mem:memory<T>, address:u16) : T
// Can only read from valid memory
requires validMemory<T>(mem)
// Address must be within bounds
requires address < (|mem| as u16) {
		mem[address]
}

/**
 * Write a value to a given address in memory.  This requires that the address 
 * is within bounds of the memory.
 */
function write<T>(mem:memory<T>, address:u16, val:T) : memory<T>
// Can only read from valid memory
requires validMemory<T>(mem)
// Address must be within bounds
requires address < (|mem| as u16) {
		mem[address:=val]
}
