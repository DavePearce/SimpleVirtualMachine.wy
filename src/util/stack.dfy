include "int.dfy"

module Stack {
		import opened Int 

		/**
		 * A raw stack consistents of a sequence of data, and a stack pointer.
		 */
		datatype Raw<T> = Stack(contents:seq<T>, sp:nat)
			
		/**
		 * A valid Stack: (1) must have a Stack pointer within bounds;
		 * (2) the Stack must be addressable with 16bits.  Note, the stack 
		 * pointer identifies the first *unused* slot on the stack.
		 */	
		type T<S> = s:Raw<S> | s.sp <= |s.contents| && |s.contents| <= MAX_U16
		witness Stack([],0)

		/**
		 * Get the capacity of this Stack.
		 */
		function capacity<S>(st:T<S>) : int { |st.contents| }
		
		/**
		 * Get the number of items currently on this Stack.
		 */
		function size<S>(st:T<S>) : int { st.sp }

		/**
		 * Create a stack from an initial sequence of words.
		 */
		function method create<S>(contents:seq<S>) : T<S>
		requires |contents| <= MAX_U16 {
				Stack(contents:=contents,sp:=0)
		}
		
		/**
		 * Push a value onto this Stack.  This requires that there is sufficient 
		 * space for that item.
		 */
		function push<S>(st:T<S>, val:S) : T<S>
				// Sanity check enough space.
				requires size(st) < capacity(st) {
						Stack(contents:=st.contents[st.sp:=val],sp:=st.sp+1)	
		}
		
		/**
		 * Peek nth value from top of Stack (where 1 is top item, 2 is next item, 
		 * and so on).  This requires there are sufficiently 
		 * many values.
		 */
		function peek<S>(st:T<S>, k:int) : S
				// Sanity check enough items to pop!
				requires k > 0 && k <= size(st) {
						st.contents[st.sp-k]
		}
		
		/**
		 * Pop a value off of this Stack.  This requires that there is actually 
		 * something to pop!
		 */
		function pop<S>(st:T<S>) : T<S>
				// Sanity check something to pop.
				requires size(st) > 0 {
						Stack(contents:=st.contents,sp:=st.sp-1)
		}
}
