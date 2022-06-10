import u8,u32 from std::int

// ==============================================================
// Simple Virtual Machine State
// ==============================================================

public type SVM is {
   // Program couner identifies next instruction
   // to execute
   u32 pc,
   // Stack pointer identifies first unused space.
   u32 sp,
   // Code memory holds bytecodes to execute.
   u8[] code,
   // Data memory is an arbitrary scratch area.
   u32[] data,   
   // Stack is used for evaluating bytecodes.
   u32[] stack
} where sp <= |stack|

public property create(u8[] code, u32 datasize, u32 stacksize) -> (SVM r):
   return {pc:0, sp:0, code: code, data: [0; datasize], stack: [0; stacksize]}

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
public property execute(SVM st) -> (SVM res):
   u8 opcode = st.code[st.pc]
   // increment pc
   SVM nst = st{pc:=st.pc+1}
   // Decode opcode
   if opcode == NOP:
      return executeNOP(nst)
   else if opcode == LDC:
      u8 k = nst.code[nst.pc]
      return executeLDC(nst{pc:=nst.pc+1},k)
   else if opcode == POP:
      return executePOP(nst)
   else if opcode == STORE:
      u8 k = nst.code[nst.pc]   
      return executeSTORE(nst{pc:=nst.pc+1},k)
   else if opcode == LOAD:
      u8 k = nst.code[nst.pc]   
      return executeLOAD(nst{pc:=nst.pc+1},k)
   else:
      return execute(st) // Errro!

public property executeNOP(SVM st) -> (SVM nst):
    return st

public property executeLDC(SVM st, u8 k) -> (SVM nst):
    return push(st, (u32) k)

public property executePOP(SVM st) -> (SVM nst):
    return pop(st)

public property executeSTORE(SVM st, u8 k) -> (SVM nst):
    // Read top of stack
    u32 v = peek(st,1)
    // Assign to data and pop stack
    return pop(store(st,k,v))

public property executeLOAD(SVM st, u8 k) -> (SVM nst):
    // Read value from data
    u32 v = read(st,k)
    // Push data to stack
    return push(st,v)

// public property executeADD(SVM st) -> (SVM nst):

// public property executeSUB(SVM st) -> (SVM nst):

// ==============================================================
// Helpers
// ==============================================================

public property push(SVM st, u32 k) -> SVM:
   return st{stack:=st.stack[st.sp:=k]}{sp:=st.sp+1}

public property peek(SVM st, int n) -> u32:
   return st.stack[st.sp - n]

public property pop(SVM st) -> SVM:
   return st{sp:=st.sp-1}

public property read(SVM st, u8 address) -> u32:
   return st.data[address]

public property store(SVM st, u8 address, u32 value) -> SVM:
   return st{data:=st.data[address:=value]}