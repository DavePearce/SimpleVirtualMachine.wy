include "int.dfy"

module Memory {
		import opened Int 
						
		// =============================================================================
		// Random Access Memory
		// =============================================================================
		
		datatype Raw<S> = Memory(contents:seq<S>)

		type T<S> = m:Raw<S> | |m.contents| < MAX_U16
		witness Memory([])

		/**
		 * Create a memory from an initial sequence of words.
		 */
		function method create<S>(contents:seq<S>) : T<S>
		requires |contents| < MAX_U16 {
				Memory(contents:=contents)
		}		
		
		function size<S>(mem:T<S>) : u16 {
				|mem.contents| as u16
		}
		
		/**
		 * Read the value at a given address in Memory.  This requires that the address 
		 * is within bounds of the Memory.
		 */
		function read<S>(mem:T<S>, address:u16) : S
			// Address must be within bounds
			requires address < (|mem.contents| as u16) {
				// Read location
				mem.contents[address]
		}
		
		/**
		 * Write a value to a given address in Memory.  This requires that the address 
		 * is within bounds of the Memory.
		 */
		function write<S>(mem:T<S>, address:u16, val:S) : T<S>
			// Address must be within bounds
			requires address < (|mem.contents| as u16) {
				// Write location
				Memory(contents:=mem.contents[address:=val])
		}
}
