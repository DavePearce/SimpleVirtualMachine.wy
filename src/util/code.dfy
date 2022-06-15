include "int.dfy"

module Code {
  import opened Int 

  // =============================================================================
  // Code Segment
  // =============================================================================

  /**
   * A code segment is just a sequence of words which form the 
   * opcodes and operands of the machine instructions.
   */
  datatype Raw<S> = Code(contents:seq<S>)
    
  type T<S> = c:Raw<S> | |c.contents| < MAX_U16 witness Code([])

  /**
   * Create a code segment from an initial sequence of words.
   */
  function method create<S>(contents:seq<S>) : T<S>
    requires |contents| < MAX_U16 {
        Code(contents:=contents)
  }    
  
  /**
   * Get the size of this code segment.
   */
  function size<S>(c:T<S>) : u16 { |c.contents| as u16 }
  
  function decode_u8<S>(c:T<S>, pc:u16) : S
    // Decode position must be valid.
    requires pc < size(c) {
      // Read word at given location
      c.contents[pc]
  }
}
