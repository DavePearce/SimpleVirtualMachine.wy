import u8,u16,u32 from std::int

// ==============================================================
// Simple Virtual Machine State
// ==============================================================

public type SVM is {
   // Program couner identifies next instruction
   // to execute
   u16 pc,
   // Stack pointer identifies first unused space.
   u32 sp,
   // Code memory holds bytecodes to execute.
   u8[] code,
   // Data memory is an arbitrary scratch area.
   u32[] data,   
   // Stack is used for evaluating bytecodes.
   u32[] stack
}
where sp <= |stack|
where |code| < 65536 && pc <= |code|

public property create(u8[] code, u32 datasize, u32 stacksize) -> (SVM r):
   return {pc:0, sp:0, code: code, data: [0; datasize], stack: [0; stacksize]}

public property isHalted(SVM st) -> (bool r):
    return st.pc == |st.code|

// ==============================================================
// Simple Virtual Machine Opcodes
// ==============================================================

public final u8 NOP = 0x00
// Load constant onto stack
public final u8 LDC = 0x01
// Pop item off stack
public final u8 POP = 0x02
// Store top of stack to data
public final u8 STORE = 0x03
// Load data to stack
public final u8 LOAD = 0x04
// Add operands on stack
public final u8 ADD = 0x05
// Subtract operands on stack
public final u8 SUB = 0x06

// ==============================================================
// Simple Virtual Machine Semantics
// ==============================================================

// Top-level execute method
public property execute(SVM st) -> (SVM res)
requires !isHalted(st):
   u8 opcode = st.code[st.pc]
   // increment pc
   SVM nst = st{pc:=st.pc+1}
   // Decode opcode
   if opcode == NOP:
      return executeNOP(nst)
   else if opcode == LDC && !isHalted(nst):
      u8 k = nst.code[nst.pc]
      return executeLDC(nst{pc:=nst.pc+1},k)
   else if opcode == POP:
      return executePOP(nst)
   else if opcode == STORE && !isHalted(nst):
      u8 k = nst.code[nst.pc]   
      return executeSTORE(nst{pc:=nst.pc+1},k)
   else if opcode == LOAD && !isHalted(nst):
      u8 k = nst.code[nst.pc]   
      return executeLOAD(nst{pc:=nst.pc+1},k)
   else if opcode == ADD:
      return executeADD(nst)
   else:
      // Force machine to halt
      return halt(nst)

public property executeADD(SVM st) -> (SVM nst):
    if st.sp > 2:
        // Read operandsw
        u32 r = peek(st,1)
        u32 l = peek(st,2)
        u32 v = 0 // (l + r) % 4294967296
        // done
        return push(pop(pop(st)),v)
    else:
        return halt(st)

public property executeNOP(SVM st) -> (SVM nst):
    return st

public property executeLDC(SVM st, u8 k) -> (SVM nst):
    return push(st, (u32) k)

public property executePOP(SVM st) -> (SVM nst):
    return pop(st)

public property executeSTORE(SVM st, u8 k) -> (SVM nst):
    // sanity check requirements
    if st.sp > 1 && k < |st.data|:
        // Read top of stack
        u32 v = peek(st,1)
        // Assign to data and pop stack
        SVM nnst = store(st,k,v)
        //
        return pop(nnst)
    else:
        return halt(st)

public property executeLOAD(SVM st, u8 k) -> (SVM nst):
    // Sanity check requirements
    if k < |st.data|:
        // Read value from data
        u32 v = read(st,k)
        // Push data to stack
        return push(st,v)
    else:
        return halt(st)

// ==============================================================
// Helpers
// ==============================================================

public property push(SVM st, u32 k) -> SVM
requires st.sp < |st.stack|:
    return st{stack:=st.stack[st.sp:=k]}{sp:=st.sp+1}

public property peek(SVM st, int n) -> u32
requires st.sp < |st.stack|
requires 0 <= n && n < st.sp:
    return st.stack[st.sp - n]

public property pop(SVM st) -> SVM
requires st.sp > 1:
   return st{sp:=st.sp-1}

public property read(SVM st, u8 address) -> u32
requires address < |st.data|:
   return st.data[address]

public property store(SVM st, u8 address, u32 value) -> SVM
requires address < |st.data|:
   return st{data:=st.data[address:=value]}

public property halt(SVM st) -> SVM:
   return st{pc:=|st.code|}